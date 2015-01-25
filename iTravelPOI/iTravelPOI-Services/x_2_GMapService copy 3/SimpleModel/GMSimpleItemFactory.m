//
// GMSimpleItemFactory.m
//
// Created by Jose Zarzuela.
//

#import "GMSimpleItemFactory.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface Private Definition
// *********************************************************************************************************************
@interface GMSimpleItemFactory ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMSimpleItemFactory




// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMSimpleItemFactory *) factory {
    return [[GMSimpleItemFactory alloc] init];
}



// =====================================================================================================================
#pragma mark -
#pragma mark PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
// Discardable. Non stored yet. They must be sync with storage
- (id<GMMap>) newMapWithName:(NSString *)name errRef:(NSErrorRef *)errRef {
    
    [NSError nilErrorRef:errRef];
    return [[GMSimpleMap alloc] initWithName:name];
}

// ---------------------------------------------------------------------------------------------------------------------
// Discardable. Non stored yet. They must be sync with storage
- (id<GMPoint>) newPointWithName:(NSString *)name inMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef {
    
    if(![map isKindOfClass:GMSimpleMap.class]) {
        [NSError setErrorRef:errRef domain:@"GMSimpleItemFactory" reason:@"Map must be instance of GMSimpleMap class: %@", map.class];
        return nil;
    }

    [NSError nilErrorRef:errRef];
    return [[GMSimplePoint alloc] initWithName:name ownerMap:map];
}

// ---------------------------------------------------------------------------------------------------------------------
// Discardable. Non stored yet. They must be sync with storage
- (id<GMPolyLine>) newPolyLineWithName:(NSString *)name  inMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef {
    
    if(![map isKindOfClass:GMSimpleMap.class]) {
        [NSError setErrorRef:errRef domain:@"GMSimpleItemFactory" reason:@"Map must be instance of GMSimpleMap class: %@", map.class];
        return nil;
    }
    
    [NSError nilErrorRef:errRef];
    return [[GMSimplePolyLine alloc] initWithName:name ownerMap:map];
}

@end
