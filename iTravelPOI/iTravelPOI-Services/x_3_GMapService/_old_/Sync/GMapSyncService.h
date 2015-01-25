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
#import "GMapService.h"



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

+ (GMapSyncService *) serviceWithEmail2:(NSString *)email
                              password:(NSString *)password
                            dataSource:(id<GMPSyncDataSource>)dataSource
                              delegate:(id<GMPSyncDelegate>)delegate
                                 errRef:(NSErrorRef *)errRef;

+ (GMapSyncService *) serviceWithGMapService:(GMapService *)gmService
                                  dataSource:(id<GMPSyncDataSource>)dataSource
                                    delegate:(id<GMPSyncDelegate>)delegate;


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) syncMaps;
- (void) cancelSync;
- (BOOL) wasCanceled;

@end
