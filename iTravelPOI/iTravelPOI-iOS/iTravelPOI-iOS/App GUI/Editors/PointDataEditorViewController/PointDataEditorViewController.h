//
//  PointDataEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseKeyboardViewController.h"
#import "MPoint.h"
#import "MMap.h"

@class PointDataEditorViewController;




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
@protocol PointDataEditorViewControllerDelegate<NSObject>

@optional
- (void) pointEdiorSavePoint:(PointDataEditorViewController *)sender;
- (void) pointEdiorCancelPoint:(PointDataEditorViewController *)sender;

@end





//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface PointDataEditorViewController : BaseKeyboardViewController

@property (weak, nonatomic) id<PointDataEditorViewControllerDelegate>   delegate;

@property (strong, nonatomic) MPoint                                *point;




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setTintColor:(UIColor *)tintColor;



@end
