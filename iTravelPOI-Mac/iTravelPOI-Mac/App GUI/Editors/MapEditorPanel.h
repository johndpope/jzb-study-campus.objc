//
//  MapEditorPanel.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 13/01/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMap.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
//*********************************************************************************************************************


//*********************************************************************************************************************
#pragma mark -
#pragma mark <MapEditorPanelDelegate> Protocol
//*********************************************************************************************************************
@class MapEditorPanel;
@protocol MapEditorPanelDelegate <NSObject>

- (void) mapPanelSaveChanges:(MapEditorPanel *)sender;
- (void) mapPanelCancelChanges:(MapEditorPanel *)sender;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
//*********************************************************************************************************************
@interface MapEditorPanel : NSWindowController

@property (weak) id<MapEditorPanelDelegate> delegate;
@property (strong) MMap *map;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
#ifndef __MapEditorPanel__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (MapEditorPanel *) startEditMap:(MMap *)map delegate:(id<MapEditorPanelDelegate>) delegate;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------


@end

