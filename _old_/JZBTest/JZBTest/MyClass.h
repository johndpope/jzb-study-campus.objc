//
//  MyClass.h
//  JZBTest
//
//  Created by Snow Leopard User on 12/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyProtocol

- (void) myProtMethod:(int) val;

@end

@interface MyClass : NSObject <MyProtocol>{
    int intValue;
    char charValue;
    
}

@property int intValue;
@property char charValue;

- (void) printValues;
- (void) setBoth_IntVal:(int) n andCharVal:(char) c;
- (void) copyFrom:(MyClass *)other;
+ (void) anotherPrint;


@end



