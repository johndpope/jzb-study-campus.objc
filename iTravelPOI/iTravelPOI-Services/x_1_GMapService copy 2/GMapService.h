//
// GMapService.h
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
#import "GMTBatchCmd.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------
typedef BOOL (^CheckCancelBlock)(void);



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMapService : NSObject



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMapService_IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
- (instancetype) initWithEmail:(NSString *)email password:(NSString *)password error:(NSError * __autoreleasing *)err;
#endif


+ (GMapService *) serviceWithEmail2:(NSString *)email password:(NSString *)password error:(NSError * __autoreleasing *)err;



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getMapList:(NSError * __autoreleasing *)err;
- (GMTMap *)  getMapFromEditURL:(NSString *)mapEditURL error:(NSError * __autoreleasing *)err;
- (GMTMap *)  addMap:(GMTMap *)map error:(NSError * __autoreleasing *)err;
- (GMTMap *)  updateMap:(GMTMap *)map error:(NSError * __autoreleasing *)err;
- (BOOL)      deleteMap:(GMTMap *)map error:(NSError * __autoreleasing *)err;


- (NSArray *)  getPlacemarkListFromMap:(GMTMap *)map error:(NSError * __autoreleasing *)err;

- (GMTPlacemark *) addPlacemark:(GMTPlacemark *)placemark    inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err;
- (GMTPlacemark *) updatePlacemark:(GMTPlacemark *)placemark inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err;
- (BOOL)           deletePlacemark:(GMTPlacemark *)placemark inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err;


- (BOOL) processBatchCmds:(NSArray *)batchCmds inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err checkCancelBlock:(CheckCancelBlock)checkCancelBlock;

@end
