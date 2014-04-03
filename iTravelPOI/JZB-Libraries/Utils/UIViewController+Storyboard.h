//
//  UIViewController+Storyboard.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark UIViewController+Storyboard Category definition
//---------------------------------------------------------------------------------------------------------------------
@interface UIViewController (Storyboard)

+ (UIViewController *) instantiateViewControllerFromStoryboardWithID:(NSString *)vcID;

@end
