//
// MapEditorPanel.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __EntityEditorPanel__IMPL__
#define __MapEditorPanel__IMPL__
#import "MapEditorPanel.h"
#import "GMTItem.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface MapEditorPanel () <NSTextFieldDelegate, NSTextViewDelegate>

@property (nonatomic, assign) IBOutlet NSTextField *mapNameField;
@property (nonatomic, assign) IBOutlet NSTextView *mapSummaryField;
@property (nonatomic, assign) IBOutlet NSTextField *mapExtraInfo;

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation MapEditorPanel



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MapEditorPanel *) startEditMap:(MMap *)map delegate:(id<EntityEditorPanelDelegate>)delegate {

    MapEditorPanel *me = [[MapEditorPanel alloc] initWithWindowNibName:@"MapEditorPanel"];
    return (MapEditorPanel *)[EntityEditorPanel panel:me startEditingEntity:map delegate:delegate];
}

// =====================================================================================================================
#pragma mark -
#pragma mark Initialization & finalization
// ---------------------------------------------------------------------------------------------------------------------



// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (MMap *) map {
    return (MMap *)self.entity;
}



// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) setFieldValuesFromEntity {

    if(self.map) {
        [self.mapNameField setStringValue:self.map.name];
        [self.mapSummaryField setString:self.map.summary];
        [self.mapExtraInfo setStringValue:[NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\nETAG:\t%@",
                                           [GMTItem stringFromDate:self.map.published_date],
                                           [GMTItem stringFromDate:self.map.updated_date],
                                           self.map.etag]];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setEntityFromFieldValues {

    if(self.map) {
        // *** CONTROL DE SEGURIDAD (@name) PARA NO TOCAR MAPAS BUENOS ***
        NSString *name = self.mapNameField.stringValue;
        if([name hasPrefix:@"@"]) {
            self.map.name = name;
        } else {
            self.map.name = [NSString stringWithFormat:@"@%@", name];
        }
        self.map.summary = [self.mapSummaryField string];
        self.map.updated_date = [NSDate date];
        self.map.modifiedSinceLastSyncValue = true;
    }
    
}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------

@end
