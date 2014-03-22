//
//  TopViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 03/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface TopViewController : UIViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (void) addChildViewController:(UIViewController *)childController;
+ (void) removeChildViewController:(UIViewController *)childController;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------

@end
