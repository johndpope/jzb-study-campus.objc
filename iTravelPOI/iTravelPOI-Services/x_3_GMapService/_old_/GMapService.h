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
#import "NSError+SimpleInit.h"



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
- (instancetype) initWithEmail:(NSString *)email password:(NSString *)password errRef:(NSErrorRef *)errRef;
#endif


+ (GMapService *) serviceWithEmail2:(NSString *)email password:(NSString *)password errRef:(NSErrorRef *)errRef;



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getMapList:(NSErrorRef  *)errRef;
- (GMTMap *)  getMapFromEditURL:(NSString *)mapEditURL errRef:(NSErrorRef *)errRef;
- (GMTMap *)  addMap:(GMTMap *)map errRef:(NSErrorRef *)errRef;
- (GMTMap *)  updateMap:(GMTMap *)map errRef:(NSErrorRef *)errRef;
- (BOOL)      deleteMap:(GMTMap *)map errRef:(NSErrorRef *)errRef;


- (NSArray *)  getPlacemarkListFromMap:(GMTMap *)map errRef:(NSErrorRef *)errRef;

- (GMTPlacemark *) addPlacemark:(GMTPlacemark *)placemark    inMap:(GMTMap *)map errRef:(NSErrorRef *)errRef;
- (GMTPlacemark *) updatePlacemark:(GMTPlacemark *)placemark inMap:(GMTMap *)map errRef:(NSErrorRef *)errRef;
- (BOOL)           deletePlacemark:(GMTPlacemark *)placemark inMap:(GMTMap *)map errRef:(NSErrorRef *)errRef;


- (BOOL) processBatchCmds:(NSArray *)batchCmds inMap:(GMTMap *)map errRef:(NSErrorRef *)errRef checkCancelBlock:(CheckCancelBlock)checkCancelBlock;

@end
