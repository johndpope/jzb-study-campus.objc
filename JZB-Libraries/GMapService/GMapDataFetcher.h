//
// GMapDataFetcher.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>



// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMapDataFetcher : NSObject



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) loginWithEmail:(NSString *)email password:(NSString *)password error:(NSError **)err;
- (NSDictionary *) getServiceInfo:(NSString *)feedStrURL error:(NSError **)err;
- (NSDictionary *) postServiceInfo:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError **)err;
- (NSDictionary *) updateServiceInfo:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError **)err;
- (BOOL) deleteServiceInfo:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError **)err;

@end
