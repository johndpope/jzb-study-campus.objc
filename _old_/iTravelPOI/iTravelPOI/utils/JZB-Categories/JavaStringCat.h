//
//  JavaStringCat.h
//  JZBTest
//
//  Created by Snow Leopard User on 16/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface NSString (JavaStringCat)

// Retorna NSNotFound en caso de no encontrar nada
- (NSInteger) indexOf: (NSString *)str;
- (NSInteger) indexOf: (NSString *)str startIndex: (NSUInteger) p1;

- (NSInteger) lastIndexOf: (NSString *)str;
- (NSInteger) lastIndexOf: (NSString *)str startIndex: (NSUInteger) p1;


- (NSString *) subStrFrom: (NSUInteger)p1;
- (NSString *) subStrFrom: (NSUInteger)p1 to:(NSUInteger)p2;

- (NSString *) replaceStr: (NSString *)str1 with:(NSString *)str2;


@end
