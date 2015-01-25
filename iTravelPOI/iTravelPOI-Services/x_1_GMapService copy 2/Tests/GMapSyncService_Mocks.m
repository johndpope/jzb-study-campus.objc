//
//  GMapSyncService_Mocks.m
//  iTravelPOI-MacTests
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <OCMock/OCMock.h>
#import "GMapSyncService_Mocks.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Tests private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------
#define MOCK_MAP_NAME_PREFIX @"@MOCK_MAP_"




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncService_Mocks private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface Mock_GMPSyncDataSource ()

@property (strong, nonatomic) NSMutableDictionary *localMaps;
@property (strong, nonatomic) NSMutableDictionary *localPlacemarks;
@property (strong, nonatomic) GMapService *gmapService;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncService_Mocks implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation Mock_GMPSyncDataSource


// ---------------------------------------------------------------------------------------------------------------------
+ (Mock_GMPSyncDataSource *) newInstance {

    Mock_GMPSyncDataSource *me = [[Mock_GMPSyncDataSource alloc] init];
    me.localMaps = [NSMutableDictionary dictionary];
    me.localPlacemarks = [NSMutableDictionary dictionary];
    return me;
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public methods
// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) __mock_newLocalMapWithName:(NSString *)name fakeSynced:(BOOL)fakeSynced {
    
    NSString *fullMapName = [NSString stringWithFormat:@"%@%@",MOCK_MAP_NAME_PREFIX,name];
    
    GMTMap *localMap = [GMTMap emptyMapWithName:fullMapName];
    localMap.modifiedSinceLastSyncValue = TRUE;
    if(fakeSynced) {
        localMap.gID = [NSString stringWithFormat:@"fake-remote-gID-%@", localMap.name];
        localMap.etag = [NSString stringWithFormat:@"fake-remote-ETag-%@", localMap.name];
    } else {
        [localMap setLocalNoSyncValues];
    }
    
    [self.localMaps setValue:localMap forKey:localMap.gID];
    
    return localMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPlacemark *) __mock_newLocalPointWithName:(NSString *)name inMap:(GMTMap *)localMap {
    
    GMTPoint *localPoint = [GMTPoint emptyPointWithName:name];
    localPoint.modifiedSinceLastSyncValue = TRUE;
    
    NSMutableDictionary *placemarks = [self __placemarksForMap:localMap];
    [placemarks setValue:localPoint forKey:localPoint.gID];
    
    return localPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) __mock_getAllLocalMapList {
    return [self.localMaps allValues];
}



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark GMPSyncDataSource protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSMutableDictionary *) __placemarksForMap:(GMTMap *)localMap {
    
    NSMutableDictionary *placemarks = [self.localPlacemarks objectForKey:localMap.gID];
    if(placemarks==nil) {
        placemarks = [NSMutableDictionary dictionary];
        [self.localPlacemarks setObject:placemarks forKey:localMap.gID];
    }
    
    return placemarks;
}

