//
// CategoryEditorPanel.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __EntityEditorPanel__IMPL__
#define __CategoryEditorPanel__IMPL__
#import <QuartzCore/QuartzCore.h>
#import "CategoryEditorPanel.h"
#import "MCategory.h"
#import "ImageManager.h"
#import "IconEditorPanel.h"
#import "MPoint.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface CategoryEditorPanel () <IconEditorPanelDelegate, NSTextFieldDelegate, NSTextViewDelegate>


@property (nonatomic, assign) IBOutlet NSButton *iconImageBtnField;
@property (nonatomic, assign) IBOutlet NSTextField *categoryNameField;
@property (nonatomic, assign) IBOutlet NSTextField *categoryPathField;
@property (nonatomic, assign) IBOutlet NSTextView *categoryDescrField;
@property (nonatomic, assign) IBOutlet NSTextField *categoryExtraInfo;

@property (nonatomic, strong) NSString *iconBaseHREF;

@property (nonatomic, strong) MMap *map;


@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation CategoryEditorPanel


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (CategoryEditorPanel *) startEditCategory:(MCategory *)category inMap:(MMap *)map delegate:(id<EntityEditorPanelDelegate>)delegate {

    CategoryEditorPanel *me = [[CategoryEditorPanel alloc] initWithWindowNibName:@"CategoryEditorPanel"];
    me.map = map;
    return (CategoryEditorPanel *)[EntityEditorPanel panel:me startEditingEntity:category delegate:delegate];
}

// =====================================================================================================================
#pragma mark -
#pragma mark Initialization & finalization
// ---------------------------------------------------------------------------------------------------------------------



// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (MCategory *) category {
    return (MCategory *)self.entity;
}


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) iconImageBtnClicked:(id)sender {
    [IconEditorPanel startEditIconBaseHREF:self.iconBaseHREF delegate:self];
}



// ---------------------------------------------------------------------------------------------------------------------
- (void) closePanel {

    self.map = nil;
    [super closePanel];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void) setImageFieldFromHREF:(NSString *)iconHREF {
    IconData *icon = [ImageManager iconDataForHREF:iconHREF];
    self.iconImageBtnField.image = icon.image;
    [self.iconImageBtnField setImagePosition:NSImageOnly];
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat:-2*M_PI];
    rotate.duration = 1.0;
    rotate.repeatCount = 1;
    [self.iconImageBtnField.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [self.iconImageBtnField.layer addAnimation:rotate forKey:@"trans_rotation"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setFieldValuesFromEntity {

    if(self.category) {
        [self setImageFieldFromHREF:self.category.iconBaseHREF];
        self.iconBaseHREF = self.category.iconBaseHREF;
        [self.categoryPathField setStringValue:self.category.fullName];

        [self.categoryNameField setStringValue:self.category.name];
        [self.categoryDescrField setString:@""];
        [self.categoryExtraInfo setStringValue:[NSString stringWithFormat:@"Updated:\t%@\n",
                                              [MMapBaseEntity stringFromDate:self.category.updated_date]]];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setEntityFromFieldValues {

    if(self.category) {
        
        // Los cambios en esta entidad son, REALMENTE, CAMBIOS EN LOS PUNTOS ASOCIADOS
        NSString *cleanCatFullName = [self.categoryPathField.stringValue replaceStr:@"&" with:@"%"];
        MCategory *destCategory = [MCategory categoryForIconBaseHREF:self.iconBaseHREF
                                                            fullName:cleanCatFullName
                                                           inContext:self.category.managedObjectContext];

        // Si hubo cambios relevantes actualiza los puntos impactados
        if(![self.category.objectID isEqual:destCategory.objectID]) {
            [self _movePointsFromCategory:self.category toCategory:destCategory inMap:self.map];
        }
    }
}


// =====================================================================================================================
#pragma mark -
#pragma mark <IconEditorPanelDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) iconPanelClose:(IconEditorPanel *)sender {
    [self setImageFieldFromHREF:sender.baseHREF];
    self.iconBaseHREF = sender.baseHREF;
}

     
     
// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _movePointsFromCategory:(MCategory *)origCategory toCategory:(MCategory *)destCategory inMap:(MMap *)map {
    
    // Comprueba si se quiere mover a otra categoria diferente
    if([origCategory.objectID isEqual:destCategory.objectID]) return;
    
    // Longitud del nombre base
    NSUInteger baseFullNameLength = origCategory.fullName.length;
    
    // Recopila todas las subcateforias
    // Se hace asi por si se moviese "hacia abajo". Lo que podría hacer un bucle infinito
    NSMutableArray *allSubCats = [NSMutableArray array];
    [self _allSubcategoriesFor:origCategory allSubCats:allSubCats];
    
    // Cambia todos los puntos de cada categoria a la nueva categoria equivalente
    // Si se indica un mapa, se restringiran los puntos a los de ese mapa
    // Se están moviendo incluso los puntos borrados
    for(MCategory *cat in allSubCats) {
        
        // Caso especial en el que se mueve "hacia abajo"
        if([cat.objectID isEqual:destCategory.objectID]) continue;
        
        
        NSString *newFullName = [NSString stringWithFormat:@"%@%@", destCategory.fullName, [cat.fullName subStrFrom:baseFullNameLength]];
        
        MCategory *newSubCategory = [MCategory categoryForIconBaseHREF:destCategory.iconBaseHREF
                                                              fullName:newFullName
                                                             inContext:destCategory.managedObjectContext];
        
        NSArray *allPoints = [NSArray arrayWithArray:cat.points.allObjects];
        for(MPoint *point in allPoints) {
            if(map==nil || [point.map.objectID isEqual:map.objectID]) {
                [point moveToCategory:newSubCategory];
                [point updateModifiedMark];
                [point.map updateModifiedMark];
            }
        }
    }
    
    // Marca la hora de actualizacion de ambas categorias
    origCategory.updated_date = [NSDate date];
    destCategory.updated_date = [NSDate date];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _allSubcategoriesFor:(MCategory *)cat allSubCats:(NSMutableArray *)allSubCats {

    [allSubCats addObject:cat];
    for(MCategory *subCat in cat.subCategories) {
        [self _allSubcategoriesFor:subCat allSubCats:allSubCats];
    }
}


@end
