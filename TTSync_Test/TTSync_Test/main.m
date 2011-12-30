//
//  main.m
//  TTSync_Test
//
//  Created by jzarzuela on 23/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
    NSLog(@"Calling different tests...");

    TT_Main_test();
    
    [pool drain];
    return 0;
}

