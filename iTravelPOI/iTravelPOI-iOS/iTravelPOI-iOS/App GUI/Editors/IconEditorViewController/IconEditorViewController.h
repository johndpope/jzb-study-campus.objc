//
//  IconEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIcon.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
@class IconEditorViewController;
@protocol IconEditorViewControllerDelegate<NSObject>

@optional
- (void) iconEditorDone:(IconEditorViewController *)sender;

@end





//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface IconEditorViewController : UIViewController

@property (weak, nonatomic)     id<IconEditorViewControllerDelegate> delegate;
@property (strong, nonatomic)   MIcon *icon;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------


@end
