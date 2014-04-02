//
// GMTMap.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTMap__IMPL__
#define __GMTItem__IMPL__
#define __GMTItem__SUBCLASSES__PROTECTED__
#import "GMTMap.h"

#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTMap ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTMap


@synthesize summary = _summary;
@synthesize featuresURL = _featuresURL;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMTMap *) emptyMap {
    return [GMTMap emptyMapWithName:@""];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMTMap *) emptyMapWithName:(NSString *)name {

    GMTMap *map = [[GMTMap alloc] init];
    [map resetEntityWithName:name];

    return map;
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) featuresURL {

    NSUInteger lastIndex = [self.gID lastIndexOf:@"/maps/"];
    if(lastIndex != NSNotFound) {
        NSString *url = [NSString stringWithFormat:@"%@/features/%@/full",
                         [self.gID substringToIndex:lastIndex],
                         [self.gID substringFromIndex:lastIndex + 6]];
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

    [super resetEntityWithName:name];

    self.summary = @"";
}

// =====================================================================================================================
#pragma mark -
#pragma mark PROTECTED methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) __itemTypeName {
    return @"GMTMap";
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __atomEntryDataContent:(NSMutableString *)atomStr {

    // Por algun motivo, el "summary" no puede ir vacio
    NSString *summary = self.summary!=nil && self.summary.length>0 ? self.summary : @".";
    [atomStr appendFormat:@"  <atom:summary type='text'>%@</atom:summary>", [self cleanXMLText:summary]];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __verifyFieldsNotNil:(NSMutableArray *)result {
    if(self.summary == nil) [result addObject:@"summary"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __descriptionPutExtraFields:(NSMutableString *)mutStr {
    [mutStr appendFormat:@"  summary     = '%@'\n", self.summary];
    [mutStr appendFormat:@"  featuresURL = '%@'\n", self.featuresURL];
}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
