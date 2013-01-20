//
//  MapEditorPanel.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 13/01/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __MapEditorPanel__IMPL__
#import "MapEditorPanel.h"
#import "GMTItem.h"

#import "PointEditorPanel.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
//*********************************************************************************************************************


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MapEditorPanel () <NSTextFieldDelegate, NSTextViewDelegate>


@property (nonatomic, assign) IBOutlet NSTextField *mapNameField;
@property (nonatomic, assign) IBOutlet NSTextView *mapSummaryField;
@property (nonatomic, assign) IBOutlet NSTextField *mapExtraInfo;


@property (nonatomic, strong) NSManagedObjectContext *mapContext;

@property (nonatomic, strong) MapEditorPanel *myself;

@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MapEditorPanel




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MapEditorPanel *) startEditMap:(MMap *)map delegate:(id<MapEditorPanelDelegate>) delegate {

    if(map==nil || delegate==nil) {
        return nil;
    }
    
    MapEditorPanel *me = [[MapEditorPanel alloc] init];
    
    BOOL allOK = [NSBundle loadNibNamed:@"MapEditorPanel" owner:me];

    if(allOK) {
        me.myself = me;
        me.delegate = delegate;
        me.map = map;
        // No se por que se debe crear una referencia fuerte al contexto si el mapa esta dentro
        me.mapContext = map.managedObjectContext;
        [me setFieldValuesFromMap];
    
        [NSApp beginSheet:me.window
           modalForWindow:[[NSApp delegate] window]
            modalDelegate:nil
           didEndSelector:nil
              contextInfo:nil];
        
        return me;
    } else {
        return nil;
    }
    
}



//=====================================================================================================================
#pragma mark -
#pragma mark Initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

    
}




//=====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------


//=====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseSave:(id)sender {

    if(self.delegate) {
        [self setMapFromFieldValues];
        [self.delegate mapPanelSaveChanges:self];
    }
    [self closePanel];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseCancel:(id)sender {

    if(self.delegate) {
        [self.delegate mapPanelCancelChanges:self];
    }
    [self closePanel];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) closePanel {
    
    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
    self.map = nil;
    self.mapContext = nil;
    self.delegate = nil;
    self.myself = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setFieldValuesFromMap {
    
    if(self.map) {
        [self.mapNameField setStringValue:self.map.name];
        [self.mapSummaryField setString:self.map.summary];
        [self.mapExtraInfo setStringValue:[NSString stringWithFormat:@"Published: %@\tUpdated: %@\nETAG: %@",
                                          [GMTItem stringFromDate:self.map.published_Date],
                                          [GMTItem stringFromDate:self.map.updated_Date],
                                          self.map.etag]];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setMapFromFieldValues {
    
    if(self.map) {
        // *** CONTROL DE SEGURIDAD (@name) PARA NO TOCAR MAPAS BUENOS ***
        NSString *name = self.mapNameField.stringValue;
        if([name hasPrefix:@"@"]) {
        self.map.name = name;
        } else {
            self.map.name = [NSString stringWithFormat:@"@%@",name];
        }
        self.map.summary = [self.mapSummaryField string];
        self.map.updated_Date = [NSDate date];
        
        // importante indicar que se ha modificado
        self.map.modifiedSinceLastSyncValue = true;
    }
}


//=====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------

@end
