//
// GMapService.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMTMap.h"
#import "GMTPoint.h"
#import "GMTBatchCmd.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------
typedef BOOL (^CheckCancelBlock)(void);



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMapService : NSObject



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMapService_IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GMapService *) serviceWithEmail:(NSString *)email password:(NSString *)password error:(NSError **)err;



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getMapList:(NSError **)err;
- (GMTMap *) getMapFromEditURL:(NSString *)mapEditURL error:(NSError **)err;
- (GMTMap *) addMap:(GMTMap *)map error:(NSError **)err;
- (GMTMap *) updateMap:(GMTMap *)map error:(NSError **)err;
- (BOOL) deleteMap:(GMTMap *)map error:(NSError **)err;


- (NSArray *) getPointListFromMap:(GMTMap *)map error:(NSError **)err;

- (BOOL) processBatchCmds:(NSArray *)batchCmds inMap:(GMTMap *)map allErrors:(NSMutableArray *)allErrors checkCancelBlock:(CheckCancelBlock)checkCancelBlock;


- (GMTPoint *) addPoint:(GMTPoint *)point inMap:(GMTMap *)map error:(NSError **)err;
- (GMTPoint *) updatePoint:(GMTPoint *)point inMap:(GMTMap *)map error:(NSError **)err;
- (BOOL) deletePoint:(GMTPoint *)point inMap:(GMTMap *)map error:(NSError **)err;

@end
