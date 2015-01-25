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

- (GMTMap *)  newRemoteMapFrom:(id)localMap errRef:(NSErrorRef *)errRef;
- (BOOL)      setRemoteMap:(GMTMap *)remoteMap fromLocalMap:(id)localMap errRef:(NSErrorRef *)errRef;

- (id)        createLocalMapFrom:(GMTMap *)remoteMap errRef:(NSErrorRef *)errRef;
- (BOOL)      updateLocalMap:(id)localMap withRemoteMap:(GMTMap *)remoteMap allPlacemarksOK:(BOOL)allPlacemarksOK errRef:(NSErrorRef *)errRef;
- (BOOL)      deleteLocalMap:(id)localMap errRef:(NSErrorRef *)errRef;


// Placemark methods
- (NSArray *)      getLocalPlacemarkListForMap:(id)localMap errRef:(NSErrorRef *)errRef;

- (GMTPlacemark *) newRemotePlacemarkFrom:(id)localPlacemark inLocalMap:(id)map errRef:(NSErrorRef *)errRef;
- (BOOL)           setRemotePlacemark:(GMTPlacemark *)remotePlacemark fromLocalPlacemark:(id)localPlacemark inLocalMap:(id)map errRef:(NSErrorRef *)errRef;

- (id)             createLocalPlacemarkFrom:(GMTPlacemark *)remotePlacemark inLocalMap:(id)map errRef:(NSErrorRef *)errRef;
- (BOOL)           updateLocalPlacemark:(id)localPlacemark inLocalMap:(id)map withRemotePlacemark:(GMTPlacemark *)remotePlacemark errRef:(NSErrorRef *)errRef;
- (BOOL)           deleteLocalPlacemark:(id)localPlacemark inLocalMap:(id)map errRef:(NSErrorRef *)errRef;



@end

