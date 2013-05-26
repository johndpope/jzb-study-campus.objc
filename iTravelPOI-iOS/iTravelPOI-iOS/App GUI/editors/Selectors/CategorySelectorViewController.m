//
//  CategorySelectorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __CategorySelectorViewController__IMPL__
#define __MBaseEntity__SUBCLASSES__PROTECTED__

#import "CategorySelectorViewController.h"
#import "TExpandableTableItem.h"
#import "CategoryEditorViewController.h"
#import "TDBadgedCell.h"
#import "BaseCoreData.h"
#import "MCategory.h"

#import "ImageManager.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface CategorySelectorViewController() <UITableViewDelegate, UITableViewDataSource, EntityEditorDelegate>


@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, assign) IBOutlet UISegmentedControl *buttonsBar;
@property (nonatomic, assign) IBOutlet UITableView *catsTableView;

@property (nonatomic, assign) UIViewController<CategorySelectorDelegate> *delegate;
@property (nonatomic, strong) NSManagedObjectContext *moContext;
@property (nonatomic, strong) MMap *selectedMap;

@property (nonatomic, strong) NSMutableArray *selectedCategories;
@property (nonatomic, strong) MCategory *excludedCategory;
@property (nonatomic, assign) BOOL multiSelection;
@property (nonatomic, weak)   NSMutableArray *allCategories;
@property (nonatomic, strong) NSMutableArray *inMapCategories;
@property (nonatomic, strong) NSMutableArray *frequentCategories;
@property (nonatomic, strong) NSMutableArray *otherCategories;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation CategorySelectorViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (CategorySelectorViewController *) startCategoriesSelectorInContext:(NSManagedObjectContext *)moContext
                                                          selectedMap:(MMap *)selectedMap
                                                  currentSelectedCats:(NSArray *)currentSelectedCats
                                                  excludeFromCategory:(MCategory *)excludeFromCategory
                                                       multiSelection:(BOOL)multiSelection
                                                             delegate:(UIViewController<CategorySelectorDelegate> *)delegate {

    if(moContext!=nil && delegate!=nil) {
        CategorySelectorViewController *me = [[CategorySelectorViewController alloc] initWithNibName:@"CategorySelectorViewController" bundle:nil];
        me.delegate = delegate;
        me.moContext = moContext;
        me.selectedMap = selectedMap;
        me.selectedCategories = [NSMutableArray arrayWithArray:currentSelectedCats];
        me.excludedCategory = excludeFromCategory;
        me.multiSelection = multiSelection;
        me.allCategories = nil;
        me.inMapCategories = nil;
        me.frequentCategories = nil;
        me.otherCategories = nil;
        me.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [delegate presentViewController:me animated:YES completion:nil];
        return me;
    } else {
        DDLogVerbose(@"Warning: CategorySelectorViewController-startEditingMap called with nil moContext or Delegate");
        return nil;
    }
}






//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.buttonsBar.selectedSegmentIndex = self.selectedMap!=nil ? 0 : 1;
    [self.buttonsBar addTarget:self
                        action:@selector(buttonsBarClicked:)
              forControlEvents:UIControlEventValueChanged];

    
    // Actualiza los campos desde la entidad a editar
    [self _loadCategoriesInfo];

}



