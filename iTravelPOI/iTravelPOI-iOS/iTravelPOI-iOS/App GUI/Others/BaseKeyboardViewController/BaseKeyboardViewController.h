//
//  BaseKeyboardViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 03/01/14.
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
@interface BaseKeyboardViewController : UIViewController

@property (weak, nonatomic)                 IBOutlet    NSLayoutConstraint  *kbContentVTrailing;

@property (assign, readonly, nonatomic)     BOOL                            isKeyboardVisible;
@property (assign, readonly, nonatomic)     CGRect                          keyboardRect;


- (void) keyboardWillShow;
- (void) keyboardDidShow;
- (void) keyboardWillHide;
- (void) keyboardDidHide;

@end
