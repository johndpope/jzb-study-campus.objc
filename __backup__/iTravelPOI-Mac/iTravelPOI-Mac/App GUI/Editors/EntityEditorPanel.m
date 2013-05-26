//
// EntityEditorPanel.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __EntityEditorPanel__IMPL__
#import "EntityEditorPanel.h"
#import "IconEditorPanel.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface EntityEditorPanel ()

@property (nonatomic, strong) NSManagedObjectContext *moContext;
@property (nonatomic, strong) EntityEditorPanel *myself;


@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation EntityEditorPanel



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (EntityEditorPanel *) panel:(EntityEditorPanel *)panel startEditingEntity:(MBaseEntity *)entity delegate:(id<EntityEditorPanelDelegate>)delegate {

    if(panel == nil || entity == nil || delegate == nil) {
        return nil;
    }

    if(panel) {
        panel.myself = panel;
        panel.delegate = delegate;
        panel.entity = entity;
        // No se por que se debe crear una referencia fuerte al contexto si la Entity ya lo esta referenciando esta dentro
        panel.moContext = entity.managedObjectContext;

        
        [NSApp beginSheet:panel.window
           modalForWindow:[delegate window]
            modalDelegate:nil
           didEndSelector:nil
              contextInfo:nil];


        return panel;
        
    } else {
        return nil;
    }

}

// =====================================================================================================================
#pragma mark -
#pragma mark Initialization & finalization
// ---------------------------------------------------------------------------------------------------------------------
- (void) windowDidLoad {
    
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self setFieldValuesFromEntity];    
}



// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseSave:(id)sender {

    [self willCloseWithSave:TRUE];
    if(self.delegate && [self.delegate respondsToSelector:@selector(editorPanelSaveChanges:)]) {
        [self setEntityFromFieldValues];
        [self.delegate editorPanelSaveChanges:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseCancel:(id)sender {

    [self willCloseWithSave:FALSE];
    if(self.delegate && [self.delegate respondsToSelector:@selector(editorPanelCancelChanges:)]) {
        [self.delegate editorPanelCancelChanges:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) closePanel {

    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
    self.entity = nil;
    self.moContext = nil;
    self.delegate = nil;
    self.myself = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willCloseWithSave:(BOOL)saving {
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setFieldValuesFromEntity {

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setEntityFromFieldValues {

}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------

@end
