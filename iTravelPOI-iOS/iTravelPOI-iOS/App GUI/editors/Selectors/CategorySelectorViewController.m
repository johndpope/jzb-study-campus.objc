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

#import "MCategory.h"
#import "NSManagedObjectContext+Utils.h"

#import "CategoryEditorViewController.h"

#import "TDBadgedCell.h"
#import "ImageManager.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface CategorySelectorViewController() <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, assign) IBOutlet UISegmentedControl *buttonsBar;
@property (nonatomic, assign) IBOutlet UITableView *catsTableView;

@property (nonatomic, strong) NSManagedObjectContext *moContext;
@property (nonatomic, strong) MMap *selectedMap;

@property (nonatomic, assign) BOOL multiSelection;
@property (nonatomic, strong) NSMutableArray *selectedCategories;

@property (nonatomic, weak)   NSMutableArray *allCategories;
@property (nonatomic, strong) NSMutableArray *inMapCategories;
@property (nonatomic, strong) NSMutableArray *frequentCategories;
@property (nonatomic, strong) NSMutableArray *otherCategories;

@property (nonatomic, strong) CSCloseCallback closeCallback;

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
+ (CategorySelectorViewController *) categoriesSelectorInContext:(NSManagedObjectContext *)moContext
                                                     selectedMap:(MMap *)selectedMap
                                             currentSelectedCats:(NSArray *)currentSelectedCats
                                                  multiSelection:(BOOL)multiSelection {

    if(moContext!=nil) {
        CategorySelectorViewController *me = [[CategorySelectorViewController alloc] initWithNibName:@"CategorySelectorViewController" bundle:nil];
        me.moContext = moContext;
        me.selectedMap = selectedMap;
        me.selectedCategories = [NSMutableArray arrayWithArray:currentSelectedCats];
        me.multiSelection = multiSelection;
        me.allCategories = nil;
        me.inMapCategories = nil;
        me.frequentCategories = nil;
        me.otherCategories = nil;
        return me;
    } else {
        DDLogVerbose(@"Warning: CategorySelectorViewController-categoriesSelectorInContext called with nil moContext");
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) showModalWithController:(UIViewController *)controller closeCallback:(CSCloseCallback)closeCallback {
    
    self.closeCallback = closeCallback;
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [controller presentViewController:self animated:YES completion:nil];
}







//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
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
    
    // Avisa al callback
    if(self.closeCallback) {
        self.closeCallback(self.selectedCategories);
    }
    
    // Y cierra el editor
    [self _dismissEditor];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)addBarBtnClicked:(UIBarButtonItem *)sender {

    // Crea el editor
    CategoryEditorViewController *catEditor= [CategoryEditorViewController editorWithNewCategoryInContext:self.moContext
                                                                                           parentCategory:nil
                                                                                            associatedMap:self.selectedMap];

    // Y lo abre de forma modal gestionando el que se haya añadido la entidad
    [catEditor showModalWithController:self startEditing:NO closeSavedCallback:^(MBaseEntity *entity) {
        
        // Casting de la entidad añadida
        MCategory *newCat = (MCategory *)entity;
        
        
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
    }];
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
    MCategory *selCategory = [item clickedAtIndex:indexPath.row selCats:self.selectedCategories];
    
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
    self.allCategories = nil;
    self.inMapCategories = nil;
    self.frequentCategories = nil;
    self.otherCategories = nil;
    self.selectedMap = nil;
    self.closeCallback = nil;
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

