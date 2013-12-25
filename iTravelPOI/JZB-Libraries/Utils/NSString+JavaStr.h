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
@interface NSString (JavaStr)

// Retorna NSNotFound en caso de no encontrar nada
- (NSUInteger) indexOf:(NSString *)str;
- (NSUInteger) indexOf:(NSString *)str startIndex:(NSUInteger)p1;

- (NSUInteger) lastIndexOf:(NSString *)str;
- (NSUInteger) lastIndexOf:(NSString *)str startIndex:(NSUInteger)p1;


- (NSString *) subStrFrom:(NSUInteger)p1;
- (NSString *) subStrFrom:(NSUInteger)p1 to:(NSUInteger)p2;

- (NSString *) replaceStr:(NSString *)str1 with:(NSString *)str2;

- (NSString *) trim;

@end
