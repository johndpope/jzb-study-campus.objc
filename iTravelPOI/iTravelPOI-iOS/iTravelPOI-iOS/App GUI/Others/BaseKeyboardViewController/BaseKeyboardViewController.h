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

@property (weak, nonatomic)                 IBOutlet    UIView              *kbContentView;
@property (weak, nonatomic)                 IBOutlet    NSLayoutConstraint  *kbContentVTrailing;

@property (nonatomic, assign, readonly)     BOOL                            isKeyboardVisible;
@property (nonatomic, assign, readonly)     CGRect                          keyboardRect;


- (CGSize) calcNewKeyboardContentViewSize:(UIView *)aView kbRect:(CGRect)kbRect;

- (void) keyboardWillShow;
- (void) keyboardDidShow;
- (void) keyboardWillHide;
- (void) keyboardDidHide;

@end
