//
// Placemark.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "Placemark.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface Placemark ()

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation Placemark


@synthesize name = _name;
@synthesize descr = _descr;
@synthesize pointsLat = _pointsLat;
@synthesize pointsLng = _pointsLng;
@synthesize minLat = _minLat;
@synthesize maxLat = _maxLat;
@synthesize minLng = _minLng;
@synthesize maxLng = _maxLng;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
- (Placemark *) init {

    if(self) {
        _pointsLat = [NSMutableArray array];
        _pointsLng = [NSMutableArray array];
        self.minLat = INFINITY;
        self.maxLat = -INFINITY;
        self.minLng = INFINITY;
        self.maxLng = -INFINITY;
    }
    return self;
}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSUInteger) count {
    return self.pointsLat.count;
}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
