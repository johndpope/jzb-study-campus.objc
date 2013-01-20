//
// GMPSyncDelegate.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMTMap.h"
#import "GMTPoint.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// *********************************************************************************************************************
@protocol GMPSyncDelegate <NSObject>

- (NSArray *) getAllLocalMapList:(NSError **)err;

- (GMTMap *) gmMapFromLocalMap:(id)localMap error:(NSError **)err;
- (id) createLocalMapFrom:(GMTMap *)gmMap error:(NSError **)err;
- (BOOL) updateLocalMap:(id)localMap withRemoteMap:(GMTMap *)remoteMap allPointsOK:(BOOL)allPointsOK error:(NSError **)err;
- (BOOL) deleteLocalMap:(id)localMap error:(NSError **)err;

- (NSArray *) localPointListForMap:(id)localMap error:(NSError **)err;

- (GMTPoint *) gmPointFromLocalPoint:(id)localPoint error:(NSError **)err;
- (id) createLocalPointFrom:(GMTPoint *)gmPoint inLocalMap:(id)map error:(NSError **)err;
- (BOOL) updateLocalPoint:(id)localPoint withRemotePoint:(GMTPoint *)remotePoint error:(NSError **)err;
- (BOOL) deleteLocalPoint:(id)localPoint inLocalMap:(id)map error:(NSError **)err;

@end
