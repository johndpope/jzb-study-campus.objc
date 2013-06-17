//
// SyncDataService.h
// iTravelPOI-FRWK
//
// Created by Jose Zarzuela on 29/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMTCompTuple.h"
#import "GMPSyncDelegate.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Service public enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------
@protocol SyncDataDelegate <GMPSyncDelegate>


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark SyncDataService Service interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface SyncDataService : NSObject

@property (atomic, assign) BOOL isRunning;


+ (SyncDataService *) syncDataServiceWithChildContext:(NSManagedObjectContext *)moChildContext delegate:(id<SyncDataDelegate>)delegate;

- (void) startMapsSync;
- (void) cancelSync;


@end
