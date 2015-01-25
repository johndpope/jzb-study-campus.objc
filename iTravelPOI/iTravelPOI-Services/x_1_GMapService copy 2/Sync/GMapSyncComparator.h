//
// GMapSyncComparator.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMPComparable.h"
#import "GMTCompTuple.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMapSyncComparator : NSObject



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMapSyncComparator_IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (NSArray *) compareLocalItems:(NSArray *)localItems withRemoteItems:(NSArray *)remoteItems;
+ (id<GMPComparable>) searchItemBygID:(NSString *)gID inArray:(NSArray *)items;



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------


@end