// ---------------------------------------------------------------------------------------------------------------------
// Maps methods
- (NSArray *) getAllLocalMapList:(NSError * __autoreleasing *)err {
    return [self __mock_getAllLocalMapList];
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) newRemoteMapFrom:(id)localMap error:(NSError * __autoreleasing *)err {
    
    GMTMap *remoteMap = [GMTMap emptyMap];
    [remoteMap copyValuesFromItem:localMap];
    return remoteMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) setRemoteMap:(GMTMap *)remoteMap fromLocalMap:(id)localMap error:(NSError * __autoreleasing *)err {
    
    [[NSException exceptionWithName:@"MethodNotImplemented" reason:@"Method not implemented in mock: setRemoteMap" userInfo:nil] raise];
    return FALSE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalMapFrom:(GMTMap *)remoteMap error:(NSError * __autoreleasing *)err {
    
    GMTMap *localMap = [GMTMap emptyMap];
    [self updateLocalMap:localMap withRemoteMap:remoteMap allPlacemarksOK:YES error:err];
    return localMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalMap:(GMTMap *)localMap withRemoteMap:(GMTMap *)remoteMap allPlacemarksOK:(BOOL)allPlacemarksOK error:(NSError * __autoreleasing *)err {
    
    // Si el mapa ha cambiado de gID (local a remoto)
    if(![localMap.gID isEqualToString:remoteMap.gID]) {
        
        // Mueve los placemark a la nueva clave
        NSMutableDictionary *placemarks = [self __placemarksForMap:localMap];
        [self.localPlacemarks setObject:placemarks forKey:remoteMap.gID];
        [self.localPlacemarks removeObjectForKey:localMap.gID];
        
        // Tambien lo elimina de la lista de mapas con el actual gID
        [self.localMaps removeObjectForKey:localMap.gID];
    }
    
    [localMap copyValuesFromItem:remoteMap];
    
    // Que quede sincronizado dependera de si todos los puntos se sincronizaron bien
    localMap.modifiedSinceLastSyncValue = (allPlacemarksOK != YES);
    
    [self.localMaps setObject:localMap forKey:localMap.gID];
    
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalMap:(GMTMap *)localMap error:(NSError * __autoreleasing *)err {
    
    [self.localMaps removeObjectForKey:localMap.gID];
    [self.localPlacemarks removeObjectForKey:localMap.gID];
    return TRUE;
}


// ---------------------------------------------------------------------------------------------------------------------
// Placemark methods
- (NSArray *) getLocalPlacemarkListForMap:(id)localMap error:(NSError * __autoreleasing *)err {
    
    NSDictionary *placemarks = [self __placemarksForMap:localMap];
    return [placemarks allValues];
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPlacemark *) newRemotePlacemarkFrom:(id)localPlacemark inLocalMap:(id)map error:(NSError * __autoreleasing *)err {

    [[NSException exceptionWithName:@"MethodNotImplemented" reason:@"Method not implemented in mock: newRemotePlacemarkFrom" userInfo:nil] raise];
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) setRemotePlacemark:(GMTPlacemark *)remotePlacemark fromLocalPlacemark:(id)localPlacemark inLocalMap:(id)map error:(NSError * __autoreleasing *)err {
    
    [[NSException exceptionWithName:@"MethodNotImplemented" reason:@"Method not implemented in mock: setRemotePlacemark" userInfo:nil] raise];
    return FALSE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalPlacemarkFrom:(GMTPlacemark *)remotePlacemark inLocalMap:(GMTMap *)localMap error:(NSError * __autoreleasing *)err {
    
    GMTPoint *localPoint = [GMTPoint emptyPoint];
    [self updateLocalPlacemark:localPoint inLocalMap:localMap withRemotePlacemark:remotePlacemark error:err];
    return localPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalPlacemark:(GMTPlacemark *)localPlacemark inLocalMap:(GMTMap *)localMap withRemotePlacemark:(GMTPlacemark *)remotePlacemark error:(NSError * __autoreleasing *)err {

    NSMutableDictionary *placemarks = [self __placemarksForMap:localMap];
    
    // Si el placememark ha cambiado de gID (local a remoto)
    if(![localPlacemark.gID isEqualToString:remotePlacemark.gID]) {
        
        // Lo elimina de la lista de mapas con el actual gID
        [placemarks removeObjectForKey:localPlacemark.gID];
    }
    
    [localPlacemark copyValuesFromItem:remotePlacemark];
    localPlacemark.modifiedSinceLastSyncValue = NO;
    
    [placemarks setObject:localPlacemark forKey:localPlacemark.gID];
    
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalPlacemark:(id)localPlacemark inLocalMap:(id)map error:(NSError * __autoreleasing *)err {

    [[NSException exceptionWithName:@"MethodNotImplemented" reason:@"Method not implemented in mock: deleteLocalPlacemark" userInfo:nil] raise];
    return FALSE;
}



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------


@end




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncService_Mocks private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface Mock_GMapService ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncService_Mocks implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation Mock_GMapService


// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithEmail:(NSString *)email password:(NSString *)password error:(NSError * __autoreleasing *)err {
    
    
    DDLogVerbose(@"Mock_GMapService - initWithEmailAndPassword");
    
    if ( self = [super initWithEmail:email password:password error:err] ) {
    }
    return self;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (Mock_GMapService *) serviceWithEmail2:(NSString *)email password:(NSString *)password error:(NSError * __autoreleasing *)err {
   
    Mock_GMapService *me = [[Mock_GMapService alloc] initWithEmail:email password:password error:err];
    return me;
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getMapList:(NSError * __autoreleasing *)err {
    
    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;
    
    NSMutableArray *filteredMapList = nil;
    
    NSArray *mapsList = [super getMapList:err];
    if(localError || !mapsList) {
        return nil;
    }
    
    filteredMapList = [NSMutableArray array];
    for(GMTMap *map in mapsList) {
        if([map.name hasPrefix:MOCK_MAP_NAME_PREFIX]) {
            [filteredMapList addObject:map];
        }
    }
    
    return filteredMapList;
}

@end

