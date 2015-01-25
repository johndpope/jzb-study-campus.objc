//
// FilteredRemoteService.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMRemoteService.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface FilteredRemoteService : GMRemoteService




// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithEmail:(NSString *)email
                      password:(NSString *)password
                   itemFactory:(id<GMItemFactory>)itemFactory
                 mapNamePrefix:(NSString *)mapNamePrefix
                        errRef:(NSErrorRef *)errRef;






@end
