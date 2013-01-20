//
//  PointEditorPanel.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 13/01/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMap.h"
#import "MPoint.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
//*********************************************************************************************************************


//*********************************************************************************************************************
#pragma mark -
#pragma mark <PointEditorPanelDelegate> Protocol
//*********************************************************************************************************************
@class PointEditorPanel;
@protocol PointEditorPanelDelegate <NSObject>

- (void) pointPanelSaveChanges:(PointEditorPanel *)sender;
- (void) pointPanelCancelChanges:(PointEditorPanel *)sender;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
//*********************************************************************************************************************
@interface PointEditorPanel : NSWindowController

@property (weak) id<PointEditorPanelDelegate> delegate;
@property (strong) MPoint *point;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
#ifndef __PointEditorPanel__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (PointEditorPanel *) startEditPoint:(MPoint *)Point delegate:(id<PointEditorPanelDelegate>) delegate;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------


@end

