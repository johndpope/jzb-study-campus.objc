//
// GMRemoteService.m
// GMRemoteService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMRemoteService_IMPL__
#import "GMRemoteService.h"
#import "GMFeedProcessor.h"
#import "GMItemValidator.h"
#import "GMAtomGenerator.h"

#import "DDLog.h"
#import "GMapDataHttpFetcher.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
#define URL_FETCH_ALL_MAPS @"http://maps.google.com/maps/feeds/maps/default/owned?max-results=999999"
#define URL_ADD_NEW_MAP    @"http://maps.google.com/maps/feeds/maps/default/full"

typedef enum {
    SS_Nothing = 0,
    SS_Create  = 1,
    SS_Update  = 2,
    SS_Delete  = 3
} GMSyncStatus;

#define BATCH_TYPE_INSERT @"insert"
#define BATCH_TYPE_DELETE @"delete"






// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMRemoteService ()

@property (strong, nonatomic) id<GMItemFactory> itemFactory;
@property (strong, nonatomic) GMapDataHttpFetcher *httpDataFetcher;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMRemoteService



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithEmail:(NSString *)email password:(NSString *)password itemFactory:(id<GMItemFactory>)itemFactory errRef:(NSErrorRef *)errRef {

    DDLogVerbose(@"GMRemoteService - initWithEmailAndPassword");
    
    if ( self = [super init] ) {
        self.itemFactory = itemFactory;
        self.httpDataFetcher = [[GMapDataHttpFetcher alloc] init];
        BOOL rc = [self.httpDataFetcher loginWithEmail:email password:password errRef:errRef];
        if(rc==NO) {
            self = nil;
        }
    }
    return self;
}




