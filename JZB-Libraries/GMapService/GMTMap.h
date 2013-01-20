//
// GMTMap.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMTItem.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMTMap : GMTItem

@property (strong)   NSString *summary;
@property (readonly) NSString *featuresURL;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMTMap__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GMTMap *) emptyMap;
+ (GMTMap *) emptyMapWithName:(NSString *)name;



// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------

@end
