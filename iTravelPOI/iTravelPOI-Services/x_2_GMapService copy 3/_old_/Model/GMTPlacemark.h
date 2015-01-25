//
// GMTPlacemark.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMTItem.h"
#import "GMTPlacemark_Protected.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMTPlacemark : GMTItem <GMTPlacemark_Protected>

@property (strong, nonatomic) NSString *descr;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMTPlacemark__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif




// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------


@end
