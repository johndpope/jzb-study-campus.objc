//
// GMapService.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMapService_IMPL__
#import "GMapService.h"

#import "DDLog.h"
#import "GMapDataHttpFetcher.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
#define URL_FETCH_ALL_MAPS @"http://maps.google.com/maps/feeds/maps/default/owned?max-results=999999"
#define URL_ADD_NEW_MAP    @"http://maps.google.com/maps/feeds/maps/default/full"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMapService ()

@property (strong, nonatomic) GMapDataHttpFetcher *httpDataFetcher;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMapService



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithEmail:(NSString *)email password:(NSString *)password error:(NSError * __autoreleasing *)err {
    
    DDLogVerbose(@"GMapService - initWithEmailAndPassword");
    
    if ( self = [super init] ) {
        self.httpDataFetcher = [[GMapDataHttpFetcher alloc] init];
        BOOL rc = [self.httpDataFetcher loginWithEmail:email password:password error:err];
        if(rc==NO) {
            self = nil;
        }
    }
    return self;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMapService *) serviceWithEmail2:(NSString *)email password:(NSString *)password error:(NSError * __autoreleasing *)err {

    DDLogVerbose(@"GMapService - serviceWithEmailAndPassword");

    GMapService *me = [[GMapService alloc] initWithEmail:email password:password error:err];
    return me;
}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC MAP methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getMapList:(NSError * __autoreleasing *)err {

    // ------------------------------------------------------------------------------
    // URL con el formato:URL_FETCH_ALL_MAPS
    // ------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - getMapList");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;



    NSDictionary *result = [self.httpDataFetcher gmapGET:URL_FETCH_ALL_MAPS error:err];

    if(result == nil || ![result valueForKeyPath:@"feed"]) {
        *err = [self _createError:@"Invalid answer received for 'getMapList' " withError:*err data:result];
        return nil;
    } else {

        NSMutableArray *maps = [NSMutableArray array];
        NSArray *entries = [result valueForKeyPath:@"feed.entry"];
        if(entries != nil) {

            // Si solo hay un elemento no retorna un array, sino un diccionario
            if([entries isKindOfClass:[NSDictionary class]]) {
                entries = [NSArray arrayWithObject:entries];
            }

            for(NSDictionary *mapDictData in entries) {
                
                GMTMap *map = [GMTMap mapWithContentOfFeed:mapDictData error:err];
                if(!map) {
                    return nil;
                }
                [maps addObject:map];
            }
        }

        // Retorna los mapas leidos
        return maps;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) getMapFromEditURL:(NSString *)mapEditURL error:(NSError * __autoreleasing *)err {

    // ------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/maps/userID/full/mapID
    // ------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - getMapFromEditURL");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;



    NSDictionary *result = [self.httpDataFetcher gmapGET:mapEditURL error:err];

    NSDictionary *mapDictData = [result objectForKey:@"entry"];
    if(mapDictData == nil) {
        *err = [self _createError:@"Invalid answer received for 'getMapFromEditURL' " withError:*err data:result];
        return nil;
    } else {
        GMTMap *map = [GMTMap mapWithContentOfFeed:mapDictData error:err];
        return map;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) addMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/maps/userID/full
    // tambien vale    http://maps.google.com/maps/feeds/maps/default/full
    // --------------------------------------------------------------------------------

    DDLogVerbose(@"GMapService - addMap [%@]", map.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __isSafeName__:map.name error:err]) {
        return nil;
    }

    NSString *atomData = [self _atomEntryDataFromItem:map error:err];
    if(!atomData) return nil;
    
    
    NSDictionary *result = [self.httpDataFetcher gmapPOST:URL_ADD_NEW_MAP feedData:atomData error:err];

    NSDictionary *mapDictData = [result objectForKey:@"entry"];
    if(mapDictData == nil) {
        *err = [self _createError:@"Invalid answer received for 'addMap' " withError:*err data:result];
        return nil;
    } else {
        GMTMap *updMap = [GMTMap mapWithContentOfFeed:mapDictData error:err];
        return updMap;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) updateMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/maps/userID/full/mapID
    // --------------------------------------------------------------------------------

    DDLogVerbose(@"GMapService - updateMap [%@]", map.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __isSafeName__:map.name error:err]) {
        return map;
    }


    NSString *atomData = [self _atomEntryDataFromItem:map error:err];
    if(!atomData) return nil;

    NSDictionary *result = [self.httpDataFetcher gmapUPDATE:map.editLink feedData:atomData error:err];

    NSDictionary *mapDictData = [result objectForKey:@"entry"];
    if(mapDictData == nil) {
        *err = [self _createError:@"Invalid answer received for 'updateMap' " withError:*err data:result];
        return nil;
    } else {
        GMTMap *updMap = [GMTMap mapWithContentOfFeed:mapDictData error:err];
        return updMap;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/maps/userID/full/mapID
    // --------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - deleteMap [%@]", map.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __isSafeName__:map.name error:err]) {
        return false;
    }


    NSString *atomData = [self _atomEntryDataFromItem:map error:err];
    if(!atomData) return FALSE;
    
    BOOL result = [self.httpDataFetcher gmapDELETE:map.editLink feedData:atomData error:err];
    return result;
}



// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC PLACEMARK methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *)  getPlacemarkListFromMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {
    
    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full
    // --------------------------------------------------------------------------------
    
    
    DDLogVerbose(@"GMapService - getPlacemarkListFromMap [%@]", map.name);
    
    
    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;
    
    
    NSDictionary *result = [self.httpDataFetcher gmapGET:[NSString stringWithFormat:@"%@?max-results=999999", map.featuresURL] error:err];
    
    // Chequea que no hubo un error
    if(*err!=nil) {
        *err = [self _createError:@"Invalid answer received for getPlacemarkListFromMap" withError:*err data:result];
        return nil;
    }
    
    // Chequea que hay un feed valido en la respuesta
    NSDictionary *feedEntry = [result objectForKey:@"atom:feed"];
    if(feedEntry == nil) {
        *err = [self _createError:@"Invalid feed answer received for getPlacemarkListFromMap" withError:*err data:result];
        return nil;
    }
    
    
    // Crea los placemarks desde el feed recibido
    NSMutableArray *allPlacemarks = [NSMutableArray array];
    
    // Si solo hay un elemento no retorna un array, sino un diccionario
    NSArray *entries = [feedEntry valueForKeyPath:@"atom:entry"];
    if([entries isKindOfClass:[NSDictionary class]]) {
        entries = [NSArray arrayWithObject:entries];
    }
    
    for(NSDictionary *feedEntry in entries) {
        
        // Crea el placemark desde el feed de la iteracion
        GMTPlacemark *placemark = [self _placemarkFromFeed:feedEntry error:err];
        
        if(!placemark) {
            return nil;
        }
        
        [allPlacemarks addObject:placemark];
        
    }

    
    // Retorna los elementos del mapa leidos
    return allPlacemarks;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPlacemark *) addPlacemark:(GMTPlacemark *)placemark inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full
    // --------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - addPlacemark [%@ / %@]", map.name, placemark.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __isSafeName__:map.name error:err]) {
        return nil;
    }


    // Obtiene el Atom a enviar en la peticion
    NSString *atomData = [self _atomEntryDataFromItem:placemark error:err];
    if(!atomData) return nil;

    // Realiza la peticion
    NSDictionary *result = [self.httpDataFetcher gmapPOST:map.featuresURL feedData:atomData error:err];
    
    // Chequea que no hubo un error
    if(*err!=nil) {
        *err = [self _createError:@"Invalid answer received for add placemark" withError:*err data:result];
        return nil;
    }
    
    // Chequea que hay un feed valido en la respuesta
    NSDictionary *feedEntry = [result objectForKey:@"atom:entry"];
    if(feedEntry == nil) {
        *err = [self _createError:@"Invalid feed answer received for placemark" withError:*err data:result];
        return nil;
    }
    
    // Crea el placemark actualizado (gID y ETag) desde el feed recibido
    GMTPlacemark *addedPlacemark = [self _placemarkFromFeed:feedEntry error:err];
    return addedPlacemark;

}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPlacemark *) updatePlacemark:(GMTPlacemark *)placemark inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full/featureID
    // --------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - updatePlacemark [%@ / %@]", map.name, placemark.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __isSafeName__:map.name error:err]) {
        return nil;
    }


    // Obtiene el Atom a enviar en la peticion
    NSString *atomData = [self _atomEntryDataFromItem:placemark error:err];
    if(!atomData) return nil;
    
    // Realiza la peticion
    NSDictionary *result = [self.httpDataFetcher gmapUPDATE:placemark.editLink feedData:atomData error:err];

    // Chequea que no hubo un error
    if(*err!=nil) {
        *err = [self _createError:@"Invalid answer received for update placemark" withError:*err data:result];
        return nil;
    }
    
    // Chequea que hay un feed valido en la respuesta
    NSDictionary *feedEntry = [result objectForKey:@"atom:entry"];
    if(feedEntry == nil) {
        *err = [self _createError:@"Invalid feed answer received for placemark" withError:*err data:result];
        return nil;
    }
    
    // Crea el placemark actualizado (gID y ETag) desde el feed recibido
    GMTPlacemark *addedPlacemark = [self _placemarkFromFeed:feedEntry error:err];
    return addedPlacemark;

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deletePlacemark:(GMTPlacemark *)placemark inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full/featureID
    // --------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - deletePlacemark [%@ / %@]", map.name, placemark.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __isSafeName__:map.name error:err]) {
        return false;
    }

    // Obtiene el Atom a enviar en la peticion
    NSString *atomData = [self _atomEntryDataFromItem:placemark error:err];
    if(!atomData) return FALSE;
    
    BOOL result = [self.httpDataFetcher gmapDELETE:placemark.editLink feedData:atomData error:err];
    return result;
}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC BATCH methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) processBatchCmds:(NSArray *)batchCmds inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err checkCancelBlock:(CheckCancelBlock)checkCancelBlock {

    // --------------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full/batch
    // --------------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - processBatchCmds [%@][%lu]", map.name, (unsigned long)batchCmds.count);

    
    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;

    
    // Si la lista esta vacia no hace nada
    if(batchCmds == nil || batchCmds.count == 0) {
        return true;
    }


    
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __isSafeName__:map.name error:err]) {
        return false;
    }

    BOOL processingWasOK = TRUE;
    
    
    // Lo primero que intenta es crear el ATOM FEED que enviaria para los cambios
    NSString *atomData = [self _atomBatchFeedData:batchCmds error:err];
    if(!atomData) return FALSE;
    
    // LOS UPDATES NO FUNCIONAN. EN ESTE PUNTO GESTIONA UPDATES INDIVIDUALES
    for(GMTBatchCmd *bCmd in batchCmds) {

        if(bCmd.cmd != BATCH_CMD_UPDATE)
            continue;

        // Chequea periodicamente si debe cancelar
        if(checkCancelBlock!=nil && checkCancelBlock()) return false;
        
        // Ejecuta la actualizacion
        NSError *updateError = nil;
        GMTPlacemark *updPlacemark = [self updatePlacemark:bCmd.placemark inMap:map error:&updateError];

        // Actualiza la informacion
        bCmd.resultCode = updPlacemark != nil ? BATCH_RC_OK : BATCH_RC_ERROR;
        bCmd.resultPlacemark = updPlacemark;
        bCmd.error = updateError;

        if(!updPlacemark) processingWasOK = FALSE;
        
    }

    
    // Chequea periodicamente si debe cancelar
    if(checkCancelBlock!=nil && checkCancelBlock()) return false;

    
    
    // LOS UPDATES NO FUNCIONAN. EN ESTE PUNTO GESTIONA LOS INSERT y DELETE
    // Realiza la peticion
    NSString *batchURL = [NSString stringWithFormat:@"%@/batch", map.featuresURL];
    NSDictionary *result = [self.httpDataFetcher gmapPOST:batchURL feedData:atomData error:err];
    
    // Chequea que no hubo un error
    if(*err!=nil) {
        *err = [self _createError:@"Invalid answer received for batch update placemarks" withError:*err data:result];
        return FALSE;
    }
    
    
    // Parsea todas las entradas encontradas actualizando el comando
    processingWasOK = [self _parseDictBatchFeedData:result batchCmds:batchCmds error:err];
    
    
    return processingWasOK;

}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _atomEntryDataFromItem:(GMTItem *)item error:(NSError * __autoreleasing *)err {

    NSMutableString *atomStr = [NSMutableString string];

    [atomStr appendString:@"<?xml version='1.0' encoding='UTF-8'?>\n"];
    [atomStr appendString:@"<atom:entry xmlns='http://www.opengis.net/kml/2.2'\n"];
    [atomStr appendString:@"            xmlns:atom='http://www.w3.org/2005/Atom'>\n"];

    NSMutableString *atomItemStr = [item atomEntryContentWithError:err];
    [atomStr appendString:atomItemStr];

    [atomStr appendString:@"</atom:entry>\n"];

    return atomItemStr!=nil ? atomStr : nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPlacemark *) _placemarkFromFeed:(NSDictionary *)feedEntry error:(NSError * __autoreleasing *)err {

    // Solo procesa las features tipo "Point" && "LineString"
    BOOL isPoint = [feedEntry valueForKeyPath:@"atom:content.Placemark.Point"] != nil;
    BOOL isPolyLine = [feedEntry valueForKeyPath:@"atom:content.Placemark.LineString"] != nil;
    if(!isPoint && !isPolyLine) {
        *err = [self _createError:@"Just Point and PolyLine placemarks can be processed" withError:*err data:feedEntry];
        return nil;
    }
    
    // Procesa la informacion del feed adecuadamente
    GMTPlacemark *item = nil;
    
    if(isPoint) {
        item = [GMTPoint pointWithContentOfFeed:feedEntry error:err];
    } else {
        item = [GMTPolyLine polyLineWithContentOfFeed:feedEntry error:err];
    }
    
    return item;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _atomBatchFeedData:(NSArray *)batchCmds error:(NSError * __autoreleasing *)err {

    NSMutableString *atomStr = [NSMutableString string];

    [atomStr appendString:@"<?xml version='1.0' encoding='UTF-8'?>"];
    [atomStr appendString:@"<atom:feed xmlns='http://www.opengis.net/kml/2.2'"];
    [atomStr appendString:@"           xmlns:atom='http://www.w3.org/2005/Atom'"];
    [atomStr appendString:@"           xmlns:gd='http://schemas.google.com/g/2005'"];
    [atomStr appendString:@"           xmlns:batch='http://schemas.google.com/gdata/batch'>"];

    for(int n = 0; n < batchCmds.count; n++) {

        GMTBatchCmd *bCmd = batchCmds[n];

        if(bCmd.cmd == BATCH_CMD_UPDATE) {

            // NO FUNCIONA LOS UPDATES.
            // SE CAMBIA POR PETICIONES INDIVIDUALES DE UPDATE

        } else {
            [atomStr appendString:@"<atom:entry>\n"];
            [atomStr appendFormat:@"  <batch:operation type='%@'/>\n", BATCH_CMD_TEXTS[bCmd.cmd]];
            [atomStr appendFormat:@"  <batch:id>%u</batch:id>\n", n + 1];
            
            // Si falla la generacion del item aborta el proceso completo
            NSMutableString *atomItemStr = [bCmd.placemark atomEntryContentWithError:err];
            if(!atomItemStr) {
                return nil;
            }
            
            [atomStr appendString:atomItemStr];

            [atomStr appendString:@"</atom:entry>\n"];
        }
    }

    [atomStr appendString:@"</atom:feed>\n"];

    return atomStr;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _parseDictBatchFeedData:(NSDictionary *)feedData batchCmds:(NSArray *)batchCmds error:(NSError * __autoreleasing *)err {

    BOOL processingWasOK = TRUE;
    
    
    // Recupera todos los feeds de la respuesta
    NSMutableArray *allEntries = [NSMutableArray array];
    
    // --- Busca las entradas de INSERT ---
    NSArray *insertEntries = [feedData valueForKeyPath:@"atom:feed.atom:entry"];
    
    // Si solo hay un elemento no retorna un array, sino un diccionario
    if([insertEntries isKindOfClass:[NSDictionary class]]) {
        insertEntries = [NSArray arrayWithObject:insertEntries];
    }
    
    if(insertEntries != nil) {
        [allEntries addObjectsFromArray:insertEntries];
    }
    
    // --- Busca las entradas de DELETE ---
    NSArray *deleteEntries = [feedData valueForKeyPath:@"atom:feed.entry"];
    
    // Si solo hay un elemento no retorna un array, sino un diccionario
    if([deleteEntries isKindOfClass:[NSDictionary class]]) {
        deleteEntries = [NSArray arrayWithObject:deleteEntries];
    }
    
    if(deleteEntries != nil) {
        [allEntries addObjectsFromArray:deleteEntries];
    }
    

    // Procesa todos los feed encontrados
    for(NSDictionary *placemarkDictData in allEntries) {

        NSString *batchIDStr = [placemarkDictData valueForKeyPath:@"batch:id.text"];
        NSString *batchCmdStr = [placemarkDictData valueForKeyPath:@"batch:operation.type"];
        NSString *batchStatusCode = [placemarkDictData valueForKeyPath:@"batch:status.code"];
        NSString *batchStatusReason = [placemarkDictData valueForKeyPath:@"batch:status.reason"];
        int cmdIndex = [batchIDStr intValue] - 1;

        if(!batchIDStr || !batchCmdStr || !batchStatusCode || !batchStatusReason || cmdIndex < 0) {
            DDLogError(@"[_parseDictBatchFeedData] Batch info missing while parsing elemement: %@", placemarkDictData);
            if(err) *err = [self _createError:@"Batch info missing while parsing elemement" withError:nil data:placemarkDictData];
            return FALSE;
        }

        if(cmdIndex >= batchCmds.count || cmdIndex<0) {
            DDLogError(@"[_parseDictBatchFeedData] Batch info with erroneous index: %d", cmdIndex);
            if(err) *err = [self _createError:@"Batch info with erroneous index" withError:nil data:placemarkDictData];
            return FALSE;
        }

        GMTBatchCmd *bCmd = batchCmds[cmdIndex];
        switch(bCmd.cmd) {

        case BATCH_CMD_ADD:
                
            if([batchStatusCode isEqualToString:@"201"]) {
                // Crea el placemark actualizado (gID y ETag) desde el feed recibido
                NSError *loopError = nil;
                GMTPlacemark *addedPlacemark = [self _placemarkFromFeed:placemarkDictData error:&loopError];
                bCmd.resultPlacemark = addedPlacemark;
                bCmd.resultCode = addedPlacemark != nil ? BATCH_RC_OK : BATCH_RC_ERROR;
                bCmd.error = loopError;
            } else {
                bCmd.resultPlacemark = nil;
                bCmd.resultCode = BATCH_RC_ERROR;
                bCmd.error = [self _createError:@"Batch insert error" withError:nil data:placemarkDictData];
                processingWasOK = FALSE;
            }
            break;

        case BATCH_CMD_DELETE:
                
            bCmd.resultPlacemark = nil;
            if([batchStatusCode isEqualToString:@"200"] || [batchStatusCode isEqualToString:@"404"]) {
                bCmd.resultCode = BATCH_RC_OK;
            } else {
                bCmd.resultCode = BATCH_RC_ERROR;
                bCmd.error = [self _createError:@"Batch delete error" withError:nil data:placemarkDictData];
                processingWasOK = FALSE;
            }
            break;

        case BATCH_CMD_UPDATE:

            // NO FUNCIONA LOS UPDATES.
            // SE CAMBIA POR PETICIONES INDIVIDUALES DE UPDATE

            break;
        }
        
    }

    // Comprueba que se obtuvo respuesta para todos los comandos ejecutados
    for(GMTBatchCmd *bCmd in batchCmds) {
        if(bCmd.resultCode == BATCH_RC_PENDING) {
            bCmd.error = [self _createError:@"Batch command still pending of execution" withError:nil data:bCmd];
            processingWasOK = FALSE;
        }
    }

    return processingWasOK;

}


// ---------------------------------------------------------------------------------------------------------------------
- (NSError *) _createError:(NSString *)desc withError:(NSError *)prevErr data:(id)data {

    NSString *content = data == nil ? @"" : [data description];
    NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             desc, NSLocalizedDescriptionKey,
                             [NSString stringWithFormat:@"Data: %@", content], @"ErrorData",
                             [NSString stringWithFormat:@"%@", prevErr], @"PreviousErrorInfo", nil];
    NSError *err = [NSError errorWithDomain:@"GMapServiceErrorDomain" code:200 userInfo:errInfo];
    return err;
}


// =====================================================================================================================
// =====================================================================================================================
- (BOOL) __isSafeName__:(NSString *)name error:(NSError * __autoreleasing *)err {
    
    
    if(![name hasPrefix:@"@"] && ![name hasPrefix:@"TMP"] && ![name hasPrefix:@"PREP"]
       && ![name hasPrefix:@"HT_Holanda_2014"] && ![name hasPrefix:@"HT_Galicia_2014"]) {
        *err = [self _createError:@"Map name must start by @ to be modified" withError:nil data:nil];
        return false;
    } else {
        return true;
    }
   
}

@end
