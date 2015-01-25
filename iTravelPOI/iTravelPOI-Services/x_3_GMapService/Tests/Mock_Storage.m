//
// Mock_StorageBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __Mock_Storage__IMPL__
#define __Mock_Storage__PROTECTED__
#import "Mock_Storage.h"
#import "GMComparer.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------
typedef enum {
    MSS_Nothing = 0,
    MSS_Create  = 1,
    MSS_Update  = 2,
    MSS_Delete  = 3
} Mock_Storage_SyncStatus;


// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface Private Definition
// *********************************************************************************************************************
@interface Mock_Storage ()


@property (strong, nonatomic) GMSimpleItemFactory *itemFactory;
@property (strong, nonatomic) NSMutableSet        *allMaps;
@property (strong, nonatomic) NSMutableSet        *allPlacemarks;
@property (assign, nonatomic) Mock_Storage_Type    storageType;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation Mock_Storage




// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (Mock_Storage *) storageWithType:(Mock_Storage_Type)type {

    Mock_Storage *me = [[Mock_Storage alloc] init];
    me.itemFactory = [GMSimpleItemFactory factory];
    me.allMaps = [NSMutableSet set];
    me.allPlacemarks = [NSMutableSet set];
    me.storageType = type;
    return me;
}




// =====================================================================================================================
#pragma mark -
#pragma mark GMItemFactory Protocol methods
// ---------------------------------------------------------------------------------------------------------------------
// Discardable. Non stored yet. Map must be sync with storage
- (GMSimpleMap *) newMapWithName:(NSString *)name errRef:(NSErrorRef *)errRef {
    GMSimpleMap * map = [self.itemFactory newMapWithName:name errRef:errRef];
    return map;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMSimplePoint *) newPointWithName:(NSString *)name inMap:(GMSimpleMap *)map errRef:(NSErrorRef *)errRef {
    GMSimplePoint * placemark = [self.itemFactory newPointWithName:name inMap:map errRef:errRef];
    return placemark;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMSimplePolyLine *) newPolyLineWithName:(NSString *)name  inMap:(GMSimpleMap *)map errRef:(NSErrorRef *)errRef {
    GMSimplePolyLine * placemark =  [self.itemFactory newPolyLineWithName:name inMap:map errRef:errRef];
    return placemark;
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
    
    if(self.storageType==MST_Local) {
        return [self _local_synchronizeMap:map errRef:errRef];
    } else {
        return [self _remote_synchronizeMap:map errRef:errRef];
    }
}



