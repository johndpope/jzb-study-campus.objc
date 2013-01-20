//
// Placemark.h
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


// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface Placemark : NSObject

@property (strong) NSString *name;
@property (strong) NSString *descr;
@property (readonly) NSUInteger count;
@property (readonly) NSMutableArray *pointsLat;
@property (readonly) NSMutableArray *pointsLng;
@property (assign) double minLat;
@property (assign) double maxLat;
@property (assign) double minLng;
@property (assign) double maxLng;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------



@end