// =====================================================================================================================
#pragma mark -
#pragma mark GMDataStorage Protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) retrieveMapList:(NSErrorRef *)errRef {
    
    
    // ------------------------------------------------------------------------------
    // URL con el formato:URL_FETCH_ALL_MAPS
    // ------------------------------------------------------------------------------

    
    DDLogVerbose(@"GMRemoteService - retrieveMapList");

    
    // Establece que no hay un error
    [NSError nilErrorRef:errRef];

    
    // Invoca al servicio remoto
    NSDictionary *result = [self.httpDataFetcher gmapGET:URL_FETCH_ALL_MAPS errRef:errRef];
    if(!result) return nil;

    
    // Comprueba que hubo una respuesta correcta
    if([result valueForKeyPath:@"feed"]==nil) {
        [NSError setErrorRef:errRef domain:@"GMRemoteService" reason:@"Invalid answer received for 'retrieveMapList': %@",result];
        return nil;
    }

    
    // Busca en el feed las entradas de los mapas
    // Si solo hay un elemento no retorna un array, sino un diccionario
    NSArray *feedEntries = [result valueForKeyPath:@"feed.entry"];
    if([feedEntries isKindOfClass:[NSDictionary class]]) {
        feedEntries = [NSArray arrayWithObject:feedEntries];
    }
    
    // Procesa las feedEntries con los mapas
    NSMutableArray *maps = [NSMutableArray array];
    for(NSDictionary *mapFeedDict in feedEntries) {

        id<GMMap> map = [self.itemFactory newMapWithName:@"" errRef:errRef];
        
        [GMFeedProcessor setItemValues:map fromFeed:mapFeedDict];
        
        if(![GMItemValidator validateFieldsAreNotNil:map errRef:errRef]) {
            return nil;
        }

        [maps addObject:map];
    }
    
    // Retorna los mapas leidos
    return maps;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) retrievePlacemarksForMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef {
    
    
    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full
    // --------------------------------------------------------------------------------

    
    DDLogVerbose(@"GMRemoteService - retrievePlacemarksForMap");
    
    
    // Establece que no hay un error
    [NSError nilErrorRef:errRef];

    
    // No se hace nada si el mapa es nulo
    if(!map) return TRUE;
    
    
    // Invoca al servicio remoto
    NSString *featuresURL = [self _featuresURLForMap:map];
    NSDictionary *result = [self.httpDataFetcher gmapGET:[NSString stringWithFormat:@"%@?max-results=999999", featuresURL] errRef:errRef];
    if(!result) return FALSE;
    
    
    // Comprueba que hubo una respuesta correcta
    if([result valueForKeyPath:@"atom:feed"]==nil) {
        [NSError setErrorRef:errRef domain:@"GMRemoteService" reason:@"Invalid answer received for 'retrievePlacemarksForMap': %@",result];
        return FALSE;
    }
    
    
    // Busca en el feed las entradas de los placemarks
    // Si solo hay un elemento no retorna un array, sino un diccionario
    NSArray *feedEntries = [result valueForKeyPath:@"atom:feed.atom:entry"];
    if([feedEntries isKindOfClass:[NSDictionary class]]) {
        feedEntries = [NSArray arrayWithObject:feedEntries];
    }
    
    // Procesa las feedEntries con los placemarks
    NSMutableArray *allPlacemarks = [NSMutableArray array];
    for(NSDictionary *placemarkFeedDict in feedEntries) {

        id<GMPlacemark> placemark = [GMFeedProcessor emptyPlacemarkFromFeed:placemarkFeedDict itemFactory:self.itemFactory inMap:map errRef:errRef];

        if(placemark) {
            [GMFeedProcessor setItemValues:placemark fromFeed:placemarkFeedDict];

            if(![GMItemValidator validateFieldsAreNotNil:placemark errRef:errRef]) {
                return FALSE;
            }
        }
        
        [allPlacemarks addObject:placemark];
    }
    
    
    // Retorna los placemarks leidos
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id<GMMap>) retrieveMapByGID:(NSString *)mapGID errRef:(NSErrorRef *)errRef {
 
    
    // ------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/maps/userID/full/mapID
    // ------------------------------------------------------------------------------

    
    DDLogVerbose(@"GMRemoteService - retrieveMapByGID");
    
    
    // Establece que no hay un error
    [NSError nilErrorRef:errRef];
    
    
    // No se hace nada si el gID es nulo
    if(!mapGID) return nil;
    
    
    // Crea una instancia de mapa vacia y le fuerza el gID indicado
    id<GMMap> map = [self.itemFactory newMapWithName:@"" errRef:errRef];
    if(!map) return nil;
    map.gID = mapGID;

        
    // Invoca al servicio remoto
    NSDictionary *result = [self.httpDataFetcher gmapGET:[self _editLinkFor:map] errRef:errRef];
    if(!result) return nil;
    
    
    // Comprueba que hubo una respuesta correcta
    NSDictionary *feedEntry = [result objectForKey:@"entry"];
    if(feedEntry==nil) {
        [NSError setErrorRef:errRef domain:@"GMRemoteService" reason:@"Invalid answer received for 'retrieveMapByGID': ", result];
        return nil;
    }
    
    
    // Procesa el feedEntry con la informacion del item
    [GMFeedProcessor setItemValues:map fromFeed:feedEntry];
    
    if(![GMItemValidator validateFieldsAreNotNil:map errRef:errRef]) {
        return nil;
    }
    
    
    // Todo ha ido bien
    return map;
}

// ---------------------------------------------------------------------------------------------------------------------
// It should be able to process Maps created by another GMDataSource
- (BOOL) synchronizeMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef {
    
    
    DDLogVerbose(@"GMRemoteService - synchronizeMap [%@]", map.name);
    
    
    // !!!!! PARA QUE NO FALLE EL CHEQUEO DEL NOMBRE !!!!!!!!!!!!!!!!!!!!
    if([self _syncStatusForItem:map]==SS_Nothing) return TRUE;
    
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* CHEQUEO DE QUE ES UN MAPA SEGURO *************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __check_isSafeMapName__:map.name errRef:errRef]) return FALSE;


    
    
    // Primero valida el estado del mapa
    if(![GMItemValidator validateFieldsAreNotNil:map errRef:errRef]) return FALSE;

    
    // La sincronizacion (CRUD) depende del estado del mapa
    switch ([self _syncStatusForItem:map]) {
            
        case SS_Nothing:
            // NO HAY NADA QUE HACER PARA EL MAPA INDICADO
            return TRUE;
            
        case SS_Delete:
            // Borra el mapa (y con el sus placemarks)
            return [self _deleteItem:map errRef:errRef];

        case SS_Create:
            // Crea el elemento remoto sin placemarks si hace falta
            if(![self _addItem:map errRef:errRef]) return FALSE;
            break;
            
        case SS_Update:
            // Actualiza las modificaciones del mapa
            if(![self _updateItem:map errRef:errRef]) return FALSE;
            break;
    }
    
    
    // En otro caso procesa los placemarks del mapa
    BOOL rc = [self _synchronizePlacemarksInMap:map errRef:errRef];

    // Actualiza la informacion de gID & ETag del mapa tras la actualizacion de los placemarks
    if(rc) rc = [self _updateItem:map errRef:errRef];
    
    // Retorna el resultado
    return rc;
}



// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE ITEM CRUD methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _synchronizePlacemarksInMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef {
    

    DDLogVerbose(@"GMRemoteService - synchronizePlacemarksInMap [%@]", map.name);

    
    // Para no crear una cadena BATCH ATOM si no hay nada que procesar (solo cambio el propio mapa dueño)
    BOOL __block mustSyncronize = FALSE;
    [map.placemarks enumerateObjectsUsingBlock:^(id<GMPlacemark> placemark, NSUInteger idx, BOOL *stop) {
        mustSyncronize = !placemark.wasSynchronized || placemark.markedAsDeleted || placemark.markedForSync;
        *stop = mustSyncronize == TRUE;
    }];
    if(!mustSyncronize) return TRUE;
    
    
    // NOTA: HAY UN BUG EN EL SERVICIO GOOGLE-MAPS Y NO FUNCIONAN LOS UPDATES BATCH
    NSMutableArray *placemarksToUpdate = [NSMutableArray array];
    
    NSMutableDictionary *itemByIDs = [NSMutableDictionary dictionary];
    NSString *atomStr = [self _batchCreateAtomStringForMap:map itemByIDs:itemByIDs placemarksToUpdate:placemarksToUpdate errRef:errRef];
    if(!atomStr) return FALSE;
    
    
    // Procesa los placemark a actualizar de forma individual
    for(id<GMPlacemark> placemark in placemarksToUpdate) {
        if(![self _updateItem:placemark errRef:errRef]) return FALSE;
    }
    
 
    // Invoca al servicio remoto con la peticion batch
    NSString *batchURL = [NSString stringWithFormat:@"%@/batch", [self _featuresURLForMap:map]];
    NSDictionary *result = [self.httpDataFetcher gmapPOST:batchURL feedData:atomStr errRef:errRef];
    if(!result) return FALSE;
    
    
    // Procesa el FEED BATCH de respuesta
    return [self _batchProcessFeed:result itemByIDs:itemByIDs errRef:errRef];
}


