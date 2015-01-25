//
// GMTBatchCmdBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTBatchCmd__IMPL__
#import "GMTBatchCmd.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************
const NSString *BATCH_CMD_TEXTS[] = {@"insert", @"update", @"delete"};
const NSString *BATCH_RC_TEXTS[] = {@"RC_OK", @"RC_ERROR", @"RC_PENDING"};



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTBatchCmd ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTBatchCmd



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMTBatchCmd *) batchCmd:(BATCH_CMD)cmd withPlacemark:(GMTPlacemark *)placemark {

    GMTBatchCmd *batchCmd = [[GMTBatchCmd alloc] init];

    batchCmd.cmd = cmd;
    batchCmd.placemark = placemark;
    batchCmd.resultCode = BATCH_RC_PENDING;
    batchCmd.resultPlacemark = nil;

    return batchCmd;
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {

    NSMutableString *desc = [NSMutableString string];

    [desc appendString:@"GMTBatchCmd {\n"];
    [desc appendFormat:@"  cmd             = '%@'\n", BATCH_CMD_TEXTS[self.cmd]];
    [desc appendFormat:@"  placemark       = '%@'\n", self.placemark];
    [desc appendFormat:@"  resultCode      = '%@'\n", BATCH_RC_TEXTS[self.resultCode]];
    [desc appendFormat:@"  resultPlacemark = '%@'\n", self.resultPlacemark];
    [desc appendString:@"}"];

    return desc;
}

@end
