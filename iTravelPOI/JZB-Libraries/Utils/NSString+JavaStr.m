//
// JavaStringCat.m
// JZBTest
//
// Created by Snow Leopard User on 16/10/11.
// Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+JavaStr.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation NSString (JavaStr)



// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
// Devuelve NSNotFound si no se encontro
- (NSUInteger) indexOf:(NSString *)str {
    return [self rangeOfString:str options:0].location;
}

// ---------------------------------------------------------------------------------------------------------------------
// Devuelve NSNotFound si no se encontro
- (NSUInteger) indexOf:(NSString *)str startIndex:(NSUInteger)p1 {
    return [self rangeOfString:str options:0 range:(NSRange){p1, [self length] - p1}].location;
}

// ---------------------------------------------------------------------------------------------------------------------
// Devuelve NSNotFound si no se encontro
- (NSUInteger) lastIndexOf:(NSString *)str {
    return [self rangeOfString:str options:NSBackwardsSearch].location;
}

// ---------------------------------------------------------------------------------------------------------------------
// Devuelve NSNotFound si no se encontro
- (NSUInteger) lastIndexOf:(NSString *)str startIndex:(NSUInteger)p1 {
    return [self rangeOfString:str options:NSBackwardsSearch range:(NSRange){p1, [self length] - p1}].location;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) subStrFrom:(NSUInteger)p1 {
    return [self substringWithRange:(NSRange){p1, [self length] - p1}];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) subStrFrom:(NSUInteger)p1 to:(NSUInteger)p2 {
    return [self substringWithRange:(NSRange){p1, p2 - p1}];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) replaceStr:(NSString *)str1 with:(NSString *)str2 {

    NSMutableString *ms = [NSMutableString stringWithString:self];
    [ms replaceOccurrencesOfString:str1 withString:str2 options:0 range:(NSRange){0, [ms length]}];
    return [ms copy];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) trim {

    NSString *trimmed = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [trimmed copy];
}

@end
