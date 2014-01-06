//
//  UIView+FirstResponder.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark UIView_FirstResponder Category definition
//---------------------------------------------------------------------------------------------------------------------
@interface UIView (FirstResponder)

- (UIView *) findFirstResponder;
- (BOOL) findFirstResponderAndResign;
- (BOOL) resignAnyResponder;


@end
