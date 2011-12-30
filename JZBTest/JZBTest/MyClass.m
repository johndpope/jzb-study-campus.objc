//
//  MyClass.m
//  JZBTest
//
//  Created by Snow Leopard User on 12/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyClass.h"


@implementation MyClass

@synthesize intValue;
@synthesize charValue;

static int pepe = 12;

- (void) myProtMethod:(int)val {
    intValue = val;   
}

+ (void) anotherPrint {
    NSLog(@"int pepe = %i", pepe);    
}

- (void) printValues {
    NSLog(@"int value = %i, char value = %c", intValue, charValue);
   
}

- (void) setBoth_IntVal:(int) n andCharVal:(char) c; {
    intValue = n;
    charValue = c;
    [self printValues];
}

- (void) copyFrom:(MyClass *)other {
    intValue = other.intValue;
    charValue = other.charValue;
}

@end

