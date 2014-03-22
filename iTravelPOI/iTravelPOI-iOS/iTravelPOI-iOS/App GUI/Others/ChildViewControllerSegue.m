//
//  ChildViewControllerSegue.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#define __ChildViewControllerSegue__IMPL__
#import "ChildViewControllerSegue.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface ChildViewControllerSegue()


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation ChildViewControllerSegue




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (void) unwindSegueForChildViewController:(UIViewController *)childController {
    
    [childController willMoveToParentViewController:nil];
    [childController removeFromParentViewController];
    [childController.view removeFromSuperview];
    [childController didMoveToParentViewController:nil];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination {

    id me  = [super initWithIdentifier:identifier source:source destination:destination];
    return me;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)perform {
    
    UIViewController *parentVC = (UIViewController *)self.sourceViewController;
    UIViewController *childVC = (UIViewController *)self.destinationViewController;
    
    [childVC willMoveToParentViewController:parentVC];
    [parentVC addChildViewController:childVC];
    [parentVC.view addSubview:childVC.view];
    childVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    childVC.view.frame = parentVC.view.bounds;
    [childVC didMoveToParentViewController:parentVC];
}

//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------



@end

