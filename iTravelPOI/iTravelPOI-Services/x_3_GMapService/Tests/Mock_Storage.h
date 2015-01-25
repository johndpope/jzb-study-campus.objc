//
// Mock_Storage.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMDataStorage.h"
#import "GMSimpleItemFactory.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************
typedef enum {
    MST_Local = 0,
    MST_Remote = 1,
} Mock_Storage_Type;




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface Mock_Storage : NSObject <GMDataStorage, GMItemFactory>




// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (Mock_Storage *) storageWithType:(Mock_Storage_Type)type;



// =====================================================================================================================
#pragma mark -
#pragma mark GMItemFactory Protocol methods
// ---------------------------------------------------------------------------------------------------------------------
// Discardable. Non stored yet. Map must be sync with storage
- (id<GMMap>)      newMapWithName:(NSString *)name errRef:(NSErrorRef *)errRef;
- (id<GMPoint>)    newPointWithName:(NSString *)name inMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;
- (id<GMPolyLine>) newPolyLineWithName:(NSString *)name  inMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;



// =====================================================================================================================
#pragma mark -
#pragma mark GMDataStorage Protocol methods
// ---------------------------------------------------------------------------------------------------------------------
@property (strong, nonatomic, readonly) id<GMItemFactory> itemFactory;

- (NSArray *) retrieveMapList:(NSErrorRef *)errRef;
- (BOOL) retrievePlacemarksForMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;
- (BOOL) synchronizeMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;



// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (GMMap_T *) createMapWithName:(NSString *)name numTestPoints:(int)numTestPoints;
- (GMMap_T *) createClonFromMap:(GMMap_T *)map;
- (id<GMPoint>) createPointWithName:(NSString *)name inMap:(id<GMMap>)map;

- (void) addMap:(id<GMMap>)map withPlacemarks:(BOOL)withPlacemarks;
- (void) updateMap:(id<GMMap>)map withPlacemarks:(BOOL)withPlacemarks;
- (void) removeMap:(id<GMMap>)map withPlacemarks:(BOOL)withPlacemarks;

- (void) addPlacemark:(id<GMPlacemark>)placemark;
- (void) updatePlacemark:(id<GMPlacemark>)placemark;
- (void) removePlacemark:(id<GMPlacemark>)placemark;


@end
