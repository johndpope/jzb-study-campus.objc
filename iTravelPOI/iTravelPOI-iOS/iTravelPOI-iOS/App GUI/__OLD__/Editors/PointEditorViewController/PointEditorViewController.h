//
//  PointEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseKeyboardViewController.h"
#import "MPoint.h"
#import "MMap.h"

@class PointEditorViewController;




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
@protocol PointEditorViewControllerDelegate<NSObject>

@optional
- (void) pointEdiorSavePoint:(PointEditorViewController *)sender;
- (void) pointEdiorCancelPoint:(PointEditorViewController *)sender;

@end





//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface PointEditorViewController : BaseKeyboardViewController

@property (weak, nonatomic) id<PointEditorViewControllerDelegate>   delegate;

@property (strong, nonatomic) MPoint                                *point;




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------



@end
