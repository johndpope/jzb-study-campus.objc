//
// GMTBatchCmd.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMTPlacemark.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************
typedef enum {
    BATCH_CMD_ADD = 0,
    BATCH_CMD_UPDATE = 1,
    BATCH_CMD_DELETE = 2
} BATCH_CMD;

extern const NSString *BATCH_CMD_TEXTS[];

typedef enum {
    BATCH_RC_OK = 0,
    BATCH_RC_ERROR = 1,
    BATCH_RC_PENDING = 2,
} BATCH_RC;

extern const NSString *BATCH_RC_TEXTS[];



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMTBatchCmd : NSObject

@property (assign, nonatomic) BATCH_CMD cmd;
@property (strong, nonatomic) GMTPlacemark *placemark;
@property (assign, nonatomic) BATCH_RC resultCode;
@property (strong, nonatomic) GMTPlacemark *resultPlacemark;
@property (strong, nonatomic) id extraData;
@property (strong, nonatomic) NSError *error;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMTBatchCmd__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GMTBatchCmd *) batchCmd:(BATCH_CMD)cmd withPlacemark:(GMTPlacemark *)placemark;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description;

@end
