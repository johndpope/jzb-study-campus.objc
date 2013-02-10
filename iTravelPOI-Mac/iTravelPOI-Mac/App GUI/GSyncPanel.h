//
// GSyncPanel.h
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Cocoa/Cocoa.h>



// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark <GSyncPanelDelegate> Protocol
// *********************************************************************************************************************
@class GSyncPanel;
@protocol GSyncPanelDelegate <NSObject>

- (NSWindow *) window;

@optional
- (void) gsyncPanelClose:(GSyncPanel *)sender;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GSyncPanel : NSWindowController

@property (nonatomic,weak) id<GSyncPanelDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext *moContext;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GSyncPanel__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GSyncPanel *) startSyncWithMOContext:(NSManagedObjectContext *)moContext delegate:(id<GSyncPanelDelegate>)delegate;




// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------


@end

