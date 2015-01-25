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
#import "GMTPolyLine.h"
#import "GMTCompTuple.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// *********************************************************************************************************************
@protocol GMPSyncDelegate <NSObject>


/////////////////////////////////////////////////@optional
- (void) syncStarted;
- (void) syncFinished:(BOOL)wasAllOK;

- (void) errorNotification:(NSError *)error;

- (void) willGetRemoteMapList;
- (void) didGetRemoteMapList;

- (void) willCompareLocalAndRemoteMaps;
- (void) didCompareLocalAndRemoteMaps:(NSArray *)compTuples;

- (BOOL) shouldProcessMapTuple:(GMTCompTuple *)tuple error:(NSError * __autoreleasing *)err;

- (void) willSyncMapTuple:(GMTCompTuple *)tuple;
- (void) didSyncMapTuple:(GMTCompTuple *)tuple;

@end

