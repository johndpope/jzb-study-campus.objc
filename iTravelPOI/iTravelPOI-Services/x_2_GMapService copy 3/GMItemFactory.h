//
// GMItemFactory.h
//
// Created by Jose Zarzuela.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMItemFactory <NSObject>


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark General Public methods
// ---------------------------------------------------------------------------------------------------------------------
// Discardable. Non stored yet. They must be sync with storage
- (id<GMMap>)      newMapWithName:(NSString *)name errRef:(NSErrorRef *)errRef;
- (id<GMPoint>)    newPointWithName:(NSString *)name inMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;
- (id<GMPolyLine>) newPolyLineWithName:(NSString *)name  inMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;


@end
