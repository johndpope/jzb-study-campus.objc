//
// GMSynchronizer.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"
#import "GMDataStorage.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************





// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMSynchronizer : NSObject


@property (strong, nonatomic, readonly) id<GMDataStorage> localStorage;
@property (strong, nonatomic, readonly) id<GMDataStorage> remoteStorage;


// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMSynchronizer *) synchronizerWithLocalStorage:(id<GMDataStorage>) localStorage remoteStorage:(id<GMDataStorage>) remoteStorage;


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark General Public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) syncronizeStorages;


@end
