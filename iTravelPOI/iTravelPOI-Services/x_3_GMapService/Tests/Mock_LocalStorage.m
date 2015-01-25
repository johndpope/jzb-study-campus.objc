//
// Mock_LocalStorage.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "Mock_LocalStorage.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface Private Definition
// *********************************************************************************************************************
@interface Mock_LocalStorage ()


@property (strong, nonatomic) NSString            *mapNamePrefix;
@property (strong, nonatomic) GMSimpleItemFactory *itemFactory;
@property (strong, nonatomic) NSMutableSet        *allMaps;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation Mock_LocalStorage




// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (Mock_LocalStorage *) storageWithMapNamePrefix:(NSString *)mapNamePrefix {

    Mock_LocalStorage *me = [[Mock_LocalStorage alloc] init];
    me.itemFactory = [GMSimpleItemFactory factory];
    me.allMaps = [NSMutableSet set];
    me.mapNamePrefix = mapNamePrefix;
    return me;
}




// =====================================================================================================================
#pragma mark -
#pragma mark GMDataStorage Protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) retrieveMapList:(NSErrorRef *)errRef {
    return self.allMaps.allObjects;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) retrievePlacemarksForMap:(GMSimpleMap *)map errRef:(NSErrorRef *)errRef {
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
// It must be able to process Maps created by any GMItemFactory using just the GMItem protocol
- (BOOL) synchronizeMap:(GMSimpleMap *)map errRef:(NSErrorRef *)errRef {
    
    [NSError nilErrorRef:errRef];
    return [self _local_synchronizeMap:map];
}



// =====================================================================================================================
#pragma mark -
#pragma mark SUPPORT PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (GMSimpleMap *) createMapWithName:(NSString *)name numTestPoints:(int)numTestPoints {
    
    // Crea la instancia con informacion basica
    GMSimpleMap * map = [self.itemFactory newMapWithName:[NSString stringWithFormat:@"%@%@", self.mapNamePrefix, name] errRef:nil];
    
    // Le crea un punto
    for(int n=0;n<numTestPoints;n++) {
        NSString *pointName = [NSString stringWithFormat:@"Point-%02d", n];
        [self createPointWithName:pointName inMap:map];
    }
    
    return map;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMSimpleMap *) createCopyFromMap:(GMSimpleMap *)map {
    
    
    
    GMSimpleMap *mapCopy = [self createMapWithName:@"" numTestPoints:0];
    [mapCopy shallowSetValuesFromItem:map];
    
    for(GMSimplePlacemark *placemark in map.placemarks) {
        
        NSError *localError;
        GMSimplePlacemark *placemarkCopy;
        
        if([placemark isKindOfClass:GMSimplePoint.class]) {
            placemarkCopy = [self.itemFactory newPointWithName:@"" inMap:mapCopy errRef:&localError];
        } else {
            placemarkCopy = [self.itemFactory newPolyLineWithName:@"" inMap:mapCopy errRef:&localError];
        }
        
        [placemarkCopy shallowSetValuesFromItem:placemark];

    }
    
    return mapCopy;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMSimplePoint *) createPointWithName:(NSString *)name inMap:(GMSimpleMap *)map {
    
    GMSimplePoint * point = [self.itemFactory newPointWithName:name inMap:map errRef:nil];
    point.coordinates = [GMCoordinates coordinatesWithLongitude:50.0*((double)rand()/(double)RAND_MAX) latitude:50.0*((double)rand()/(double)RAND_MAX)];
    return point;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) directAddMap:(id<GMMap>)map {
    [self.allMaps addObject:map];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) directRemoveMap:(id<GMMap>)map {
    [self.allMaps removeObject:map];
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (GMSimpleMap *) _searchMapByID:(NSString *) gID {

    for(GMSimpleMap *map in self.allMaps) {
        if([map.gID isEqualToString:gID]) return map;
    }
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _local_synchronizeMap:(GMSimpleMap *)map {


    if(map.markedAsDeleted) {
        
        // Lo borra del almacen
        [self directRemoveMap:map];
        
    } else {

        // Elimina los placemarks que esten marcados como borrados
        [[map.placemarks copy] enumerateObjectsUsingBlock:^(GMSimplePlacemark *placemark, NSUInteger idx, BOOL *stop) {
            if(placemark.markedAsDeleted) {
                //[placemark removeFromMap];
            }
        }];

    }
    
    // Todo fue bien
    return TRUE;
    
}



@end
