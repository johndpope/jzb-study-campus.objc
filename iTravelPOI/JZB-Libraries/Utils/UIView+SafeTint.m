//
//  UIView+SafeTint.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+SafeTint.h"



static char kProperty_iOS6TintColor;



//*********************************************************************************************************************
#pragma mark -
#pragma mark UIView_SafeTint Category implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation UIView (SafeTint)

@dynamic iOS6TintColor;


//---------------------------------------------------------------------------------------------------------------------
- (UIColor *) iOS6TintColor {
    
    if([self respondsToSelector:@selector(tintColor)]) {
        return [self tintColor];
    } else {
        UIColor *color = (UIColor *)objc_getAssociatedObject(self, &kProperty_iOS6TintColor);
        return color;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setIOS6TintColor:(UIColor *)color {
    
    if([self respondsToSelector:@selector(setTintColor:)]) {
        self.tintColor = color;
    } else {
        objc_setAssociatedObject(self, &kProperty_iOS6TintColor, color, OBJC_ASSOCIATION_RETAIN);
    }
}


@end
