//
// GMSimpleModel_Protected.h
//
// Created by Jose Zarzuela.
//

#import <Foundation/Foundation.h>




// *********************************************************************************************************************
#pragma mark -
#pragma mark Protected Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimpleItem_Protected Protocol/Category protected definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMSimpleItem_Protected <NSObject>

@end

@interface GMSimpleItem (Protected) <GMSimpleItem_Protected>

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimpleMap_Protected Protocol/Category protected definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMSimpleMap_Protected <GMSimpleItem_Protected>

@end

@interface GMSimpleMap (Protected) <GMSimpleMap_Protected>

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimplePlacemark_Protected Protocol/Category protected definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMSimplePlacemark_Protected <GMSimpleItem_Protected>

@end

@interface GMSimplePlacemark (Protected) <GMSimplePlacemark_Protected>

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimplePoint_Protected Protocol/Category protected definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMSimplePoint_Protected <GMSimplePlacemark_Protected>

@end

@interface GMSimplePoint (Protected) <GMSimplePoint_Protected>

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSimplePlacemark_Protected Protocol/Category protected definition
// ---------------------------------------------------------------------------------------------------------------------
@protocol GMSimplePolyLine_Protected <GMSimplePlacemark_Protected>

@end

@interface GMSimplePolyLine (Protected) <GMSimplePolyLine_Protected>

@end


