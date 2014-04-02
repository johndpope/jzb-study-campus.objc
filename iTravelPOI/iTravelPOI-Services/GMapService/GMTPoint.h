//
// GMTPoint.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMTItem.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
#define GM_DEFAULT_POINT_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMTPoint : GMTItem

@property (strong, nonatomic) NSString *descr;
@property (strong, nonatomic) NSString *iconHREF;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMTPoint__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GMTPoint *) emptyPoint;
+ (GMTPoint *) emptyPointWithName:(NSString *)name;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------

@end
