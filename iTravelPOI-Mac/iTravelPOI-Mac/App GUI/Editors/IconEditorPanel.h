//
// IconEditorPanel.h
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMap.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark <IconEditorPanelDelegate> Protocol
// *********************************************************************************************************************
@class IconEditorPanel;
@protocol IconEditorPanelDelegate <NSObject>

- (NSWindow *) window;
- (void) iconPanelSaveChanges:(IconEditorPanel *)sender;
- (void) iconPanelCancelChanges:(IconEditorPanel *)sender;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface IconEditorPanel : NSWindowController

@property (weak) id<IconEditorPanelDelegate> delegate;
@property (strong) NSString *iconHREF;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __IconEditorPanel__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (IconEditorPanel *) startEditIconHREF:(NSString *)iconHREF delegate:(id<IconEditorPanelDelegate>)delegate;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------


@end

