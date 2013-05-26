//
// SyncDataService.h
// iTravelPOI-FRWK
//
// Created by Jose Zarzuela on 29/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMTCompTuple.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark Service public enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------
@protocol PSyncDataDelegate <NSObject>

- (void) syncFinished:(BOOL)allOK;

- (void) willGetRemoteMapList;
- (void) didGetRemoteMapList;
- (void) willSyncMapTupleList:(NSArray *)compTuples;
- (void) willSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int)index;
- (void) didSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int)index syncOK:(BOOL)syncOK;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark SyncDataService Service interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface SyncDataService : NSObject

+ (SyncDataService *) syncDataServiceWithMOContext:(NSManagedObjectContext *)moContext delegate:(id<PSyncDataDelegate>)delegate;

- (void) startMapsSync;
- (void) cancelSync;


@end
