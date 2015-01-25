//
// Mock_LocalStorage.h
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




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface Mock_LocalStorage : NSObject <GMDataStorage>




// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (Mock_LocalStorage *) storageWithMapNamePrefix:(NSString *)mapNamePrefix;




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
- (GMSimpleMap *) createMapWithName:(NSString *)name numTestPoints:(int)numTestPoints;
- (GMSimpleMap *) createCopyFromMap:(GMSimpleMap *)map;
- (id<GMPoint>)   createPointWithName:(NSString *)name inMap:(id<GMMap>)map;

- (void) directAddMap:(id<GMMap>)map;
- (void) directRemoveMap:(id<GMMap>)map;




@end
