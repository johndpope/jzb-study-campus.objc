//
// GMTPolyLine.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTPolyLine__IMPL__
#define __GMTItem__IMPL__
#define __GMTItem__SUBCLASSES__PROTECTED__
#import "GMTPolyLine.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTPolyLine ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTPolyLine



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMTPolyLine *) emptyPolyLine {
    return [GMTPolyLine emptyPolyLineWithName:@""];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMTPolyLine *) emptyPolyLineWithName:(NSString *)name {

    GMTPolyLine *polyLine = [[GMTPolyLine alloc] init];
    [polyLine resetEntityWithName:name];

    return polyLine;
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
    self.coordinates = [NSMutableArray array];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) addCoordWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lng {
    
    CLLocation *coord = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    [self.coordinates addObject:coord];
}



// =====================================================================================================================
#pragma mark -
#pragma mark PROTECTED methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) __itemTypeName {
    return @"GMTPolyLine";
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __atomEntryDataContent:(NSMutableString *)atomStr {

    /*********************************************************************************************************
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
    *********************************************************************************************************/
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __verifyFieldsNotNil:(NSMutableArray *)result {
    if(self.descr == nil) [result addObject:@"descr"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __descriptionPutExtraFields:(NSMutableString *)mutStr {
    
    [mutStr appendFormat:@"  descr       = '%@'\n", self.descr];
    [mutStr appendFormat:@"  coordinates = '%@'\n", self.coordinates];
}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
