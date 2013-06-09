//
//  CategoryEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __CategoryEditorViewController__IMPL__
#define __EntityEditorViewController__SUBCLASSES__PROTECTED__

#import <QuartzCore/QuartzCore.h>
#import "CategoryEditorViewController.h"

#import "MCategory.h"
#import "MPoint.h"

#import "IconEditorViewController.h"
#import "CategorySelectorViewController.h"

#import "TDBadgedCell.h"
#import "UIView+FirstResponder.h"
#import "NSString+JavaStr.h"

#import "ImageManager.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface CategoryEditorViewController() <UITextFieldDelegate, UITextViewDelegate,
                                           UITableViewDelegate, UITableViewDataSource,
                                           CategorySelectorDelegate, IconEditorDelegate>


@property (nonatomic, assign) IBOutlet UIImageView *iconImageField;
@property (nonatomic, assign) IBOutlet UITextField *nameField;
@property (nonatomic, assign) IBOutlet UILabel *extraInfo;
@property (nonatomic, assign) IBOutlet UITableView *parentCatTable;
@property (nonatomic, assign) IBOutlet UISwitch *modifyInAllMaps;

@property (nonatomic, strong) MMap *map;
@property (nonatomic, strong) MCategory *parentCat;
@property (nonatomic, strong) NSString *catIconHREF;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation CategoryEditorViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (CategoryEditorViewController *) editorWithAssociatedMap:(MMap *)map {
    
    CategoryEditorViewController *me = [[CategoryEditorViewController alloc] initWithNibName:@"CategoryEditorViewController" bundle:nil];
    me.map = map;
    return me;
}




//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Borra el color de fondo de la tabla
    self.parentCatTable.backgroundColor = [UIColor clearColor];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // Rota la imagen con el icono para indicar que esditable
    [self _rotateImageField:self.iconImageField];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (MCategory *)category {
    return (MCategory *)self.entity;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setCategory:(MCategory *)category {
    self.entity = category;
}




//=====================================================================================================================
#pragma mark -
#pragma mark <IconEditorDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeIconEditor:(IconEditorViewController *)senderEditor {
    [self _setImageFieldFromIconHREF:senderEditor.iconBaseHREF];
    return true;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <CategorySelectorDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeCategorySelector:(CategorySelectorViewController *)senderEditor selectedCategories:(NSArray *)selectedCategories {

    MCategory *selectedCat = nil;
    if(selectedCategories.count>0) {
         selectedCat = selectedCategories[0];
    }
    
    // No puede ser su categoria padre ni el mismo, ni ningun descendiente suyo
    if(selectedCat.internalIDValue!=self.category.internalIDValue && ![selectedCat isDescendatOf:self.category]) {
        self.parentCat = selectedCat;
        [self.parentCatTable reloadData];
    }
    
    return YES;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // No dejamos nada seleccionado
    [CategorySelectorViewController startCategoriesSelectorInContext:self.moContext
                                                         selectedMap:self.map
                                                 currentSelectedCats:self.parentCat!=nil ? [NSArray arrayWithObject:self.parentCat] : nil
                                                 excludeFromCategory:self.category
                                                      multiSelection:NO
                                                            delegate:self];
    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Parent Category";
}


//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";
    
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    

    if(self.parentCat!=nil) {
        cell.imageView.image = self.parentCat.entityImage;
        cell.textLabel.text = self.parentCat.fullName;
    } else {
        cell.imageView.image = nil;
        cell.textLabel.text = @"<none>";
    }
    
    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)iconImageTapAction:(UITapGestureRecognizer *)sender {
    
    // Aquí se hacia una comprobación de que no se estuviese editando un texto????
    if(sender.state == UIGestureRecognizerStateEnded) {
        [self.view findFirstResponderAndResign];
        [IconEditorViewController startEditingIcon:self.catIconHREF delegate:self];
    }
}






//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _editorTitle {
    return @"Category Editor";
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _nullifyEditor {
    
    [super _nullifyEditor];
    
    self.map = nil;
    self.catIconHREF = nil;
    self.parentCat = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setImageFieldFromIconHREF:(NSString *)iconHREF {
    
    IconData *icon = [ImageManager iconDataForHREF:iconHREF];
    self.catIconHREF = iconHREF;
    self.iconImageField.image = icon.image;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity:(MBaseEntity *)entity {
    
    MCategory *category = (MCategory *)entity;
    
    self.parentCat = category.parent;
    self.nameField.text = category.name;
    [self _setImageFieldFromIconHREF:category.iconHREF];
    self.extraInfo.text = [NSString stringWithFormat:@"Updated:\t%@\n",
                                       [MBaseEntity stringFromDate:category.updateTime]];
    
    self.modifyInAllMaps.on = YES;
    self.modifyInAllMaps.enabled = (self.map!=nil);

    [self.parentCatTable reloadData];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues:(MBaseEntity *)entity {

    MCategory *category = (MCategory *)entity;
    
    NSString *catName = [self.nameField.text trim];
    if(catName.length==0) {
        IconData *icon = [ImageManager iconDataForHREF:self.catIconHREF];
        catName = icon.shortName;
    }

    
    NSString *destFullName;
    if(self.parentCat==nil) {
        // Es una categoria raiz
        destFullName = catName;
    } else {
        destFullName = [NSString stringWithFormat:@"%@%@%@",self.parentCat.fullName,CATEGORY_NAME_SEPARATOR,catName];
    }
    
    
    // Busca la categoria que concuerda con los valores actuales
    MCategory *destCat = [MCategory categoryWithFullName:destFullName inContext:self.moContext];
    
    // Si ha habido cambios en el nombre o la categoria padre hay que transferir la informacion
    if(category.internalIDValue!=destCat.internalIDValue) {
        destCat.iconHREF = self.catIconHREF;
        MMap *useMap = self.modifyInAllMaps.on ? nil : self.map;
        [category transferTo:destCat inMap:useMap];
        [category markAsModified];
        self.category = destCat;
    }
    
    category.iconHREF = self.catIconHREF;
    [category markAsModified];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _allSubcategoriesFor:(MCategory *)cat allSubCats:(NSMutableArray *)allSubCats {
    
    [allSubCats addObject:cat];
    for(MCategory *subCat in cat.subCategories) {
        [self _allSubcategoriesFor:subCat allSubCats:allSubCats];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbItemsForEditingOthers {
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _enableFieldsForEditing {
    
    //self.fName.enabled = YES;
    //self.fSummary.editable = YES;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _disableFieldsFromEditing {
    
    //self.fName.enabled = NO;
    //self.fSummary.editable = NO;
}


@end

