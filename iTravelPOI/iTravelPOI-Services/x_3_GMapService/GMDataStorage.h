//
// GMDataStorage.h
//
// Created by Jose Zarzuela.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"
#import "GMItemFactory.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// *********************************************************************************************************************
@protocol GMDataStorage <NSObject>


@property (strong, readonly, nonatomic) id<GMItemFactory> itemFactory;


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark General Public methods
// ---------------------------------------------------------------------------------------------------------------------
// Map CRUD
- (id<GMMap>)  createMapWithName:(NSString *)name  errRef:(NSErrorRef *)errRef;
- (BOOL)       updateMap:(id<GMMap>)map            errRef:(NSErrorRef *)errRef;
- (BOOL)       deleteMap:(id<GMMap>)map            errRef:(NSErrorRef *)errRef;

// Placemark CRUD
- (id<GMPoint>)    createPointWithName:(NSString *)name         inMap:(id<GMMap>)map  errRef:(NSErrorRef *)errRef;
- (id<GMPolyLine>) createPolyLineWithName:(NSString *)name      inMap:(id<GMMap>)map  errRef:(NSErrorRef *)errRef;
- (BOOL)           updatePlacemark:(id<GMPlacemark>)placemark                         errRef:(NSErrorRef *)errRef;
- (BOOL)           removePlacemark:(id<GMPlacemark>)placemark                         errRef:(NSErrorRef *)errRef;


// Map retrieval
- (NSArray *) retrieveMapList:(NSErrorRef *)errRef;
- (NSArray *) retrieveMapByGID:(NSString *)gID errRef:(NSErrorRef *)errRef;


// Placemark retrieval
- (BOOL) retrievePlacemarksForMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;
- (id<GMPlacemark>) retrievePlacemarkByGID:(NSString *)gID errRef:(NSErrorRef *)errRef;



- (BOOL) synchronizeMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;


@end
