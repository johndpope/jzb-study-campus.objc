//
//  DelegateMapCompare.m
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DelegateMapCompare.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation DelegateMapCompare


@synthesize  compItems = _compItems;


//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        self.compItems = [NSMutableArray array];
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_compItems release];
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) processTuple:(MECompareTuple *) tuple {

    [self.compItems addObject:tuple];
}


@end
