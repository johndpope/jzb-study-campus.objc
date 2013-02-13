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
        [self.categoryPathField setStringValue:self.category.iconExtraInfo];

        [self.categoryNameField setStringValue:self.category.name];
        [self.categoryDescrField setString:@""];
        [self.categoryExtraInfo setStringValue:[NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\n",
                                             [MBaseEntity stringFromDate:self.category.published_date],
                                             [MBaseEntity stringFromDate:self.category.updated_date]]];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setEntityFromFieldValues {

    if(self.category) {
        
        // Los cambios en esta entidad son, REALMENTE, CAMBIOS EN LOS PUNTOS ASOCIADOS
        NSString *cleanCatName = [self.categoryPathField.stringValue replaceStr:@"&" with:@"%"];
        MCategory *destCategory = [MCategory categoryForIconBaseHREF:self.iconBaseHREF
                                                           extraInfo:cleanCatName
                                                           inContext:self.category.managedObjectContext];
        
        [self.category movePointsToCategory:destCategory inMap:self.map];
        
        // Marca los puntos y el mapa como modificados
        [self markAsModifiedPointsForCategory:self.category inMap:self.map];
        if(![self.category.objectID isEqual:destCategory.objectID]) {
            [self markAsModifiedPointsForCategory:destCategory inMap:self.map];
        }
        self.map.modifiedSinceLastSyncValue = true;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) markAsModifiedPointsForCategory:(MCategory *)category inMap:(MMap *)map {

    for(MPoint *point in category.points) {
        if([point.map.objectID isEqual:map.objectID]) {
            point.modifiedSinceLastSyncValue = true;
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
// ---------------------------------------------------------------------------------------------------------------------

@end
