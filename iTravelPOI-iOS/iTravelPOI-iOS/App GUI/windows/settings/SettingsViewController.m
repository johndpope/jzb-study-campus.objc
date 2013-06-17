//
//  SettingsViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __SettingsViewController__IMPL__
#define __EntityEditorViewController__SUBCLASSES__PROTECTED__

#import <QuartzCore/QuartzCore.h>
#import "SettingsViewController.h"

#import "MPoint.h"

#import "IconEditorViewController.h"
#import "CategorySelectorViewController.h"
#import "NSManagedObjectContext+Utils.h"

#import "UIView+FirstResponder.h"
#import "NSString+JavaStr.h"

#import "ImageManager.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define TAG_VIEW_ICON              8001
#define TAG_VIEW_TAGS              8002




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface SettingsViewController() <IconEditorDelegate>


@property (nonatomic, assign) IBOutlet UIImageView              *fIconImage;
@property (nonatomic, assign) IBOutlet UITextField              *fName;
@property (nonatomic, assign) IBOutlet UILabel                  *fExtraInfo;
@property (nonatomic, assign) IBOutlet UIView                   *vCategoriesSection;
@property (nonatomic, assign) IBOutlet UISwitch                 *fModifyInAllMaps;

@property (nonatomic, strong) MCategory *parentCat;
@property (nonatomic, strong) NSString *catIconHREF;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation SettingsViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (SettingsViewController *) editorWithCategory:(MCategory *)category associatedMap:(MMap *)map {
    
    // Crea el editor desde el NIB y lo inicializa con la entidad (y contexto) especificada
    SettingsViewController *me = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [me initWithEntity:category moContext:category.managedObjectContext];
    me.associatedEntity = map;
    return me;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Establece los TAGs para poder localizar a las vistas
    self.fIconImage.tag = TAG_VIEW_ICON;
    self.vCategoriesSection.tag = TAG_VIEW_TAGS;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
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

//---------------------------------------------------------------------------------------------------------------------
- (MMap *) map {
    return (MMap *)self.associatedEntity;
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
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)iconImageTapAction:(UITapGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded) {
        
        // Retira, si estaba, el teclado
        [self.view findFirstResponderAndResign];
        
        // Muestra el editor de iconos
        [IconEditorViewController startEditingIcon:self.catIconHREF delegate:self];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)vCategoriesTapAction:(UITapGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded) {
        
        // Retira, si estaba, el teclado
        [self.view findFirstResponderAndResign];
        
        // Muestra el editor de categorias
        // Creamos el editor
        CategorySelectorViewController *editor = [CategorySelectorViewController categoriesSelectorInContext:self.moContext
                                                                                                 selectedMap:self.map
                                                                                         currentSelectedCats:self.parentCat!=nil ? [NSArray arrayWithObject:self.parentCat] : nil
                                                                                              multiSelection:NO];
        
        // Lo abrimos de forma modal y gestionamos la seleccion
        [editor showModalWithController:self closeCallback:^(NSArray *selectedCategories) {
            
            MCategory *selectedCat = nil;
            if(selectedCategories.count>0) {
                selectedCat = selectedCategories[0];
            }
            
            // No puede ser su categoria padre ni el mismo, ni ningun descendiente suyo
            if(selectedCat.internalIDValue!=self.category.internalIDValue && ![selectedCat isDescendatOf:self.category]) {
                self.parentCat = selectedCat;
                if(self.parentCat) {
                    [self _createTagsViewContent:self.vCategoriesSection categories:[NSArray arrayWithObject:self.parentCat] nextView:nil];
                } else {
                    [self _createTagsViewContent:self.vCategoriesSection categories:[NSArray array] nextView:nil];
                }
            }
        }];
    }
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _editorTitle {
    return @"Tag Information";
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _nullifyEditor {
    
    [super _nullifyEditor];
    
    self.catIconHREF = nil;
    self.parentCat = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setImageFieldFromIconHREF:(NSString *)iconHREF {
    
    IconData *icon = [ImageManager iconDataForHREF:iconHREF];
    self.catIconHREF = iconHREF;
    self.fIconImage.image = icon.image;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    self.parentCat = self.category.parent;
    if(self.parentCat) {
        [self _createTagsViewContent:self.vCategoriesSection categories:[NSArray arrayWithObject:self.parentCat] nextView:nil];
    } else {
        [self _createTagsViewContent:self.vCategoriesSection categories:[NSArray array] nextView:nil];
    }

    self.fName.text = self.category.name;
    [self _setImageFieldFromIconHREF:self.category.iconHREF];
    self.fExtraInfo.text = [NSString stringWithFormat:@"Updated:\t%@\n",
                                       [MBaseEntity stringFromDate:self.category.updateTime]];
    
    self.fModifyInAllMaps.on = YES;
    self.fModifyInAllMaps.enabled = (self.map!=nil);
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues {

    NSString *catName = [self.fName.text trim];
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
    if(self.category.internalIDValue!=destCat.internalIDValue) {
        destCat.iconHREF = self.catIconHREF;
        MMap *useMap = self.fModifyInAllMaps.on ? nil : self.map;
        [self.category transferTo:destCat inMap:useMap];
        [self.category markAsModified];
        self.category = destCat;
    }
    
    self.category.iconHREF = self.catIconHREF;
    [self.category markAsModified];
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
    
    self.fName.enabled = YES;
    self.fModifyInAllMaps.enabled = YES;
    ((UIGestureRecognizer *)self.fIconImage.gestureRecognizers[0]).enabled = YES;
    ((UIGestureRecognizer *)self.vCategoriesSection.gestureRecognizers[0]).enabled = YES;
    
    // Rota la imagen con el icono para indicar que esditable
    [self _rotateView:self.fIconImage];
    [self _rotateView:self.vCategoriesSection];

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _disableFieldsFromEditing {
    
    self.fName.enabled = NO;
    self.fModifyInAllMaps.enabled = NO;
    ((UIGestureRecognizer *)self.fIconImage.gestureRecognizers[0]).enabled = NO;
    ((UIGestureRecognizer *)self.vCategoriesSection.gestureRecognizers[0]).enabled = NO;
    
}


@end

