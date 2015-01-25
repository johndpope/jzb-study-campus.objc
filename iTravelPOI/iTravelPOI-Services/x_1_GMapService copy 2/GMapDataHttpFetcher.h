//
// GMapDataHttpFetcher.h
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
@interface GMapDataHttpFetcher : NSObject



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL)           loginWithEmail:(NSString *)email password:(NSString *)password error:(NSError * __autoreleasing *)err;
- (NSDictionary *) gmapGET:(NSString *)feedStrURL error:(NSError * __autoreleasing *)err;
- (NSDictionary *) gmapPOST:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError * __autoreleasing *)err;
- (NSDictionary *) gmapUPDATE:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError * __autoreleasing *)err;
- (BOOL)           gmapDELETE:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError * __autoreleasing *)err;

@end
