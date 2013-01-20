//
//  GroupEditWindowController.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 31/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class MGroup;



//*********************************************************************************************************************
#pragma mark -
#pragma mark GroupEditorDelegate Public protocol definition
//---------------------------------------------------------------------------------------------------------------------
@protocol GroupEditorDelegate <NSObject>

@required
- (void) endSaving:(MGroup *)group sender:(id)sender;
- (void) endCanceling:(MGroup *)group sender:(id)sender;

@end





//*********************************************************************************************************************
#pragma mark -
#pragma mark GroupEditWindowController interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GroupEditWindowController : NSWindowController <NSWindowDelegate>


@property (nonatomic, assign) id<GroupEditorDelegate> delegate;
@property (nonatomic, strong) MGroup *group;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------


@end
