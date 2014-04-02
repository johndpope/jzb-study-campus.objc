//
// GMapSyncService.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMPSyncDataSource.h"
#import "GMPSyncDelegate.h"



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
@interface GMapSyncService : NSObject



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMapSyncService_IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GMapSyncService *) serviceWithEmail:(NSString *)email
                              password:(NSString *)password
                            dataSource:(id<GMPSyncDataSource>)dataSource
                              delegate:(id<GMPSyncDelegate>)delegate
                                 error:(NSError * __autoreleasing *)err;



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) syncMaps:(NSError * __autoreleasing *)err;
- (void) cancelSync;
- (BOOL) wasCanceled;

@end
