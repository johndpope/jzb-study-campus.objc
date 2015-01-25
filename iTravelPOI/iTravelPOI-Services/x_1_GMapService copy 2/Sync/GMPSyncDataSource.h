//
// GMPSyncDataSource.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMTMap.h"
#import "GMTPlacemark.h"
#import "GMTPoint.h"
#import "GMTPolyLine.h"
#import "GMTCompTuple.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// *********************************************************************************************************************
@protocol GMPSyncDataSource <NSObject>

// Map methods
- (NSArray *) getAllLocalMapList:(NSError * __autoreleasing *)err;

- (GMTMap *)  newRemoteMapFrom:(id)localMap error:(NSError * __autoreleasing *)err;
- (BOOL)      setRemoteMap:(GMTMap *)remoteMap fromLocalMap:(id)localMap error:(NSError * __autoreleasing *)err;

- (id)        createLocalMapFrom:(GMTMap *)remoteMap error:(NSError * __autoreleasing *)err;
- (BOOL)      updateLocalMap:(id)localMap withRemoteMap:(GMTMap *)remoteMap allPlacemarksOK:(BOOL)allPlacemarksOK error:(NSError * __autoreleasing *)err;
- (BOOL)      deleteLocalMap:(id)localMap error:(NSError * __autoreleasing *)err;


// Placemark methods
- (NSArray *)      getLocalPlacemarkListForMap:(id)localMap error:(NSError * __autoreleasing *)err;

- (GMTPlacemark *) newRemotePlacemarkFrom:(id)localPlacemark inLocalMap:(id)map error:(NSError * __autoreleasing *)err;
- (BOOL)           setRemotePlacemark:(GMTPlacemark *)remotePlacemark fromLocalPlacemark:(id)localPlacemark inLocalMap:(id)map error:(NSError * __autoreleasing *)err;

- (id)             createLocalPlacemarkFrom:(GMTPlacemark *)remotePlacemark inLocalMap:(id)map error:(NSError * __autoreleasing *)err;
- (BOOL)           updateLocalPlacemark:(id)localPlacemark inLocalMap:(id)map withRemotePlacemark:(GMTPlacemark *)remotePlacemark error:(NSError * __autoreleasing *)err;
- (BOOL)           deleteLocalPlacemark:(id)localPlacemark inLocalMap:(id)map error:(NSError * __autoreleasing *)err;



@end

