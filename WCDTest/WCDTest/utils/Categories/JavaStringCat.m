//
//  JavaStringCat.m
//  JZBTest
//
//  Created by Snow Leopard User on 16/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JavaStringCat.h"


@implementation NSString (JavaStringCat)


//****************************************************************************
- (NSUInteger) indexOf: (NSString *)str {
    NSRange r = [self rangeOfString:str options:0];
    if(r.length>0) 
        return r.location;
    else
        return -1;
}

//****************************************************************************
- (NSUInteger) indexOf: (NSString *)str startIndex: (NSUInteger) p1 {
    NSRange r = [self rangeOfString:str options:0 range: (NSRange){p1, [self length]-p1}];
    if(r.length>0) 
        return r.location;
    else
        return -1;
}

//****************************************************************************
- (NSUInteger) lastIndexOf: (NSString *)str {
    NSRange r = [self rangeOfString:str options:NSBackwardsSearch];
    if(r.length>0) 
        return r.location;
    else
        return -1;
}

//****************************************************************************
- (NSUInteger) lastIndexOf: (NSString *)str startIndex: (NSUInteger) p1 {
    return [self rangeOfString:str options:NSBackwardsSearch range: (NSRange){p1, [self length]-p1}].location;
}

//****************************************************************************
- (NSString *) subStrFrom: (NSUInteger)p1 {
    return [self substringWithRange: (NSRange){p1, [self length]-p1}];
}

//****************************************************************************
- (NSString *) subStrFrom: (NSUInteger)p1 To:(NSUInteger)p2 {
    return [self substringWithRange: (NSRange){p1, p2-p1}];
}

//****************************************************************************
- (NSString *) replaceStr: (NSString *)str1 With:(NSString *)str2 {
    
    NSMutableString *ms = [NSMutableString stringWithString:self];
    [ms replaceOccurrencesOfString: str1 withString: str2 options:0 range: (NSRange){0,[ms length]}];
    return [[ms copy] autorelease];
}


@end
