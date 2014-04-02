//
// GMTPoint.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTPoint__IMPL__
#define __GMTItem__IMPL__
#import "GMTPoint.h"

#import "GMPItemSubclassing.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTPoint () <GMPItemSubclassing>


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTPoint


@synthesize descr = _descr;
@synthesize iconHREF = _iconHREF;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMTPoint *) emptyPoint {
    return [GMTPoint emptyPointWithName:@""];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMTPoint *) emptyPointWithName:(NSString *)name {

    GMTPoint *point = [[GMTPoint alloc] init];
    [point resetEntityWithName:name];

    return point;
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) resetEntityWithName:(NSString *)name {

    [super resetEntityWithName:name];

    self.descr = @"";
    self.iconHREF = GM_DEFAULT_POINT_ICON_HREF;
    self.latitude = 0.0;
    self.longitude = 0.0;
}

// =====================================================================================================================
#pragma mark -
#pragma mark PROTECTED methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) __itemTypeName {
    return @"GMTPoint";
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __atomEntryDataContent:(NSMutableString *)atomStr {

    static NSUInteger s_idCounter = 1;


    [atomStr appendString:@"  <atom:content type='application/vnd.google-earth.kml+xml'>"];
    [atomStr appendString:@"      <Placemark>"];
    [atomStr appendFormat:@"        <name>%@</name>", [self cleanXMLText:self.name]];
    [atomStr appendFormat:@"        <description type='html'>%@</description>", [self cleanXMLText:self.descr]];

    if(self.iconHREF) {
        s_idCounter++;
        NSString *styleID = [NSString stringWithFormat:@"Style-%ld-%lu", time(0L), (unsigned long)s_idCounter];
        [atomStr appendFormat:@"        <Style id='%@'><IconStyle><Icon><href><![CDATA[%@]]></href></Icon></IconStyle></Style>", styleID, self.iconHREF];
    }

    //<!-- lon,lat[,alt] -->
    [atomStr appendString:@"        <Point>"];
    [atomStr appendFormat:@"          <coordinates>%0.6f,%0.6f,0.0</coordinates>", self.longitude, self.latitude];
    [atomStr appendString:@"        </Point>"];
    [atomStr appendString:@"      </Placemark>"];
    [atomStr appendString:@"  </atom:content>"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __verifyFieldsNotNil:(NSMutableArray *)result {
    if(self.descr == nil) [result addObject:@"descr"];
    if(self.iconHREF == nil) [result addObject:@"iconHREF"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __descriptionPutExtraFields:(NSMutableString *)mutStr {
    [mutStr appendFormat:@"  latitude    = '%f'\n", self.latitude];
    [mutStr appendFormat:@"  longitude   = '%f'\n", self.longitude];
    [mutStr appendFormat:@"  iconHREF    = '%@'\n", self.iconHREF];
    [mutStr appendFormat:@"  descr       = '%@'\n", self.descr];
}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
