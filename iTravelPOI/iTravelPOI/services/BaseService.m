//
//  BaseService.m
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseService-Protected.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation BaseService

@synthesize serviceQueue = _serviceQueue;


//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        NSString *serviceClassName = [[self class] description];
        _serviceQueue = dispatch_queue_create([serviceClassName UTF8String], NULL);
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    dispatch_release(_serviceQueue);
    [super dealloc];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (dispatch_queue_t) serviceQueue {
    return _serviceQueue;
}


@end