// ---------------------------------------------------------------------------------------------------------------------
// NOTA: HAY UN BUG EN EL SERVICIO GOOGLE-MAPS Y NO FUNCIONAN LOS UPDATES BATCH
- (NSString *) _batchCreateAtomStringForMap:(id<GMMap>)map itemByIDs:(NSMutableDictionary *)itemByIDs placemarksToUpdate:(NSMutableArray *)placemarksToUpdate errRef:(NSErrorRef *)errRef {
    
    NSMutableString *atomStr = [NSMutableString string];
    
    // Cabecera del ATOM
    [atomStr appendString:@"<?xml version='1.0' encoding='UTF-8'?>\n"];
    [atomStr appendString:@"<atom:feed xmlns='http://www.opengis.net/kml/2.2'\n"];
    [atomStr appendString:@"           xmlns:atom='http://www.w3.org/2005/Atom'\n"];
    [atomStr appendString:@"           xmlns:gd='http://schemas.google.com/g/2005'\n"];
    [atomStr appendString:@"           xmlns:batch='http://schemas.google.com/gdata/batch'>\n"];
    
    
    // Itera todos los elementos para construir el ATOM a enviar
    int id_index = 0;
    NSString *type, *batch_item_id, *itemAtomStr;
    for(id<GMPlacemark> placemark in map.placemarks) {
        
        // Primero valida el estado del placemark
        if(![GMItemValidator validateFieldsAreNotNil:placemark errRef:errRef]) return nil;

        // La sincronizacion (CRUD) depende del estado del mapa
        GMSyncStatus SyncStatus = [self _syncStatusForItem:placemark];
        switch (SyncStatus) {
                
            case SS_Nothing:
                // NO HAY NADA QUE HACER PARA EL PLACEMARK INDICADO
                break;
                
            case SS_Update:
                // Actualiza el placemark de forma individual
                [placemarksToUpdate addObject:placemark];
                break;
                
            case SS_Create:
            case SS_Delete:
                // Crea la parte del atom referente a este elemento
                type = SyncStatus == SS_Create ? BATCH_TYPE_INSERT : BATCH_TYPE_DELETE;
                batch_item_id = [NSString stringWithFormat:@"ID_%@_%u", type, id_index++];
                itemAtomStr = [GMAtomGenerator partialAtomEntryFromItem:placemark];
                
                [atomStr appendString:@"<atom:entry>\n"];
                [atomStr appendFormat:@"  <batch:operation type='%@'/>\n", type];
                [atomStr appendFormat:@"  <batch:id>%@</batch:id>\n", batch_item_id];
                [atomStr appendString:itemAtomStr];
                [atomStr appendString:@"</atom:entry>\n"];
                
                // Lo añade al diccionario para que luego se pueda procesar su respuesta
                [itemByIDs setObject:placemark forKey:batch_item_id];
                break;
        }
        
    }

    
    // Pie del ATOM
    [atomStr appendString:@"</atom:feed>\n"];

    // Retorna el resultado final
    return atomStr;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _batchProcessFeed:(NSDictionary *)batchFeedDict itemByIDs:(NSDictionary *)itemByIDs errRef:(NSErrorRef *)errRef {

    
    // Establece que no hay un error
    [NSError nilErrorRef:errRef];
    
    // Va a acumular todos los errores encontrados como textos
    NSMutableArray *allErrorMsg = [NSMutableArray array];
    
    // Recupera todos los feeds de la respuesta
    NSMutableArray *allEntries = [NSMutableArray array];
    
    // --- Busca las entradas de tipo INSERT ---
    // Si solo hay un elemento no retorna un array, sino un diccionario
    NSArray *insertEntries = [batchFeedDict valueForKeyPath:@"atom:feed.atom:entry"];
    if([insertEntries isKindOfClass:[NSDictionary class]]) {
        insertEntries = [NSArray arrayWithObject:insertEntries];
    }
    if(insertEntries != nil) {
        [allEntries addObjectsFromArray:insertEntries];
    }
    
    // --- Busca las entradas de tipo DELETE ---
    // Si solo hay un elemento no retorna un array, sino un diccionario
    NSArray *deleteEntries = [batchFeedDict valueForKeyPath:@"atom:feed.entry"];
    if([deleteEntries isKindOfClass:[NSDictionary class]]) {
        deleteEntries = [NSArray arrayWithObject:deleteEntries];
    }
    if(deleteEntries != nil) {
        [allEntries addObjectsFromArray:deleteEntries];
    }
    
    
    // Procesa todos los feed de respuesta encontrados
    for(NSDictionary *placemarkFeedDict in allEntries) {

        // Extre la informacion del feedEntry
        NSString *batchId = [placemarkFeedDict valueForKeyPath:@"batch:id.text"];
        NSString *batchType = [placemarkFeedDict valueForKeyPath:@"batch:operation.type"];
        NSString *batchStatusCode = [placemarkFeedDict valueForKeyPath:@"batch:status.code"];
        NSString *batchStatusReason = [placemarkFeedDict valueForKeyPath:@"batch:status.reason"];
       
        if(!batchId || !batchType || !batchStatusCode || !batchStatusReason) {
            [allErrorMsg addObject:[NSString stringWithFormat:@"Batch error: Missing information while parsing elemement: %@", placemarkFeedDict]];
            continue;
        }

        // Para cada elemento debe haber un item que origino la peticion
        id<GMItem> gmItem = [itemByIDs objectForKey:batchId];
        if(!gmItem) {
            [allErrorMsg addObject:[NSString stringWithFormat:@"Batch error: No source elemement found by ID: %@", placemarkFeedDict]];
            continue;
        }

        // Procesa las inserciones
        if([batchType isEqualToString:BATCH_TYPE_INSERT]){
            
            if([batchStatusCode isEqualToString:@"201"]) {
                
                [GMFeedProcessor setItemValues:gmItem fromFeed:placemarkFeedDict];
                
                if(![GMItemValidator validateFieldsAreNotNil:gmItem errRef:errRef]) {
                    [allErrorMsg addObject:[NSString stringWithFormat:@"Batch error validating elemement '%@' set from %@", gmItem.name, placemarkFeedDict]];
                }
                
            } else {
                [allErrorMsg addObject:[NSString stringWithFormat:@"Batch error adding elemement '%@': Code = %@, Reason = %@", gmItem.name, batchStatusCode, batchStatusReason]];
                continue;
            }
            
        }
        
        // Procesa los borrados
        if([batchType isEqualToString:BATCH_TYPE_DELETE] && !([batchStatusCode isEqualToString:@"200"] || [batchStatusCode isEqualToString:@"404"])) {
            [allErrorMsg addObject:[NSString stringWithFormat:@"Batch error deleting elemement '%@': Code = %@, Reason = %@", gmItem.name, batchStatusCode, batchStatusReason]];
            continue;
        }
        
    }
    
    // Genera un error si campturo algo durante el procesado de la informacion
    if(allErrorMsg.count>0) {
        NSString *allErrorTxt = [allErrorMsg componentsJoinedByString:@"\n\n    "];
        [NSError setErrorRef:errRef domain:@"GMRemoteService" reason:@"Several errors captured during batch response processing: [\n%@\n", allErrorTxt];
        return FALSE;
    } else {
        return TRUE;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _addItem:(id<GMItem>)item errRef:(NSErrorRef *)errRef {
    
    
    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/maps/userID/full
    // tambien vale    http://maps.google.com/maps/feeds/maps/default/full
    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full
    // --------------------------------------------------------------------------------
    
    
    // El comportamiento depende de si es un mapa o un placemark
    BOOL isMap = [item conformsToProtocol:@protocol(GMMap)];
    
    
    DDLogVerbose(@"GMRemoteService - addItem [%@ / %@]", isMap?item.name:((id<GMPlacemark>)item).map.name,isMap?@"-":item.name);
    
    
    // Establece que no hay un error
    [NSError nilErrorRef:errRef];

    
    // Obtiene el Atom a enviar en la peticion
    NSString *atomData = [GMAtomGenerator fullAtomEntryFromItem:item];
    if(!atomData) return FALSE;


    // Invoca al servicio remoto
    NSString *postURL = isMap ? URL_ADD_NEW_MAP : [self _featuresURLForMap:(id<GMMap>)item];
    NSDictionary *result = [self.httpDataFetcher gmapPOST:postURL feedData:atomData errRef:errRef];
    if(!result) return FALSE;
    
    
    // Comprueba que hubo una respuesta correcta
    NSDictionary *feedEntry = [result objectForKey:isMap ? @"entry" : @"atom:entry"];
    if(feedEntry==nil) {
        [NSError setErrorRef:errRef domain:@"GMRemoteService" reason:@"Invalid answer received for 'addItem': ", result];
        return FALSE;
    }
    

    // Procesa el feedEntry con la informacion del item
    [GMFeedProcessor setItemValues:item fromFeed:feedEntry];

    if(![GMItemValidator validateFieldsAreNotNil:item errRef:errRef]) {
        return FALSE;
    }
    
    
    // Todo ha ido bien
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _updateItem:(id<GMItem>)item errRef:(NSErrorRef *)errRef {
    
    
    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/maps/userID/full/mapID
    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full/featureID
    // --------------------------------------------------------------------------------

    
    // El comportamiento depende de si es un mapa o un placemark
    BOOL isMap = [item conformsToProtocol:@protocol(GMMap)];

    
    DDLogVerbose(@"GMRemoteService - updateItem [%@ / %@]", isMap?item.name:((id<GMPlacemark>)item).map.name,isMap?@"-":item.name);
    
    
    // Establece que no hay un error
    [NSError nilErrorRef:errRef];

    
    // Obtiene el Atom a enviar en la peticion
    NSString *atomData = [GMAtomGenerator fullAtomEntryFromItem:item];
    if(!atomData) return FALSE;
    
    
    // Invoca al servicio remoto
    NSDictionary *result = [self.httpDataFetcher gmapUPDATE:[self _editLinkFor:item] feedData:atomData errRef:errRef];
    if(!result) return FALSE;
    
    
    // Comprueba que hubo una respuesta correcta
    NSDictionary *feedEntry = [result objectForKey:isMap ? @"entry" : @"atom:entry"];
    if(feedEntry==nil) {
        [NSError setErrorRef:errRef domain:@"GMRemoteService" reason:@"Invalid answer received for 'updateItem': ", result];
        return FALSE;
    }
    
    
    // Procesa el feedEntry con la informacion del item
    [GMFeedProcessor setItemValues:item fromFeed:feedEntry];
    
    if(![GMItemValidator validateFieldsAreNotNil:item errRef:errRef]) {
        return FALSE;
    }
    
    
    // Todo ha ido bien
    return TRUE;
}


// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _deleteItem:(id<GMItem>)item errRef:(NSErrorRef *)errRef {
    
    
    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/maps/userID/full/mapID
    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full/featureID
    // --------------------------------------------------------------------------------
    
    
    // El comportamiento depende de si es un mapa o un placemark
    BOOL isMap = [item conformsToProtocol:@protocol(GMMap)];

    
    DDLogVerbose(@"GMRemoteService - deleteItem [%@ / %@]", isMap?item.name:((id<GMPlacemark>)item).map.name,isMap?@"-":item.name);
    
    
    // Obtiene el Atom a enviar en la peticion
    NSString *atomData = [GMAtomGenerator fullAtomEntryFromItem:item];
    if(!atomData) return FALSE;
    
    
    // Invoca al servicio remoto
    BOOL result = [self.httpDataFetcher gmapDELETE:[self _editLinkFor:item] feedData:atomData errRef:errRef];
    
    // Si fue bien lo marca como borrado
    if(result) {
        item.markedAsDeleted = TRUE;
    }
    
    // Devuelve el resultado
    return result;
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _featuresURLForMap:(id<GMMap>)map {
    
    NSUInteger lastIndex = [map.gID lastIndexOf:@"/maps/"];
    if(lastIndex != NSNotFound) {
        NSString *url = [NSString stringWithFormat:@"%@/features/%@/full",
                         [map.gID substringToIndex:lastIndex],
                         [map.gID substringFromIndex:lastIndex + 6]];
        return url;
    } else {
        return nil;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _editLinkFor:(id<GMItem>)item {
    
    NSUInteger lastIndex = [item.gID lastIndexOf:@"/"];
    if(lastIndex != NSNotFound) {
        NSString *url = [NSString stringWithFormat:@"%@/full%@",
                         [item.gID substringToIndex:lastIndex],
                         [item.gID substringFromIndex:lastIndex]];
        return url;
    } else {
        return nil;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMSyncStatus) _syncStatusForItem:(id<GMItem>) item {

    // El estado de sincronizacion depende de si fue sincronizado, borrado, modificado,...
    if(item.markedAsDeleted) {
        return item.wasSynchronized ? SS_Delete : SS_Nothing;
        
    } else if(!item.wasSynchronized) {
        return SS_Create;
        
    } else if(item.markedForSync){
        return SS_Update;
        
    } else {
        return SS_Nothing;
        
    }
}




// =====================================================================================================================
// =====================================================================================================================
- (BOOL) __check_isSafeMapName__:(NSString *)name errRef:(NSErrorRef *)errRef {
    
    
    if(![name hasPrefix:@"@"] && ![name hasPrefix:@"TMP"] && ![name hasPrefix:@"PREP"]
       && ![name hasPrefix:@"HT_Holanda_2014"] && ![name hasPrefix:@"HT_Galicia_2014"]) {
        
        [NSError setErrorRef:errRef domain:@"GMRemoteService" reason:@"Map name (%@) is not included in the group of 'safe names'", name];

        return false;
    } else {
        return true;
    }
    
}


@end
