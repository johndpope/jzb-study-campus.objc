//
// GMTItemBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTItem__IMPL__
#define __GMTItem__SUBCLASSES__PROTECTED__
#import "GMTItem.h"

#import "NSString+JavaStr.h"
#import "NSString+HTML.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
#define GM_DATE_FORMATTER @"yyyy-MM-dd'T'HH:mm:ss'.'SSSS'Z'"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTItem ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTItem


@synthesize name = _name;
@synthesize gID = _gID;
@synthesize etag = _etag;
@synthesize published_Date = _published_Date;
@synthesize updated_Date = _updated_Date;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) stringFromDate:(NSDate *)date {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GM_DATE_FORMATTER];
    // The Z at the end of your string represents Zulu which is UTC
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSDate *) dateFromString:(NSString *)str {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GM_DATE_FORMATTER];
    // The Z at the end of your string represents Zulu which is UTC
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *dateFromString = [dateFormatter dateFromString:str];
    return dateFromString;
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) editLink {

    NSUInteger lastIndex = [self.gID lastIndexOf:@"/"];
    if(lastIndex != NSNotFound) {
        NSString *url = [NSString stringWithFormat:@"%@/full%@",
                         [self.gID substringToIndex:lastIndex],
                         [self.gID substringFromIndex:lastIndex]];
        return url;
    } else {
        return nil;
    }
}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) resetEntityWithName:(NSString *)name {

    self.name = name;
    self.gID = GM_LOCAL_ID;
    self.etag = GM_NO_SYNC_ETAG;
    self.published_Date = [NSDate date];
    self.updated_Date = self.published_Date;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) atomEntryDataContent:(NSMutableString *)atomStr {

    if(self.gID != nil && self.gID.length > 0 && ![self.gID isEqualToString:GM_LOCAL_ID]) {
        [atomStr appendFormat:@"  <atom:id>%@</atom:id>", self.gID];
        [atomStr appendFormat:@"  <atom:link rel='edit' type='application/atom+xml' href='%@'/>", self.editLink];
    }

    [atomStr appendFormat:@"  <atom:published>%@</atom:published>", [GMTItem stringFromDate:self.published_Date]];
    [atomStr appendFormat:@"  <atom:updated>%@</atom:updated>", [GMTItem stringFromDate:self.updated_Date]];

    [atomStr appendFormat:@"  <atom:title   type='text'>%@</atom:title>", [self cleanXMLText:self.name]];

    [self __atomEntryDataContent:atomStr];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) verifyFieldsNotNil {

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:8];

    if(self.name == nil) [result addObject:@"name"];
    if(self.gID == nil) [result addObject:@"gID"];
    if(self.etag == nil) [result addObject:@"etag"];
    if(self.published_Date == nil) [result addObject:@"published_Date"];
    if(self.updated_Date == nil) [result addObject:@"updated_Date"];

    [self __verifyFieldsNotNil:result];

    if(result.count > 0) {
        return [result componentsJoinedByString:@", "];
    } else
        return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {

    NSMutableString *desc = [NSMutableString string];

    [desc appendFormat:@"%@ {\n", [self __itemTypeName]];

    [desc appendFormat:@"  name        = '%@'\n", self.name];
    [desc appendFormat:@"  gID        = '%@'\n", self.gID];
    [desc appendFormat:@"  etag        = '%@'\n", self.etag];

    [self __descriptionPutExtraFields:desc];

    [desc appendFormat:@"  editLink    = '%@'\n", self.editLink];
    [desc appendFormat:@"  published   = '%@'\n", [GMTItem stringFromDate:self.published_Date]];
    [desc appendFormat:@"  updated     = '%@'\n", [GMTItem stringFromDate:self.updated_Date]];

    [desc appendString:@"}"];

    return desc;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) cleanXMLText:(NSString *)text {
    
    return [text gtm_stringByEscapingForHTML];
}

// =====================================================================================================================
#pragma mark -
#pragma mark PROTECTED methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) __itemTypeName {
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __atomEntryDataContent:(NSMutableString *)atomStr {
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __verifyFieldsNotNil:(NSMutableArray *)result {
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __descriptionPutExtraFields:(NSMutableString *)mutStr {
    
}

@end
