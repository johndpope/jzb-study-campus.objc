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
#import "GMTCompTuple.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// *********************************************************************************************************************
@protocol GMPSyncDelegate <NSObject>


@optional
- (void) syncFinished:(BOOL)wasAllOK;

- (void) willGetRemoteMapList;
- (void) didGetRemoteMapList;

- (void) willCompareLocalAndRemoteMaps;
- (void) didCompareLocalAndRemoteMaps:(NSArray *)compTuples;

- (BOOL) shouldProcessTuple:(GMTCompTuple *)tuple error:(NSError * __autoreleasing *)err;

- (void) willSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int)index;
- (void) didSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int)index syncOK:(BOOL)syncOK;

@end

