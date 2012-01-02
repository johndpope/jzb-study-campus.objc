//
//  Category.m
//  TTSync_Test
//
//  Created by jzarzuela on 02/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Category.h"


@implementation Category


@synthesize name, desc, icon, pois;


//****************************************************************************
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        name = @"";
        desc = @"";
        icon = nil;
        pois = [[NSArray alloc] init];
    }
    
    return self;
}

//****************************************************************************
- (void)dealloc
{
    [name autorelease];
    [desc autorelease];
    [icon autorelease];
    [pois autorelease];
    [super dealloc];
}

@end
