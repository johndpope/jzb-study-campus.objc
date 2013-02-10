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
#define GM_LOCAL_ID  @"LocalGMap-ID"
#define GM_NO_SYNC_ETAG  @"No-Sycn-ETag"


// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMTItem : NSObject

@property (strong)   NSString *name;
@property (strong)   NSString *gmID;
@property (strong)   NSString *etag;
@property (readonly) NSString *editLink;
@property (strong)   NSDate *published_Date;
@property (strong)   NSDate *updated_Date;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMTItem__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (NSString *) stringFromDate:(NSDate *)date;
+ (NSDate *) dateFromString:(NSString *)str;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) resetEntityWithName:(NSString *)name;
- (void) atomEntryDataContent:(NSMutableString *)atomStr;

- (NSString *) verifyFieldsNotNil;
- (NSString *) description;

- (NSString *) cleanXMLText:(NSString *)text;

@end
