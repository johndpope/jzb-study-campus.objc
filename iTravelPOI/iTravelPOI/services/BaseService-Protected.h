//
//  BaseService-Protected.h
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark BaseService PROTECTED methods definition
//---------------------------------------------------------------------------------------------------------------------
@interface BaseService()

@property (nonatomic, assign, readonly) dispatch_queue_t serviceQueue;

@end
