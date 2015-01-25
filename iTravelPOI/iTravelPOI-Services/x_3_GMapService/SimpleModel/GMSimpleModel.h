//
// GMSimpleModel.h
//
// Created by Jose Zarzuela.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimpleItem Interface definition
// *********************************************************************************************************************
@interface GMSimpleItem : NSObject <GMItem>

- (instancetype) init __attribute__ ((unavailable ("Method 'init' not available")));
- (instancetype) initWithName:(NSString *)name;

@end




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimpleMap Interface definition
// *********************************************************************************************************************
@class GMSimplePlacemark, GMSimplePoint, GMSimplePolyLine;
@interface GMSimpleMap : GMSimpleItem <GMMap>

- (void) addPlacemark:(GMSimplePlacemark *)placemark;
- (void) removePlacemark:(GMSimplePlacemark *)placemark;
- (void) removeAllPlacemarks;

@end




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimplePlacemark Interface definition
// *********************************************************************************************************************
@interface GMSimplePlacemark : GMSimpleItem <GMPlacemark>

- (instancetype) initWithName:(NSString *)name __attribute__ ((unavailable ("Method '(NSString *)name' not available")));
- (instancetype) initWithName:(NSString *)name ownerMap:(GMSimpleMap *)owerMap;

@end




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimplePoint Interface definition
// *********************************************************************************************************************
@interface GMSimplePoint : GMSimplePlacemark <GMPoint>

@end




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimplePolyLine Interface definition
// *********************************************************************************************************************
@interface GMSimplePolyLine : GMSimplePlacemark <GMPolyLine>

@end

