//
// GMSynchronizerBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "GMSynchronizer.h"
#import "GMComparer.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSynchronizer Interface Private Definition
// *********************************************************************************************************************
@interface GMSynchronizer ()

@property (strong, nonatomic) id<GMDataStorage> localStorage;
@property (strong, nonatomic) id<GMDataStorage> remoteStorage;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMSynchronizer Implementation
// *********************************************************************************************************************
@implementation GMSynchronizer




// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMSynchronizer *) synchronizerWithLocalStorage:(id<GMDataStorage>) localStorage remoteStorage:(id<GMDataStorage>) remoteStorage {
   
    GMSynchronizer *me = [[GMSynchronizer alloc] init];
    me.localStorage = localStorage;
    me.remoteStorage = remoteStorage;
    return me;
}


// =====================================================================================================================
#pragma mark -
#pragma mark PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) syncronizeStorages {

    NSError *localError = nil;
    
    
    // Consigue la lista de mapas locales
    NSArray *localMaps = [self.localStorage retrieveMapList:&localError];
    if(!localMaps) return;

    
    // Consigue la lista de mapas remotos
    NSArray *remoteMaps = [self.remoteStorage retrieveMapList:&localError];
    if(!remoteMaps) return;
    
    
    // Compara las dos listas de mapas
    NSArray *tuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];

    
    // Procesa todas las tupla que indiquen que ambos mapas no son iguales
    for(GMCompareTuple *tuple in tuples) {
        if(tuple.compStatus!=CS_Equals) {
            [self _processMapTuple:tuple];
        }
    }
    
}



// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) _processMapTuple:(GMCompareTuple *)mapTuple {
    
    
    NSError *localError = nil;
    BOOL rc = FALSE;
    
    
    // ¿COMO LE DIGO AL LOCAL STORAGE QUE PREPARE EL MAPA EN UN CHILD-CTX?
    
    // Sincroniza dependiendo del resultado de la comparacion
    switch (mapTuple.compStatus) {

        case CS_Equals:
            // Nada que hacer
            break;
            
        case CS_DeleteLocal:
            mapTuple.local.markedAsDeleted = TRUE;
            break;

        case CS_CreateLocal:
            mapTuple.local = [self.localStorage.itemFactory newMapWithName:@"" errRef:&localError];
            [mapTuple.local shallowSetValuesFromItem:mapTuple.remote];
            [self _synchronizePlacemarksInTuple:mapTuple errRef:&localError];
            break;
            
        case CS_UpdateLocal:
            [mapTuple.local shallowSetValuesFromItem:mapTuple.remote];
            [self _synchronizePlacemarksInTuple:mapTuple errRef:&localError];
            break;
            
        case CS_DeleteRemote:
            // Nada que hacer
            break;

        case CS_CreateRemote:
            // Nada que hacer
            break;
    
        case CS_UpdateRemote:
            [self _synchronizePlacemarksInTuple:mapTuple errRef:&localError];
            break;
    }

    // Sincroniza cambios en el storage remoto
    rc = [self.remoteStorage synchronizeMap:(id<GMMap>)mapTuple.local errRef:&localError];

    // Sincroniza cambios en el storage local
    rc = [self.localStorage synchronizeMap:(id<GMMap>)mapTuple.local errRef:&localError];
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _synchronizePlacemarksInTuple:(GMCompareTuple *)mapTuple errRef:(NSErrorRef *) errRef {
    
    
    // De inicio no hay error
    [NSError nilErrorRef:errRef];
    
    
    // Prepara la informacion de los mapas por comodidad
    id<GMMap> localMap = (id<GMMap>)mapTuple.local;
    id<GMMap> remoteMap = (id<GMMap>)mapTuple.remote;
    
    
    // Consigue la lista de placemarks locales
    if(![self.localStorage retrievePlacemarksForMap:localMap errRef:errRef]) {
        return FALSE;
    }

    // Consigue la lista de placemarks remotos
    if(![self.remoteStorage retrievePlacemarksForMap:remoteMap errRef:errRef]) {
        return FALSE;
    }

    
    // Compara las dos listas de mapas
    NSArray *tuples = [GMComparer compareLocalItems:localMap.placemarks toRemoteItems:remoteMap.placemarks];
    
    
    // Procesa todas las tupla que indiquen que ambos mapas no son iguales
    for(GMCompareTuple *tuple in tuples) {
        if(tuple.compStatus!=CS_Equals) {
            BOOL rc = [self _processPlacemarkTuple:tuple localMap:localMap errRef:errRef];
        }
    }
    
    // Todo ha ido bien
    return TRUE;

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _processPlacemarkTuple:(GMCompareTuple *)placemarkTuple localMap:(id<GMMap>)localMap errRef:(NSErrorRef *) errRef {
    
    
    // Sincroniza dependiendo del resultado de la comparacion
    switch (placemarkTuple.compStatus) {
            
        case CS_Equals:
        case CS_DeleteRemote:
        case CS_CreateRemote:
        case CS_UpdateRemote:
            // Nada que hacer
            break;
            
        case CS_DeleteLocal:
            // Marca el placemark como borrado
            placemarkTuple.local.markedAsDeleted = TRUE;
            break;
            
        case CS_CreateLocal:
            // Crea una instancia local
            if([placemarkTuple.remote conformsToProtocol:@protocol(GMPoint)]) {
                placemarkTuple.local = [self.localStorage.itemFactory newPointWithName:@"" inMap:localMap errRef:errRef];
                
            } else if([placemarkTuple.remote conformsToProtocol:@protocol(GMPolyLine)]) {
                placemarkTuple.local = [self.localStorage.itemFactory newPolyLineWithName:@"" inMap:localMap errRef:errRef];
                
            } else {
                [NSError setErrorRef:errRef domain:@"GMSynchronizer" reason:@"Unknown placemark class: %@", placemarkTuple.remote.class];
                return FALSE;
            }
            
            // Sincroniza la informacion desde el placemark remoto
            [placemarkTuple.local shallowSetValuesFromItem:placemarkTuple.remote];
            break;
            
        case CS_UpdateLocal:
            // Sincroniza la informacion desde el placemark remoto
            [placemarkTuple.local shallowSetValuesFromItem:placemarkTuple.remote];
            break;
    }
    
    // Todo ha ido bien si hay un elemento local
    return (placemarkTuple.local!=nil);

}



@end
