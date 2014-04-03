//
//  UIViewController+Storyboard.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "UIViewController+Storyboard.h"






//*********************************************************************************************************************
#pragma mark -
#pragma mark UIViewController+Storyboard Category implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation UIViewController (Storyboard)



//---------------------------------------------------------------------------------------------------------------------
+ (UIViewController *) instantiateViewControllerFromStoryboardWithID:(NSString *)vcID {
    
    UIWindow *wnd = UIApplication.sharedApplication.keyWindow;
    UIViewController *rvc = wnd.rootViewController;
    
    if(!rvc) {
        for(UIWindow *wnd in UIApplication.sharedApplication.windows) {
            rvc = wnd.rootViewController;
            if(rvc) break;
        }
    }
    
    UIViewController *vc =  [rvc.storyboard instantiateViewControllerWithIdentifier:vcID];
    return vc;
}



@end
