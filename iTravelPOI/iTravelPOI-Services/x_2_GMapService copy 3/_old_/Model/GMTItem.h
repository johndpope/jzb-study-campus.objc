//
// GMTItem.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMPComparable.h"
#import "GMTItem_Protected.h"
#import "NSError+SimpleInit.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************


#if TARGET_OS_MAC
    #define GMTColor NSColor
#elif TARGET_OS_IPHONE && !TARGET_OS_MAC
    #define GMTColor UIColor
#endif





// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMTItem : NSObject <GMPComparable, GMTItem_Protected>

@property (strong, nonatomic)   NSString *name;
@property (strong, nonatomic)   NSString *gID;
@property (strong, nonatomic)   NSString *etag;
@property (readonly, nonatomic) NSString *editLink;
@property (strong, nonatomic)   NSDate *published_Date;
@property (strong, nonatomic)   NSDate *updated_Date;
@property (assign, nonatomic)   BOOL modifiedSinceLastSyncValue;
@property (assign, nonatomic)   BOOL markedAsDeletedValue;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------

+ (NSString *) stringFromDate:(NSDate *)date;
+ (NSDate *) dateFromString:(NSString *)str;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithName:(NSString *)name;
- (instancetype) initWithContentOfFeed:(NSDictionary *)feedDict errRef:(NSErrorRef *)errRef;

- (void) copyValuesFromItem:(GMTItem *)item;

- (BOOL) hasNoSyncLocalGID;
- (BOOL) hasNoSyncLocalETag;
- (void) setLocalNoSyncValues;

- (NSMutableString *) atomEntryContentWithErrRef:(NSErrorRef *)errRef;


@end
