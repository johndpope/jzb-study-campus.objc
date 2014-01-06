//
// JavaStringCat.h
// JZBTest
//
// Created by Snow Leopard User on 16/10/11.
// Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface UIImage (Tint)

+ (UIImage *)imageNamed:(NSString *)name burnTint:(UIColor *)color;
+ (UIImage *)imageNamed:(NSString *)name burnTintRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha;
+ (UIImage *)imageNamed:(NSString *)name burnTintRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha
             brightnessInc:(CGFloat)brightnessInc;

- (UIImage *)burnTint:(UIColor *)color;
- (UIImage *)burnTintRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha;

- (UIImage *)scaledToSize:(CGSize)newSize;
- (UIImage *)scaledToSize:(CGSize)newSize centerInSize:(CGSize)containerSize;
- (UIImage *)scaledToSize:(CGSize)newSize offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY containerW:(CGFloat)containerW containerH:(CGFloat)containerH;


@end

@interface UIColor (Tint)

+ (UIColor *)colorWithIntRed:(NSUInteger)red intGreen:(NSUInteger)green intBlue:(NSUInteger)blue alpha:(CGFloat)alpha;
- (UIColor *)incrementBrightness:(CGFloat)brightnessInc;

@end
