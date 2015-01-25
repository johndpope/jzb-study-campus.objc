//
// NSError+SimpleInit.h
// JZBTest
//
// Created by Snow Leopard User on 16/10/11.
// Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************
#ifndef NSErrorRef
    #define NSErrorRef NSError * __autoreleasing
#endif


// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface NSError (SimpleInit)

+ (NSError *) errorWithDomain:(NSString *)domain reason:(NSString *)reason,...;
+ (NSError *) errorWithDomain:(NSString *)domain code:(NSInteger)code reason:(NSString *)reason,...;

+ (void) setErrorRef:(NSErrorRef *)errRef domain:(NSString *)domain reason:(NSString *)reason,...;
+ (void) setErrorRef:(NSErrorRef *)errRef domain:(NSString *)domain code:(NSInteger)code reason:(NSString *)reason,...;

+ (void) nilErrorRef:(NSErrorRef *)errRef;

@end
