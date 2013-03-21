//
// GMapPointEditorPanel.h
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyMKPointAnnotation.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark <GMapPointEditorPanelDelegate> Protocol
// *********************************************************************************************************************
@class GMapPointEditorPanel;
@protocol GMapPointEditorPanelDelegate <NSObject>

- (NSWindow *) window;

@optional
- (void) editorPanelSaveChanges:(GMapPointEditorPanel *)sender;
- (void) editorPanelCancelChanges:(GMapPointEditorPanel *)sender;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMapPointEditorPanel : NSWindowController

@property (nonatomic, weak) id<GMapPointEditorPanelDelegate> delegate;
@property (nonatomic, strong) NSArray *annotations;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMapPointEditorPanel__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GMapPointEditorPanel *) startGMapPointEditor:(NSArray *)annotations delegate:(id<GMapPointEditorPanelDelegate>)delegate;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------


@end

