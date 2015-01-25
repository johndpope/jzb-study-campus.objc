//
// GMRemoteService.h
// GMRemoteService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMDataStorage.h"
#import "GMItemFactory.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------
typedef BOOL (^CheckCancelBlock)(void);



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMRemoteService: NSObject <GMDataStorage>



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Init && CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithEmail:(NSString *)email password:(NSString *)password itemFactory:(id<GMItemFactory>)itemFactory errRef:(NSErrorRef *)errRef;



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (id<GMMap>) retrieveMapByGID:(NSString *)mapGID errRef:(NSErrorRef *)errRef;


@end
