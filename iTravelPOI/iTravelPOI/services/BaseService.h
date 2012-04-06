//
//  BaseService.h
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
//---------------------------------------------------------------------------------------------------------------------
#define SRVC_ASYNCHRONOUS void



//*********************************************************************************************************************
#pragma mark -
#pragma mark BaseService interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface BaseService : NSObject {
@private
    dispatch_queue_t _serviceQueue;
    
}



@end
