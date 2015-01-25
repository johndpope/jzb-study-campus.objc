//
// GMapSyncService_Mocks.h
// GMapSyncService_Mocks
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMPSyncDataSource.h"
#import "GMapSyncService.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface Mock_GMPSyncDataSource : NSObject<GMPSyncDataSource>

+ (Mock_GMPSyncDataSource *) newInstance;

- (GMTMap *) __mock_newLocalMapWithName:(NSString *)name fakeSynced:(BOOL)fakeSynced;
- (GMTPlacemark *) __mock_newLocalPointWithName:(NSString *)name inMap:(GMTMap *)localMap;
- (NSArray *) __mock_getAllLocalMapList;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface Mock_GMapService : GMapService

+ (Mock_GMapService *) serviceWithEmail2:(NSString *)email password:(NSString *)password error:(NSError * __autoreleasing *)err;


@end