//=====================================================================================================================
#pragma mark -
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (void) buttonsBarClicked:(UISegmentedControl *)sender {
    [self _loadCategoriesInfo];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)doneBarBtnClicked:(UIBarButtonItem *)sender {
    if([self.delegate closeCategorySelector:self selectedCategories:self.selectedCategories]) {
        [self _dismissEditor];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)addBarBtnClicked:(UIBarButtonItem *)sender {

    
    NSManagedObjectContext *moc = [BaseCoreData moChildContext];
    MCategory *newCat = [MCategory categoryWithFullName:@"name" inContext:moc];
    MMap *copyMap = self.selectedMap!=nil ? (MMap *)[moc objectWithID:self.selectedMap.objectID] : nil;
    
    [CategoryEditorViewController startEditingCategory:newCat inMap:copyMap delegate:self];
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) editorSaveChanges:(UIViewController<EntityEditorViewController> *)senderEditor modifiedEntity:(MBaseEntity *)modifiedEntity {
    
    [BaseCoreData saveMOContext:modifiedEntity.managedObjectContext saveAll:NO];
    MCategory *newCat = (MCategory *)[self.moContext objectWithID:modifiedEntity.objectID];

    // Borra el resto de checks
    [self.inMapCategories enumerateObjectsUsingBlock:^(TExpandableTableItem *item, NSUInteger idx, BOOL *stop) {
        [item clearCheck];
    }];

    [self.frequentCategories enumerateObjectsUsingBlock:^(TExpandableTableItem *item, NSUInteger idx, BOOL *stop) {
        [item clearCheck];
    }];
    
    [self.otherCategories enumerateObjectsUsingBlock:^(TExpandableTableItem *item, NSUInteger idx, BOOL *stop) {
        [item clearCheck];
    }];
    
    // Crea un nuevo item y lo pone seleccionado y el primero
    TExpandableTableItem *item = [TExpandableTableItem expandableTableItemWithCategory:newCat isChecked:YES];
    if(self.selectedMap!=nil) {
        [newCat updateViewCount:0 inMap:self.selectedMap];
        self.buttonsBar.selectedSegmentIndex = 0;
        [self _loadCategoriesInfo];
    } else {
        self.buttonsBar.selectedSegmentIndex = 1;
        [self _loadCategoriesInfo];
    }

    [self.allCategories insertObject:item atIndex:0];

    [self.selectedCategories removeAllObjects];
    [self.selectedCategories addObject:newCat];
    
    [self.catsTableView reloadData];
    
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) editorCancelChanges:(UIViewController<EntityEditorViewController> *)senderEditor {
    return TRUE;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Secciones a refrescar
    NSMutableIndexSet *sectionsToRefresh = [NSMutableIndexSet indexSetWithIndex:indexPath.section];
    
    // Ajustamos el estado de seleccion y expansion del elemento seleccionado
    TExpandableTableItem *item = (TExpandableTableItem *)self.allCategories[indexPath.section];
    MCategory *selCategory = [item clickedAtIndex:indexPath.row selCats:self.selectedCategories excludedCat:self.excludedCategory];
    
    if(selCategory!=nil) {
        if(item.isChecked) {
            if(!self.multiSelection) {
                [self.selectedCategories removeAllObjects];
            }
            [self.selectedCategories addObject:selCategory];
        } else {
            [self.selectedCategories removeObject:selCategory];
        }
    }
    
    // Gestiona la NO multi seleccion en el array "visible" y en los ocultos
    if(!self.multiSelection && item.isChecked) {
        
        for(NSUInteger index = 0; index<self.allCategories.count; index++) {
            TExpandableTableItem *otherItem = self.allCategories[index];
            if(otherItem!=item && otherItem.isChecked) {
                [otherItem clearCheck];
                [sectionsToRefresh addIndex:index];
            }
        }
        
        if(self.allCategories!=self.inMapCategories) {
            for(TExpandableTableItem *otherItem in self.inMapCategories) {
                if(otherItem!=item && otherItem.isChecked) {
                    [otherItem clearCheck];
                }
            }
        }
        
        if(self.allCategories!=self.frequentCategories) {
            for(TExpandableTableItem *otherItem in self.frequentCategories) {
                if(otherItem!=item && otherItem.isChecked) {
                    [otherItem clearCheck];
                }
            }
        }
        
        if(self.allCategories!=self.otherCategories) {
            for(TExpandableTableItem *otherItem in self.otherCategories) {
                if(otherItem!=item && otherItem.isChecked) {
                    [otherItem clearCheck];
                }
            }
        }
    }
    
    // Refrescamos la visualizacion de la tabla
    [tableView reloadSections:sectionsToRefresh withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // No dejamos nada seleccionado
    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allCategories.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    TExpandableTableItem *item = (TExpandableTableItem *)self.allCategories[section];
    return item.currentSize;
}


//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";

    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryView = [[UIImageView alloc] initWithImage:TExpandableTableItem.imageUnchecked];
    }
    

    TExpandableTableItem *item = (TExpandableTableItem *)self.allCategories[indexPath.section];
    [item fillCellView:cell withIndex:indexPath.row];
    
    return cell;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {
    
    [self dismissViewControllerAnimated:YES completion:nil];

    // Set properties to nil
    self.selectedCategories = nil;
    self.excludedCategory = nil;
    self.allCategories = nil;
    self.inMapCategories = nil;
    self.frequentCategories = nil;
    self.otherCategories = nil;
    self.selectedMap = nil;
    self.delegate = nil;
    self.moContext = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _loadCategoriesInfo {
    
    switch (self.buttonsBar.selectedSegmentIndex) {
        case 0:
            if(self.inMapCategories==nil) {
                self.inMapCategories = [NSMutableArray array];
                NSArray *rootCats=[MCategory rootCategoriesWithPointsInMap:self.selectedMap];
                [self _addLoadedRootCategories:rootCats into:self.inMapCategories];
            }
            self.allCategories = self.inMapCategories;
            [self.catsTableView reloadData];
            break;
            
        case 1:
            if(self.frequentCategories==nil) {
                self.frequentCategories = [NSMutableArray array];
                NSArray *rootCats=[MCategory frequentRootCategoriesWithPointsNotInMap:self.selectedMap];
                [self _addLoadedRootCategories:rootCats into:self.frequentCategories];
            }
            self.allCategories = self.frequentCategories;
            [self.catsTableView reloadData];
            break;
            
        case 2:
            if(self.otherCategories==nil) {
                self.otherCategories = [NSMutableArray array];
                NSArray *rootCats=[MCategory otherRootCategoriesWithPointsNotInMap:self.selectedMap];
                [self _addLoadedRootCategories:rootCats into:self.otherCategories];
            }
            self.allCategories = self.otherCategories;
            [self.catsTableView reloadData];
            break;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _addLoadedRootCategories:(NSArray *)rootCats into:(NSMutableArray *)intoCategories {
    
    for(MCategory *cat in rootCats) {
        
        // Comprueba si hay que excluirla
        if(cat.internalIDValue == self.excludedCategory.internalIDValue || [cat isDescendatOf:self.excludedCategory]) {
            continue;
        }
        
        // Por cada categoria raiz comprueba si hay alguna seleccionada de la misma jerarquia
        MCategory *replacedCat = cat;
        BOOL isChecked = FALSE;
        for(MCategory *selCat in self.selectedCategories) {
            if(selCat.hierarchyIDValue==cat.hierarchyIDValue) {
                replacedCat = (MCategory *)[cat.managedObjectContext objectWithID:selCat.objectID];
                isChecked = TRUE;
                break;
            }
        }
        
        TExpandableTableItem *item = [TExpandableTableItem expandableTableItemWithCategory:replacedCat isChecked:isChecked];
        [intoCategories addObject:item];
    }
}


@end

