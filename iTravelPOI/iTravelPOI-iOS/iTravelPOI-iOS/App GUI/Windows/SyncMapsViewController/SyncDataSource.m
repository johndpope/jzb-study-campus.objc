//
//  SyncDataSource.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 28/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#define __SyncDataSource__IMPL__
#import "SyncDataSource.h"
#import "MMap.h"
#import "MPoint.h"
#import "MIcon.h"
#import "MTag.h"
#import "NSString+JavaStr.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface SyncDataSource()



@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation SyncDataSource




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark <GMPSyncDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
// Map methods
- (NSArray *) getAllLocalMapList:(NSError * __autoreleasing *)err {
    
    NSArray *allMapsList = [MMap allMapsinContext:self.moContext includeMarkedAsDeleted:TRUE];
    return  allMapsList;
}

//---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) createRemoteMapFrom:(MMap *)localMap error:(NSError * __autoreleasing *)err {
    
    GMTMap *remoteMap = [GMTMap emptyMapWithName:localMap.name];
    [self updateRemoteMap:remoteMap withLocalMap:localMap error:err];
    return  remoteMap;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateRemoteMap:(GMTMap *)remoteMap withLocalMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {
    
    remoteMap.gID = localMap.gID;
    remoteMap.etag = localMap.etag;
    remoteMap.name = localMap.name;
    remoteMap.summary = localMap.summary;
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (MMap *) createLocalMapFrom:(GMTMap *)gmMap error:(NSError * __autoreleasing *)err {
    
    MMap *localMap = [MMap emptyMapWithName:gmMap.name inContext:self.moContext];
    BOOL ok = [self updateLocalMap:localMap withRemoteMap:gmMap allPointsOK:TRUE error:err];
    return  ok?localMap:nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalMap:(MMap *)localMap withRemoteMap:(GMTMap *)remoteMap allPointsOK:(BOOL)allPointsOK error:(NSError * __autoreleasing *)err {
    
    [localMap updateName:remoteMap.name];
    [localMap updateSummary:remoteMap.summary];
    [localMap updateGID:remoteMap.gID andETag:remoteMap.etag];
    
    // Si NO hubo NINGUN problema con los puntos lo deja marcado como "sincronizado".
    // En otro caso como "modificado" para forzar que se vuelva a sincronizar
    if(allPointsOK) {
        [localMap markAsSynchronized];
    } else {
        [localMap markAsModified];
    }
    
    return  TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {
    
    // El borrado en la sincronizacion es definitivo y lo elimina del almacen
    [localMap deleteEntity];
    return  TRUE;
}


//---------------------------------------------------------------------------------------------------------------------
// Point methods
- (NSArray *) getLocalPointListForMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {
    
    // Retorna todos los puntos del mapa. Incluidos los marcados para borrar
    return localMap.points.allObjects;
}

//---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) createRemotePointFrom:(MPoint *)localPoint error:(NSError * __autoreleasing *)err {
    
    GMTPoint *remotePoint = [GMTPoint emptyPointWithName:localPoint.name];
    [self updateRemotePoint:remotePoint withLocalPoint:localPoint error:err];
    return  remotePoint;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateRemotePoint:(GMTPoint *)remotePoint withLocalPoint:(MPoint *)localPoint error:(NSError * __autoreleasing *)err {
    
    remotePoint.gID = localPoint.gID;
    remotePoint.etag = localPoint.etag;
    remotePoint.name = localPoint.name;
    remotePoint.descr = [localPoint combinedDescAndTagsInfo];
    remotePoint.latitude = localPoint.latitudeValue;
    remotePoint.longitude = localPoint.longitudeValue;
    remotePoint.iconHREF = localPoint.icon.iconHREF;
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (MPoint *) createLocalPointFrom:(GMTPoint *)gmPoint inLocalMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {
    
    MPoint *point = [MPoint emptyPointWithName:gmPoint.name inMap:localMap];
    BOOL ok = [self updateLocalPoint:point withRemotePoint:gmPoint error:err];
    return ok?point:nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalPoint:(MPoint *)localPoint withRemotePoint:(GMTPoint *)remotePoint error:(NSError * __autoreleasing *)err {
    
    [localPoint updateGID:remotePoint.gID andETag:remotePoint.etag];
    [localPoint updateName:remotePoint.name];
    [localPoint updateFromCombinedDescAndTagsInfo:remotePoint.descr];
    [localPoint updateLatitude:remotePoint.latitude longitude:remotePoint.longitude];
    
    MIcon *icon = [MIcon iconForHref:remotePoint.iconHREF inContext:localPoint.managedObjectContext];
    [localPoint updateIcon:icon];
    
    [localPoint markAsSynchronized];

    return  TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalPoint:(MPoint *)localPoint inLocalMap:(id)map error:(NSError * __autoreleasing *)err {
    
    // El borrado en la sincronizacion es definitivo y lo elimina del almacen
    [localPoint deleteEntity];
    return TRUE;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------



@end

