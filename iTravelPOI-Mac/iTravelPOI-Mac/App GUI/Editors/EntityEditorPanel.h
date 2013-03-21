//
// EntityEditorPanel.h
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBaseEntity.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark <EntityEditorPanelDelegate> Protocol
// *********************************************************************************************************************
@class EntityEditorPanel;
@protocol EntityEditorPanelDelegate <NSObject>

- (NSWindow *) window;

@optional
- (void) editorPanelSaveChanges:(EntityEditorPanel *)sender;
- (void) editorPanelCancelChanges:(EntityEditorPanel *)sender;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface EntityEditorPanel : NSWindowController

@property (nonatomic, weak) id<EntityEditorPanelDelegate> delegate;
@property (nonatomic, strong) MBaseEntity *entity;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __EntityEditorPanel__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#else
+ (EntityEditorPanel *) panel:(EntityEditorPanel *)panel startEditingEntity:(MBaseEntity *)entity delegate:(id<EntityEditorPanelDelegate>)delegate;
- (void) closePanel;
- (void) willCloseWithSave:(BOOL)saving;
#endif



// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------


@end

