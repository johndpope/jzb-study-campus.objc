//
// JavaStringCat.m
// JZBTest
//
// Created by Snow Leopard User on 16/10/11.
// Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Tint.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation UIImage (Tint)



// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
+ (UIImage *)imageNamed:(NSString *)name burnTint:(UIColor *)color {
    return [[UIImage imageNamed:name] burnTint:color];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (UIImage *)imageNamed:(NSString *)name burnTintRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha {
    return [[UIImage imageNamed:name] burnTintRed:red green:green blue:blue alpha:alpha];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (UIImage *)imageNamed:(NSString *)name burnTintRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha
             brightnessInc:(CGFloat)brightnessInc {
    
    CGFloat fred = MAX(MIN(brightnessInc+red/255.0,1.0), 0.0);
    CGFloat fgreen = MAX(MIN(brightnessInc+green/255.0,1.0), 0.0);
    CGFloat fblue = MAX(MIN(brightnessInc+blue/255.0,1.0), 0.0);
    
    return [UIImage imageNamed:name burnTint:[UIColor colorWithRed:fred green:fgreen blue:fblue alpha:alpha]];
}


// ---------------------------------------------------------------------------------------------------------------------
- (UIImage *)burnTint:(UIColor *)color
{
    // Si no hay color no hay cambios
    if(!color) return self;
    
    // lets tint the icon - assumes your icons are black
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, self.CGImage);
    
    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (UIImage *)burnTintRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha {
    
    return [self burnTint:[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha]];
}


// ---------------------------------------------------------------------------------------------------------------------
- (UIImage *)scaledToSize:(CGSize)newSize {
    
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// ---------------------------------------------------------------------------------------------------------------------
- (UIImage *)scaledToSize:(CGSize)newSize centerInSize:(CGSize)containerSize {
    
    newSize.width = MIN(containerSize.width, newSize.width);
    newSize.height = MIN(containerSize.height, newSize.height);
    
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(containerSize, NO, 0.0);
    
    [self drawInRect:CGRectMake((containerSize.width-newSize.width)/2, (containerSize.height-newSize.height)/2, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// ---------------------------------------------------------------------------------------------------------------------
- (UIImage *)scaledToSize:(CGSize)newSize offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY
               containerW:(CGFloat)containerW containerH:(CGFloat)containerH {
    
    containerW = MAX(containerW, newSize.width);
    containerH = MAX(containerH, newSize.height);
    
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions((CGSize){containerW, containerH}, NO, 0.0);
    
    [self drawInRect:CGRectMake(offsetX, offsetY, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation UIColor (Tint)

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
+ (UIColor *) colorWithIntRed:(NSUInteger)red intGreen:(NSUInteger)green intBlue:(NSUInteger)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

// ---------------------------------------------------------------------------------------------------------------------
- (UIColor *)incrementBrightness:(CGFloat)brightnessInc {
    
    CGFloat old_red, old_green, old_blue, old_alpha;
    
    [self getRed:&old_red green:&old_green blue:&old_blue alpha:&old_alpha];
    
    CGFloat new_red = MAX(MIN(brightnessInc+old_red,1.0), 0.0);
    CGFloat new_green = MAX(MIN(brightnessInc+old_green,1.0), 0.0);
    CGFloat new_blue = MAX(MIN(brightnessInc+old_blue,1.0), 0.0);
    
    return [UIColor colorWithRed:new_red green:new_green blue:new_blue alpha:old_alpha];

}


@end
