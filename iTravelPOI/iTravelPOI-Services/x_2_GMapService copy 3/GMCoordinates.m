//
// GMCoordinatesBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMCoordinates__IMPL__
#define __GMCoordinates__PROTECTED__
#import "GMCoordinates.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface Private Definition
// *********************************************************************************************************************
@interface GMCoordinates ()

@property (assign, nonatomic) CLLocationDegrees  longitude;
@property (assign, nonatomic) CLLocationDegrees  latitude;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMCoordinates




// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMCoordinates *) coordinatesWithLongitude:(CLLocationDegrees)lng latitude:(CLLocationDegrees)lat {
    return [[GMCoordinates alloc] initWithLongitude:lng latitude:lat];
}

// ---------------------------------------------------------------------------------------------------------------------
// Format: f_longitude, f_latitude [, f_altitude]
+ (GMCoordinates *) coordinatesWithString:(NSString *)value {
    return [[GMCoordinates alloc] initWithString:value];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMCoordinates *) coordinatesWithCoordinates:(GMCoordinates *)coord {
    return [[GMCoordinates alloc] initWithCoordinates:coord];
}



// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithLongitude:(CLLocationDegrees)lng latitude:(CLLocationDegrees)lat {

    if( self = [super init] ) {
        self.latitude = lat;
        self.longitude = lng;
    }
    return self;
}

// ---------------------------------------------------------------------------------------------------------------------
// Format: f_longitude, f_latitude [, f_altitude]
- (instancetype) initWithString:(NSString *)value {
    
    if( self = [super init] ) {
        NSArray *splittedStr = [value componentsSeparatedByString:@","];
        if(splittedStr.count >= 2) {
            self.longitude = [splittedStr[0] doubleValue];
            self.latitude = [splittedStr[1] doubleValue];
        } else {
            self.longitude = 0;
            self.latitude = 0;
        }
    }
    return self;
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithCoordinates:(GMCoordinates *)coord {
    
    if( self = [super init] ) {
        self.longitude = coord.longitude;
        self.latitude = coord.latitude;
    }
    return self;
}


// =====================================================================================================================
#pragma mark -
#pragma mark PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
// Format: f_longitude, f_latitude [, f_altitude]
- (NSString *) stringValue {
    
    return [NSString stringWithFormat:@"%0.6f, %0.6f, 0.0", self.longitude, self.latitude];
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) isEqualToCoordinates:(GMCoordinates *)coord {

    return  self.longitude == coord.longitude && self.latitude == coord.latitude;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {

    return [NSString stringWithFormat:@"[longitude = %0.6f, latitude = %0.6f]", self.longitude, self.latitude];
}




// =====================================================================================================================
#pragma mark -
#pragma mark PROTECTED methods
// ---------------------------------------------------------------------------------------------------------------------




// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------



@end
