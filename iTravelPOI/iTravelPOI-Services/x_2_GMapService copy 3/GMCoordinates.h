//
// GMCoordinates.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>



// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************
#define COORDINATES_ZERO [GMCoordinates coordinatesWithLongitude:0.0 latitude:0.0];




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMCoordinates : NSObject


// General attributes
@property (assign, nonatomic, readonly) CLLocationDegrees  longitude;
@property (assign, nonatomic, readonly) CLLocationDegrees  latitude;


// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
// Format: f_longitude, f_latitude [, f_altitude]
+ (GMCoordinates *) coordinatesWithString:(NSString *)value;
+ (GMCoordinates *) coordinatesWithLongitude:(CLLocationDegrees)lng latitude:(CLLocationDegrees)lat;
+ (GMCoordinates *) coordinatesWithCoordinates:(GMCoordinates *)coord;

- (instancetype) initWithString:(NSString *)value;
- (instancetype) initWithLongitude:(CLLocationDegrees)lng latitude:(CLLocationDegrees)lat;
- (instancetype) initWithCoordinates:(GMCoordinates *)coord;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
// Format: f_longitude, f_latitude [, f_altitude]
- (NSString *) stringValue;
- (BOOL) isEqualToCoordinates:(GMCoordinates *)coord;

@end
