//
// GMTItem.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>

// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GM_Test : NSObject

@property (assign) BOOL exitOnError;
@property (strong) NSError *error;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GM_Test_IMPL_
- (id) init __attribute__ ((unavailable ("init not available")));
#endif
+ (GM_Test *) testWithEmail:(NSString *)email password:(NSString *)password exitOnError:(BOOL)exitOnError error:(NSError **)err;



// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) syncTestAll;
- (void) asyncTestAll;


- (BOOL) test_createUpdateDelete_map;
- (BOOL) test_readAllPoint;
- (BOOL) test_createUpdateDelete_point;
- (BOOL) test_batchCreateUpdateDelete_point;



@end
