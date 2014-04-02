//
// GMPSyncDataSource.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMTMap.h"
#import "GMTPoint.h"
#import "GMTCompTuple.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// *********************************************************************************************************************
@protocol GMPSyncDataSource <NSObject>

// Map methods
- (NSArray *) getAllLocalMapList:(NSError * __autoreleasing *)err;

- (GMTMap *) gmMapFromLocalMap:(id)localMap error:(NSError * __autoreleasing *)err;
- (id) createLocalMapFrom:(GMTMap *)gmMap error:(NSError * __autoreleasing *)err;
- (BOOL) updateLocalMap:(id)localMap withRemoteMap:(GMTMap *)remoteMap allPointsOK:(BOOL)allPointsOK error:(NSError * __autoreleasing *)err;
- (BOOL) deleteLocalMap:(id)localMap error:(NSError * __autoreleasing *)err;

// Point methods
- (NSArray *) localPointListForMap:(id)localMap error:(NSError * __autoreleasing *)err;

- (GMTPoint *) gmPointFromLocalPoint:(id)localPoint error:(NSError * __autoreleasing *)err;
- (id) createLocalPointFrom:(GMTPoint *)gmPoint inLocalMap:(id)map error:(NSError * __autoreleasing *)err;
- (BOOL) updateLocalPoint:(id)localPoint withRemotePoint:(GMTPoint *)remotePoint error:(NSError * __autoreleasing *)err;
- (BOOL) deleteLocalPoint:(id)localPoint inLocalMap:(id)map error:(NSError * __autoreleasing *)err;

@end

