//
//  UIPlaceHolderTextView.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 08/06/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>

//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, copy) NSString *placeholderText;
@property (nonatomic, retain) UIColor *placeholderColor;

@end