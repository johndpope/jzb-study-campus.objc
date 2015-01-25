//
// GMSimpleModel_Protected.h
//
// Created by Jose Zarzuela.
//

#import <Foundation/Foundation.h>




// *********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimpleMap_Protected Protocol/Category public definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMSimpleMap_Protected <NSObject>

- (void) addPlacemark:(GMSimplePlacemark *)placemark;
- (void) removePlacemark:(GMSimplePlacemark *)placemark;

@end

@interface GMSimpleMap (Protected) <GMSimpleMap_Protected>


@end
