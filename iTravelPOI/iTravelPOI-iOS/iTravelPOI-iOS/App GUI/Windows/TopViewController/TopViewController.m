//
//  TopViewController.m
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TopViewController__IMPL__
#import "TopViewController.h"
#import "UINavigationPopProtocol.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
static TopViewController *_instance;


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TopViewController () <UINavigationControllerDelegate>


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TopViewController





//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (void) addChildViewController:(UIViewController *)childController {
    
    [childController willMoveToParentViewController:_instance];
    [_instance addChildViewController:childController];
    [_instance.view addSubview:childController.view];
    childController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    childController.view.frame = _instance.view.bounds;
    [childController didMoveToParentViewController:_instance];
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) removeChildViewController:(UIViewController *)childController {
    
    [childController willMoveToParentViewController:nil];
    [childController removeFromParentViewController];
    [childController.view removeFromSuperview];
    [childController didMoveToParentViewController:nil];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Recuerda esta instancia como una propiedad de clase
    _instance = self;

    // Crea el root ViewController
    [self performSegueWithIdentifier:@"rootVC" sender:self];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"rootVC"]) {
        
        if([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {

            UINavigationController *navCtlr = (UINavigationController *)segue.destinationViewController;
            navCtlr.delegate = self;
        }
    }
    
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UINavigationControllerDelegate> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    
    if(operation==UINavigationControllerOperationPop && [toVC conformsToProtocol:@protocol(UINavigationPopProtocol)]) {
        [toVC performSelector:@selector(poppedFromVC:) withObject:fromVC];
    }
    
    return nil;
}

//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------



@end
