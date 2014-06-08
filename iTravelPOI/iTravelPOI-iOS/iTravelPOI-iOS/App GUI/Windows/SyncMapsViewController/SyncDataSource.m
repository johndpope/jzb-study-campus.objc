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
#import "MPolyLine.h"
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
// Point AND GMTPolyLine methods
//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getLocalPointListForMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {
    
    // Retorna todos los puntos del mapa. Incluidos los marcados para borrar
    return localMap.points.allObjects;
}

//---------------------------------------------------------------------------------------------------------------------
- (GMTItem *) createRemotePointFrom:(id)localPoint error:(NSError * __autoreleasing *)err {
    
    if([localPoint isKindOfClass:MPolyLine.class]) {
        return [self _createRemotePolyLineFrom:localPoint error:err];
    } else {
        return [self _createRemotePointFrom:localPoint error:err];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateRemotePoint:(GMTItem *)remotePoint withLocalPoint:(id)localPoint error:(NSError * __autoreleasing *)err {
    
    if([localPoint isKindOfClass:MPolyLine.class]) {
        return [self _updateRemotePolyLine:(GMTPolyLine *)remotePoint withLocalPolyLine:localPoint error:err];
    } else {
        return [self _updateRemotePoint:(GMTPoint *)remotePoint withLocalPoint:localPoint error:err];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (id) createLocalPointFrom:(GMTItem *)gmPoint inLocalMap:(id)map error:(NSError * __autoreleasing *)err {
 
    if([gmPoint isKindOfClass:GMTPolyLine.class]) {
        return [self _createLocalPolyLineFrom:(GMTPolyLine *)gmPoint inLocalMap:map error:err];
    } else {
        return [self _createLocalPointFrom:(GMTPoint *)gmPoint inLocalMap:map error:err];
    }

}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalPoint:(id)localPoint withRemotePoint:(GMTItem *)remotePoint error:(NSError * __autoreleasing *)err {

    if([remotePoint isKindOfClass:GMTPolyLine.class]) {
        return [self _updateLocalPolyLine:localPoint withRemotePolyLine:(GMTPolyLine *)remotePoint error:err];
    } else {
        return [self _updateLocalPoint:localPoint withRemotePoint:(GMTPoint *)remotePoint error:err];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalPoint:(id)localPoint inLocalMap:(id)map error:(NSError * __autoreleasing *)err {

    if([localPoint isKindOfClass:MPolyLine.class]) {
        return [self _deleteLocalPolyLine:localPoint inLocalMap:map error:err];
    } else {
        return [self _deleteLocalPoint:localPoint inLocalMap:map error:err];
    }
   
}



//---------------------------------------------------------------------------------------------------------------------
// Point methods
//---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) _createRemotePointFrom:(MPoint *)localPoint error:(NSError * __autoreleasing *)err {
    
    GMTPoint *remotePoint = [GMTPoint emptyPointWithName:localPoint.name];
    [self _updateRemotePoint:remotePoint withLocalPoint:localPoint error:err];
    return  remotePoint;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _updateRemotePoint:(GMTPoint *)remotePoint withLocalPoint:(MPoint *)localPoint error:(NSError * __autoreleasing *)err {
    
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
- (MPoint *) _createLocalPointFrom:(GMTPoint *)gmPoint inLocalMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {
    
    MPoint *point = [MPoint emptyPointWithName:gmPoint.name inMap:localMap];
    BOOL ok = [self _updateLocalPoint:point withRemotePoint:gmPoint error:err];
    return ok?point:nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _updateLocalPoint:(MPoint *)localPoint withRemotePoint:(GMTPoint *)remotePoint error:(NSError * __autoreleasing *)err {
    
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
- (BOOL) _deleteLocalPoint:(MPoint *)localPoint inLocalMap:(id)map error:(NSError * __autoreleasing *)err {
    
    // El borrado en la sincronizacion es definitivo y lo elimina del almacen
    [localPoint deleteEntity];
    return TRUE;
}


//---------------------------------------------------------------------------------------------------------------------
// GMTPolyLine methods
//---------------------------------------------------------------------------------------------------------------------
- (GMTPolyLine *) _createRemotePolyLineFrom:(MPolyLine *)localPolyLine error:(NSError * __autoreleasing *)err {
    
    GMTPolyLine *remotePolyLine = [GMTPolyLine emptyPolyLineWithName:localPolyLine.name];
    [self _updateRemotePolyLine:remotePolyLine withLocalPolyLine:localPolyLine error:err];
    return  remotePolyLine;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _updateRemotePolyLine:(GMTPolyLine *)remotePolyLine withLocalPolyLine:(MPolyLine *)localPolyLine error:(NSError * __autoreleasing *)err {
    
    remotePolyLine.gID = localPolyLine.gID;
    remotePolyLine.etag = localPolyLine.etag;
    remotePolyLine.name = localPolyLine.name;
    remotePolyLine.descr = [localPolyLine combinedDescAndTagsInfo];
    
    [remotePolyLine.coordinates removeAllObjects];
    
    for(MCoordinate *coord in localPolyLine.coordinates) {
        [remotePolyLine addCoordWithLatitude:coord.latitudeValue andLongitude:coord.longitudeValue];
    }
    
    remotePolyLine.color = localPolyLine.color;

    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (id) _createLocalPolyLineFrom:(GMTPolyLine *)gmPolyLine inLocalMap:(MMap *)map error:(NSError * __autoreleasing *)err {
    
    MPolyLine *polyLine = [MPolyLine emptyPolyLineWithName:gmPolyLine.name inMap:map];
    BOOL ok = [self _updateLocalPolyLine:polyLine withRemotePolyLine:gmPolyLine error:err];
    return ok?polyLine:nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _updateLocalPolyLine:(MPolyLine *)localPolyLine withRemotePolyLine:(GMTPolyLine *)remotePolyLine error:(NSError * __autoreleasing *)err {
    
    [localPolyLine updateGID:remotePolyLine.gID andETag:remotePolyLine.etag];
    [localPolyLine updateName:remotePolyLine.name];
    [localPolyLine updateFromCombinedDescAndTagsInfo:remotePolyLine.descr];
    
    [localPolyLine setCoordinatesFromLocations:remotePolyLine.coordinates];
    
    [localPolyLine setColor:remotePolyLine.color];
    
    [localPolyLine markAsSynchronized];
    
    return  TRUE;
    
}
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _deleteLocalPolyLine:(MPolyLine *)localPolyLine inLocalMap:(id)map error:(NSError * __autoreleasing *)err {
    
    // El borrado en la sincronizacion es definitivo y lo elimina del almacen
    [localPolyLine deleteEntity];
    return TRUE;
    
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------



@end

