//
// CategoryEditorPanel.h
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCategory.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark <CategoryEditorPanelDelegate> Protocol
// *********************************************************************************************************************
@class CategoryEditorPanel;
@protocol CategoryEditorPanelDelegate <NSObject>

- (NSWindow *) window;
- (void) categoryPanelSaveChanges:(CategoryEditorPanel *)sender;
- (void) categoryPanelCancelChanges:(CategoryEditorPanel *)sender;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface CategoryEditorPanel : NSWindowController

@property (weak) id<CategoryEditorPanelDelegate> delegate;
@property (strong) MCategory *category;
@property (strong) MMap *map;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __CategoryEditorPanel__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (CategoryEditorPanel *) startEditCategory:(MCategory *)category inMap:(MMap *)map delegate:(id<CategoryEditorPanelDelegate>)delegate;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------


@end

