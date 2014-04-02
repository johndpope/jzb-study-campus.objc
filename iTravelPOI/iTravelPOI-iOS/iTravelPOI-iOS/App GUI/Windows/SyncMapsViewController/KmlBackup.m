//
//  KmlBackup.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 28/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#define __KmlBackup__IMPL__
#import "KmlBackup.h"
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
@interface KmlBackup()



@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation KmlBackup




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
#pragma mark <GMPKmlBackup> protocol methods
//---------------------------------------------------------------------------------------------------------------------
// Map methods
- (NSArray *) getAllLocalMapList:(NSError **)err {
    
    NSArray *allMapsList = [MMap allMapsinContext:self.moContext includeMarkedAsDeleted:TRUE];
    return  allMapsList;
}

//---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) createRemoteMapFrom:(MMap *)localMap error:(NSError **)err {
    
    GMTMap *remoteMap = [GMTMap emptyMapWithName:localMap.name];
    [self updateRemoteMap:remoteMap withLocalMap:localMap error:err];
    return  remoteMap;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateRemoteMap:(GMTMap *)remoteMap withLocalMap:(MMap *)localMap error:(NSError **)err {
    
    remoteMap.gID = localMap.gID;
    remoteMap.etag = localMap.etag;
    remoteMap.name = localMap.name;
    remoteMap.summary = localMap.summary;
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (MMap *) createLocalMapFrom:(GMTMap *)gmMap error:(NSError **)err {
    
    MMap *localMap = [MMap emptyMapWithName:gmMap.name inContext:self.moContext];
    BOOL ok = [self updateLocalMap:localMap withRemoteMap:gmMap allPointsOK:TRUE error:err];
    return  ok?localMap:nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalMap:(MMap *)localMap withRemoteMap:(GMTMap *)remoteMap allPointsOK:(BOOL)allPointsOK error:(NSError **)err {
    
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
- (BOOL) deleteLocalMap:(MMap *)localMap error:(NSError **)err {
    
    // El borrado en la sincronizacion es definitivo y lo elimina del almacen
    [localMap deleteEntity];
    return  TRUE;
}


//---------------------------------------------------------------------------------------------------------------------
// Point methods
- (NSArray *) getLocalPointListForMap:(MMap *)localMap error:(NSError **)err {
    
    // Retorna todos los puntos del mapa. Incluidos los marcados para borrar
    return localMap.points.allObjects;
}

//---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) createRemotePointFrom:(MPoint *)localPoint error:(NSError **)err {
    
    GMTPoint *remotePoint = [GMTPoint emptyPointWithName:localPoint.name];
    [self updateRemotePoint:remotePoint withLocalPoint:localPoint error:err];
    return  remotePoint;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateRemotePoint:(GMTPoint *)remotePoint withLocalPoint:(MPoint *)localPoint error:(NSError **)err {
    
    remotePoint.gID = localPoint.gID;
    remotePoint.etag = localPoint.etag;
    remotePoint.name = localPoint.name;
    [self _updateTagsAndDescInGMapPoint:remotePoint fromPoint:localPoint];
    remotePoint.latitude = localPoint.latitudeValue;
    remotePoint.longitude = localPoint.longitudeValue;
    remotePoint.iconHREF = localPoint.icon.iconHREF;
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (MPoint *) createLocalPointFrom:(GMTPoint *)gmPoint inLocalMap:(MMap *)localMap error:(NSError **)err {
    
    MPoint *point = [MPoint emptyPointWithName:gmPoint.name inMap:localMap];
    BOOL ok = [self updateLocalPoint:point withRemotePoint:gmPoint error:err];
    return ok?point:nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalPoint:(MPoint *)localPoint withRemotePoint:(GMTPoint *)remotePoint error:(NSError **)err {
    
    [localPoint updateGID:remotePoint.gID andETag:remotePoint.etag];
    [localPoint updateName:remotePoint.name];

    [self _updateTagsAndDescInPoint:localPoint fromGMapPoint:remotePoint];
    [localPoint updateLatitude:remotePoint.latitude longitude:remotePoint.longitude];
    
    MIcon *icon = [MIcon iconForHref:remotePoint.iconHREF inContext:localPoint.managedObjectContext];
    [localPoint updateIcon:icon];
    
    [localPoint markAsSynchronized];

    return  TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalPoint:(MPoint *)localPoint inLocalMap:(id)map error:(NSError **)err {
    
    // El borrado en la sincronizacion es definitivo y lo elimina del almacen
    [localPoint deleteEntity];
    return TRUE;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _updateTagsAndDescInGMapPoint:(GMTPoint *)gmPoint fromPoint:(MPoint *)point {

    NSMutableString *tagsText = [NSMutableString stringWithString:@""];
    BOOL first = TRUE;
    for(MTag *tag in point.directNoAutoTags) {
        if(first) {
            [tagsText appendString:tag.name];
        } else {
            [tagsText appendFormat:@", %@", tag.name];
        }
        first = FALSE;
    }

    gmPoint.descr = [NSString stringWithFormat:@"$[%@]$%@",tagsText,point.descr];
    
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _updateTagsAndDescInPoint:(MPoint *)point fromGMapPoint:(GMTPoint *)gmPoint {
    
    NSString *text=gmPoint.descr;
    
    // Borra los tags actuales porque, en cualquier caso, los tags vendran del punto remoto
    for(MTag *tag in [point.directNoAutoTags copy]) {
        [tag untagPoint:point];
    }
    
    // Primero elimina la informacion previa
    NSUInteger p1 = [text indexOf:@"$["];
    NSUInteger p2 = [text indexOf:@"]$"];
    if(p1==NSNotFound || p2==NSNotFound || p1>=p2) {
        
        // Pone la descripcion tal cual esta en el GMTPoint
        [point updateDesc:text];
        
    } else {
        
        NSString *txt1 = [text subStrFrom:0 to:p1];
        NSString *txt2 = [text subStrFrom:2+p2];
        
        // Extrae la descripcion "limpia"
        NSString *cleanDesc = [NSString stringWithFormat:@"%@%@",txt1, txt2];
        [point updateDesc:cleanDesc];

        // Extrae la informacion de los tags
        NSString *tagsStr = [text subStrFrom:2+p1 to:p2];
        NSArray *tagNames = [tagsStr componentsSeparatedByString:@","];
        for(NSString *tagName in tagNames) {
            MTag *tag = [MTag tagWithFullName:tagName inContext:self.moContext];
            [tag tagPoint:point];
        }
    }
    
    
}

@end

