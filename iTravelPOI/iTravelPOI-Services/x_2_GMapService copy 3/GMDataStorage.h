//
// GMTItemSubclassing.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMItemFactory.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// *********************************************************************************************************************
@protocol GMDataStorage <NSObject>


//@property (strong, nonatomic, readonly) id<GMItemFactory> itemFactory;


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark General Public methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) retrieveMapList:(NSErrorRef *)errRef;
- (BOOL) retrievePlacemarksForMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;

// It must be able to process Maps created by any GMItemFactory using just the GMItem protocol
- (BOOL) synchronizeMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef;


@end