// =====================================================================================================================
#pragma mark -
#pragma mark SUPPORT PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (GMSimpleMap *) createMapWithName:(NSString *)name numTestPoints:(int)numTestPoints {
    
    // Crea la instancia con informacion basica
    GMSimpleMap * map = [self.itemFactory newMapWithName:[NSString stringWithFormat:@"@%@", name] errRef:nil];
    map.markedAsDeleted = FALSE;
    map.markedAsModified = (self.storageType==MST_Local);
    map.gID = [Mock_Storage _generateGIdType:self.storageType];
    map.etag = [Mock_Storage _generateETagType:self.storageType];
    
    // Lo marca como pendiente de salvarlo
    map.needToBeSaved = (self.storageType==MST_Local);

    // Le crea un punto
    for(int n=0;n<numTestPoints;n++) {
        NSString *pointName = [NSString stringWithFormat:@"Point-%02d", n];
        [self createPointWithName:pointName inMap:map];
    }
    
    return map;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMSimpleMap *) createClonFromMap:(GMSimpleMap *)map {
    
    GMSimpleMap * clonedMap = [self.itemFactory newMapWithName:@"" errRef:nil];
    [clonedMap shallowSetValuesFromItem:map];
    
    [map.placemarks enumerateObjectsUsingBlock:^(GMSimplePlacemark *placemark, NSUInteger idx, BOOL *stop) {
        GMSimplePlacemark *clonedPlacemark = [placemark emptyInstanceLikeMeInMap:clonedMap];
        [clonedPlacemark shallowSetValuesFromItem:placemark];
    }];
    
    return clonedMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) addMap:(GMSimpleMap *)map withPlacemarks:(BOOL)withPlacemarks {
    
    [self.allMaps addObject:map];
    map.needToBeSaved = FALSE;
    
    if(withPlacemarks) {
        [map.placemarks enumerateObjectsUsingBlock:^(GMSimplePlacemark *placemark, NSUInteger idx, BOOL *stop) {
            [self addPlacemark:placemark];
        }];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) updateMap:(GMSimpleMap *)map withPlacemarks:(BOOL)withPlacemarks {

    map.needToBeSaved = FALSE;
    
    if(withPlacemarks) {
        [map.placemarks enumerateObjectsUsingBlock:^(GMSimplePlacemark *placemark, NSUInteger idx, BOOL *stop) {
            [self updatePlacemark:placemark];
        }];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) removeMap:(GMSimpleMap *)map withPlacemarks:(BOOL)withPlacemarks {
    
    [self.allMaps removeObject:map];
    
    if(withPlacemarks) {
        [map.placemarks enumerateObjectsUsingBlock:^(GMSimplePlacemark *placemark, NSUInteger idx, BOOL *stop) {
            [self removePlacemark:placemark];
        }];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMSimplePoint *) createPointWithName:(NSString *)name inMap:(GMSimpleMap *)map {
    
    GMSimplePoint * point = [self.itemFactory newPointWithName:name inMap:map errRef:nil];
    point.markedAsDeleted = FALSE;
    point.markedAsModified = (self.storageType==MST_Local);
    point.gID = [Mock_Storage _generateGIdType:self.storageType];
    point.etag = [Mock_Storage _generateETagType:self.storageType];
    point.coordinates = [GMCoordinates coordinatesWithLongitude:50.0*((double)rand()/(double)RAND_MAX) latitude:50.0*((double)rand()/(double)RAND_MAX)];
    
    // Lo marca como pendiente de salvarlo
    point.needToBeSaved = (self.storageType==MST_Local);

    return point;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) addPlacemark:(GMSimplePlacemark *)placemark {
    [self.allPlacemarks addObject:placemark];
    placemark.needToBeSaved = FALSE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) updatePlacemark:(GMSimplePlacemark *)placemark {
    placemark.needToBeSaved = FALSE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) removePlacemark:(GMSimplePlacemark *)placemark {
    [placemark removeFromMap];
    placemark.needToBeSaved = FALSE;
    [self.allPlacemarks removeObject:placemark];
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _generateGIdType:(Mock_Storage_Type)type {
    
    // Contador para los IDs y ETags iniciales
    static NSUInteger s_idCounter = 1;
    
    NSString *id_prefix = type==MST_Local ? GM_NO_SYNC_LOCAL_ID : @"Sync-Remote-GID";
    NSString *gID = [NSString stringWithFormat:@"%@-%04ld", id_prefix, s_idCounter++];
    return gID;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _generateETagType:(Mock_Storage_Type)type {
    
    // Contador para los IDs y ETags iniciales
    static NSUInteger s_idCounter = 1;
    
    NSString *etag_prefix = type==MST_Local ? GM_NO_SYNC_LOCAL_ETAG : @"Sync-Remote-ETAG";
    NSString *etag = [NSString stringWithFormat:@"%@-%04ld", etag_prefix, s_idCounter++];
    return etag;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMSimpleMap *) _searchMapByID:(NSString *) gID {

    for(GMSimpleMap *map in self.allMaps) {
        if([map.gID isEqualToString:gID]) return map;
    }
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMSimplePlacemark *) _searchPlacemarkByID:(NSString *) gID {
    
    for(GMSimplePlacemark *placemark in self.allPlacemarks) {
        if([placemark.gID isEqualToString:gID]) return placemark;
    }
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (Mock_Storage_SyncStatus) _syncStatusForItem:(GMItem_T *) item {
    
    // El estado de sincronizacion depende de si fue sincronizado, borrado, modificado,...
    if(item.markedAsDeleted) {
        return item.wasSynchronized ? MSS_Delete : MSS_Nothing;
        
    } else if(!item.wasSynchronized) {
        return MSS_Create;
        
    } else if(item.markedAsModified){
        return MSS_Update;
        
    } else {
        return MSS_Nothing;
        
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _remote_synchronizeMap:(GMSimpleMap *)map errRef:(NSErrorRef *)errRef {

    
    GMSimpleMap *mapCopy = nil;


    // No hay error inicial
    [NSError nilErrorRef:errRef];

    // Procesa dependiendo de su estado de sincronizacion
    switch ([self _syncStatusForItem:map]) {
            
        case MSS_Nothing:
            // Nada
            break;
            
        case MSS_Create:
            // Crea una nueva instancia de mapa remoto y le copia informacion del local
            mapCopy = [self.itemFactory newMapWithName:@"" errRef:errRef];
            [mapCopy shallowSetValuesFromItem:map];
            
            // Actualiza los valores remotos adecuadamente
            mapCopy.gID = [Mock_Storage _generateGIdType:MST_Remote];
            mapCopy.etag = [Mock_Storage _generateETagType:MST_Remote];
            mapCopy.markedAsDeleted = FALSE;
            mapCopy.markedAsModified = FALSE;
            mapCopy.published_Date = [NSDate date];
            mapCopy.updated_Date = [NSDate date];
            
            // Lo almacena
            [self addMap:mapCopy withPlacemarks:FALSE];

            // Copia de vuelta informacion al mapa local como sincronizado
            [map shallowSetValuesFromItem:mapCopy];
            
            // Lo marca como para salvarlo
            map.needToBeSaved = TRUE;
            
            // Itera sincronizado los placemarks
            [self _synchronizePlacemarksToRemoteMap:mapCopy fromLocalMap:map];
            break;
            
        case MSS_Update:
            // Busca el elemento previamente creado y le copia informacion del local (SI LO ENCUENTRA)
            mapCopy = [self _searchMapByID:map.gID];
            if(!mapCopy) return FALSE;
            [mapCopy shallowSetValuesFromItem:map];

            // Actualiza los valores remotos adecuadamente
            mapCopy.etag = [Mock_Storage _generateETagType:MST_Remote];
            mapCopy.markedAsDeleted = FALSE;
            mapCopy.markedAsModified = FALSE;
            mapCopy.updated_Date = [NSDate date];

            // Actualiza el almacen
            [self updateMap:mapCopy withPlacemarks:FALSE];

            // Copia de vuelta informacion al mapa local como sincronizado
            [map shallowSetValuesFromItem:mapCopy];
            
            // Lo marca como para salvarlo
            map.needToBeSaved = TRUE;

            // Itera sincronizado los placemarks
            [self _synchronizePlacemarksToRemoteMap:mapCopy fromLocalMap:map];
            break;
            
        case MSS_Delete:
            // Busca el elemento previamente creado y lo borra (SI LO ENCUENTRA)
            mapCopy = [self _searchMapByID:map.gID];
            if(!mapCopy) return FALSE;
            [self removeMap:mapCopy withPlacemarks:FALSE];
            
            // Marca el local como borrado
            map.markedAsDeleted = TRUE;
            break;
    }
    
    // Todo fue bien
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _synchronizePlacemarksToRemoteMap:(GMSimpleMap *)remoteMap fromLocalMap:(GMSimpleMap *)localMap  {
    
    // Le quita todas los placemarks al mapa remoto
    [remoteMap removeAllPlacemarks];
    
    // Itera los placemarks del mapa local
    for(GMSimplePlacemark *placemark in localMap.placemarks) {
        
        GMSimplePlacemark *placemarkCopy;
        
        // Procesa dependiendo de su estado de sincronizacion
        switch ([self _syncStatusForItem:placemark]) {
                
            case MSS_Nothing:
                // Nada
                break;
                
            case MSS_Create:
                // Crea una nueva instancia de placemark remoto y le copia informacion del local
                placemarkCopy = [placemark emptyInstanceLikeMeInMap:remoteMap];
                [placemarkCopy shallowSetValuesFromItem:placemark];
                
                // Actualiza los valores remotos adecuadamente
                placemarkCopy.gID = [Mock_Storage _generateGIdType:MST_Remote];
                placemarkCopy.etag = [Mock_Storage _generateETagType:MST_Remote];
                placemarkCopy.markedAsDeleted = FALSE;
                placemarkCopy.markedAsModified = FALSE;
                placemarkCopy.published_Date = [NSDate date];
                placemarkCopy.updated_Date = [NSDate date];
                
                // Lo almacena
                [self addPlacemark:placemarkCopy];
                
                // Copia de vuelta informacion al placemark local como sincronizado
                [placemark shallowSetValuesFromItem:placemarkCopy];
                
                // Lo marca como para salvarlo
                placemark.needToBeSaved = TRUE;
                break;
                
            case MSS_Update:
                // Crea una nueva instancia de placemark remoto y le copia informacion del local
                placemarkCopy = [placemark emptyInstanceLikeMeInMap:remoteMap];
                [placemarkCopy shallowSetValuesFromItem:placemark];
                
                // Actualiza los valores remotos adecuadamente
                placemarkCopy.etag = [Mock_Storage _generateETagType:MST_Remote];
                placemarkCopy.markedAsDeleted = FALSE;
                placemarkCopy.markedAsModified = FALSE;
                placemarkCopy.updated_Date = [NSDate date];
                
                // Actualiza el almacen
                [self updatePlacemark:placemarkCopy];
                
                // Copia de vuelta informacion al placemark local como sincronizado
                [placemark shallowSetValuesFromItem:placemarkCopy];

                // Lo marca como para salvarlo
                placemark.needToBeSaved = TRUE;
                break;
                
            case MSS_Delete:
                // Crea una nueva instancia de placemark remoto y le copia informacion del local
                placemarkCopy = [placemark emptyInstanceLikeMeInMap:remoteMap];
                [placemarkCopy shallowSetValuesFromItem:placemark];

                // Actualiza el almacen
                [self removePlacemark:placemarkCopy];
                
                // Marca el local como borrado
                placemark.markedAsDeleted = TRUE;
                break;
        }
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _local_synchronizeMap:(GMSimpleMap *)map errRef:(NSErrorRef *)errRef {

    // No hay error inicial
    [NSError nilErrorRef:errRef];

    if(map.markedAsDeleted) {
        
        // Lo borra del almacen
        [self removeMap:map withPlacemarks:FALSE];

        // Borraria tambien del almacen todos sus placemarks
        [map.placemarks enumerateObjectsUsingBlock:^(GMSimplePlacemark *placemark, NSUInteger idx, BOOL *stop) {
            [self removePlacemark:placemark];
            placemark.markedAsDeleted = TRUE;
        }];

        
    } else{
        
        if (map.needToBeSaved) {
            
            // Se salva en el almacen
            if([self _searchMapByID:map.gID]==nil) {
                [self addMap:map withPlacemarks:FALSE];
            } else {
                [self updateMap:map withPlacemarks:FALSE];
            }
        }
        
        // Almacena tambien todos los placemarks del mapa
        [[map.placemarks copy] enumerateObjectsUsingBlock:^(GMSimplePlacemark *placemark, NSUInteger idx, BOOL *stop) {
            
            if(placemark.markedAsDeleted) {
                [placemark removeFromMap];
                [self removePlacemark:placemark];
            } else if(placemark.needToBeSaved) {
                GMSimplePlacemark *prevPlacemark = [self _searchPlacemarkByID:placemark.gID];
                if(!prevPlacemark) {
                    [self addPlacemark:placemark];
                } else {
                    [self updatePlacemark:placemark];
                }
            }
        }];

    }
    
    // Todo fue bien
    return TRUE;
    
}



@end
