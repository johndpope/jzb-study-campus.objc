//
// GMTPolyLine.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GMTPlacemark.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
#define GM_DEFAULT_POLYLINE_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/GMI_landmarks-jp.png"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMTPolyLine : GMTPlacemark

@property (strong, nonatomic) NSMutableArray *coordinates;
@property (strong, nonatomic) GMTColor *color;
@property (assign, nonatomic) NSUInteger width;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMTPolyLine__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GMTPolyLine *) emptyPolyLine;
+ (GMTPolyLine *) emptyPolyLineWithName:(NSString *)name;
+ (GMTPolyLine *) polyLineWithContentOfFeed:(NSDictionary *)feedDict error:(NSError * __autoreleasing *)err;



// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) addCoordWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lng;

@end
