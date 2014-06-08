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
#import "GMapHttpDataFetcher.h"
#import "NSString+JavaStr.h"
#import "NSString+HTML.h"



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

@property (strong, nonatomic) GMapHttpDataFetcher *httpDataFetcher;

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
+ (GMapService *) serviceWithEmail:(NSString *)email password:(NSString *)password error:(NSError * __autoreleasing *)err {

    DDLogVerbose(@"GMapService - initWithEmailAndPassword");

    GMapService *me = [[GMapService alloc] init];
    me.httpDataFetcher = [[GMapHttpDataFetcher alloc] init];
    BOOL rc = [me.httpDataFetcher loginWithEmail:email password:password error:err];

    return rc == YES ? me : nil;
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

            for(NSDictionary *entry in entries) {
                GMTMap *map = [self _parseDictMapData:entry error:err];
                if(!map) {
                    return nil;
                }

                // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                // ******* SEGURO ***************************
                // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                //if(![map.name hasPrefix:@"@"] && ![map.name hasPrefix:@"TMP"]) {
                //    // Solo deja que "bajen" mapas remotos que empiecen con @ o TMP
                //    continue;
                //}

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
        GMTMap *map = [self _parseDictMapData:mapDictData error:err];
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


    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg];
        *err = [self _createError:errDesc withError:nil data:map];
        return nil;
    }


    NSString *atomData = [self _itemAtomEntryData:map];
    NSDictionary *result = [self.httpDataFetcher gmapPOST:URL_ADD_NEW_MAP feedData:atomData error:err];

    NSDictionary *mapDictData = [result objectForKey:@"entry"];
    if(mapDictData == nil) {
        *err = [self _createError:@"Invalid answer received for 'addMap' " withError:*err data:result];
        return nil;
    } else {
        GMTMap *updMap = [self _parseDictMapData:mapDictData error:err];
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


    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg];
        *err = [self _createError:errDesc withError:nil data:map];
        return nil;
    }


    NSString *atomData = [self _itemAtomEntryData:map];
    NSDictionary *result = [self.httpDataFetcher gmapUPDATE:map.editLink feedData:atomData error:err];

    NSDictionary *mapDictData = [result objectForKey:@"entry"];
    if(mapDictData == nil) {
        *err = [self _createError:@"Invalid answer received for 'updateMap' " withError:*err data:result];
        return nil;
    } else {
        GMTMap *updMap = [self _parseDictMapData:mapDictData error:err];
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


    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg];
        *err = [self _createError:errDesc withError:nil data:map];
        return false;
    }


    NSString *atomData = [self _itemAtomEntryData:map];
    BOOL result = [self.httpDataFetcher gmapDELETE:map.editLink feedData:atomData error:err];
    return result;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getPointListFromMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full
    // --------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - getPointListFromMap [%@]", map.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg];
        *err = [self _createError:errDesc withError:nil data:map];
        return nil;
    }


    NSDictionary *result = [self.httpDataFetcher gmapGET:[NSString stringWithFormat:@"%@?max-results=999999", map.featuresURL] error:err];

    if(result == nil || ![result valueForKeyPath:@"atom:feed"]) {
        *err = [self _createError:@"Invalid answer received for 'getPointListFromMap' " withError:*err data:result];
        return nil;
    } else {

        NSMutableArray *points = [NSMutableArray array];
        NSArray *entries = [result valueForKeyPath:@"atom:feed.atom:entry"];

        if(entries != nil) {

            // Si solo hay un elemento no retorna un array, sino un diccionario
            if([entries isKindOfClass:[NSDictionary class]]) {
                entries = [NSArray arrayWithObject:entries];
            }

            for(NSDictionary *entry in entries) {

                // Solo procesa las features tipo "Point" && "LineString"
                BOOL isPoint = [entry valueForKeyPath:@"atom:content.Placemark.Point"] != nil;
                BOOL isPolyLine = [entry valueForKeyPath:@"atom:content.Placemark.LineString"] != nil;
                if(!isPoint && !isPolyLine) {
                    continue;
                }
                
                GMTItem *item = nil;
                
                if(isPoint) {
                    item = [self _parseDictPointData:entry error:err];
                } else {
                    item = [self _parseDictPolyLineData:entry error:err];
                }

                if(!item) {
                    return nil;
                }
                [points addObject:item];

            }
        }

        // Retorna los points leidos
        return points;
    }

}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC POINT methods
// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) addPoint:(GMTPoint *)point inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full
    // --------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - addPoint [%@ / %@]", map.name, point.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __isSafeName__:map.name error:err]) {
        return nil;
    }


    NSString *errMsg1 = [map verifyFieldsNotNil];
    if(errMsg1) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg1];
        *err = [self _createError:errDesc withError:nil data:map];
        return nil;
    }
    
    NSString *errMsg2 = [point verifyFieldsNotNil];
    if(errMsg2) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input point: %@", errMsg2];
        *err = [self _createError:errDesc withError:nil data:point];
        return nil;
    }


    NSString *atomData = [self _itemAtomEntryData:point];
    NSDictionary *result = [self.httpDataFetcher gmapPOST:map.featuresURL feedData:atomData error:err];

    NSDictionary *pointDictData = [result objectForKey:@"atom:entry"];
    if(pointDictData == nil) {
        *err = [self _createError:@"Invalid answer received for 'addPoint' " withError:*err data:result];
        return nil;
    } else {
        GMTPoint *updPoint = [self _parseDictPointData:pointDictData error:err];
        return updPoint;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) updatePoint:(GMTPoint *)point inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full/featureID
    // --------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - updatePoint [%@ / %@]", map.name, point.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __isSafeName__:map.name error:err]) {
        return nil;
    }


    NSString *errMsg1 = [map verifyFieldsNotNil];
    if(errMsg1) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg1];
        *err = [self _createError:errDesc withError:nil data:map];
        return nil;
    }
    
    NSString *errMsg2 = [point verifyFieldsNotNil];
    if(errMsg2) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input point: %@", errMsg2];
        *err = [self _createError:errDesc withError:nil data:point];
        return nil;
    }


    NSString *atomData = [self _itemAtomEntryData:point];
    NSDictionary *result = [self.httpDataFetcher gmapUPDATE:point.editLink feedData:atomData error:err];


    NSDictionary *pointDictData = [result objectForKey:@"atom:entry"];
    if(pointDictData == nil) {
        *err = [self _createError:@"Invalid answer received for 'updatePoint' " withError:*err data:result];
        return nil;
    } else {
        GMTPoint *updPoint = [self _parseDictPointData:pointDictData error:err];
        return updPoint;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deletePoint:(GMTPoint *)point inMap:(GMTMap *)map error:(NSError * __autoreleasing *)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full/featureID
    // --------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - deletePoint [%@ / %@]", map.name, point.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![self __isSafeName__:map.name error:err]) {
        return false;
    }


    NSString *errMsg1 = [map verifyFieldsNotNil];
    if(errMsg1) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg1];
        *err = [self _createError:errDesc withError:nil data:map];
        return false;
    }
    
    NSString *errMsg2 = [point verifyFieldsNotNil];
    if(errMsg2) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input point: %@", errMsg2];
        *err = [self _createError:errDesc withError:nil data:point];
        return false;
    }


    NSString *atomData = [self _itemAtomEntryData:point];
    BOOL result = [self.httpDataFetcher gmapDELETE:point.editLink feedData:atomData error:err];
    return result;
}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC BATCH methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) processBatchCmds:(NSArray *)batchCmds inMap:(GMTMap *)map allErrors:(NSMutableArray *)allErrors checkCancelBlock:(CheckCancelBlock)checkCancelBlock {

    // --------------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full/batch
    // --------------------------------------------------------------------------------------



    DDLogVerbose(@"GMapService - processBatchCmds [%@][%lu]", map.name, (unsigned long)batchCmds.count);

    
    // Si la lista esta vacia no hace nada
    if(batchCmds == nil || batchCmds.count == 0) {
        return true;
    }


    
    
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    __autoreleasing NSError *safeNameError = nil;
    if(![self __isSafeName__:map.name error:&safeNameError]) {
        for(GMTBatchCmd *bcmd in batchCmds) {
            bcmd.resultItem = bcmd.item;
            bcmd.resultCode = BATCH_RC_ERROR;
        }
        [allErrors addObject:safeNameError];
        return false;
    }


    
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* NO SABE ACTUALIZAR LOS POLY LINES ************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    NSMutableArray *batchCmds_clean = [NSMutableArray array];
    for(GMTBatchCmd *bCmd in batchCmds) {
        if(![bCmd.item isKindOfClass:GMTPolyLine.class]) {
            [batchCmds_clean addObject:bCmd];
        }
    }
    batchCmds = batchCmds_clean;



    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg];
        NSError *localError = [self _createError:errDesc withError:nil data:map];
        [allErrors addObject:localError];
        return false;
    }

    for(GMTBatchCmd *bCmd in batchCmds) {
        NSString *errMsg2 = [bCmd.item verifyFieldsNotNil];
        if(errMsg2) {
            NSString *errDesc = [NSString stringWithFormat:@"Validating input point: %@", errMsg2];
            NSError *localError = [self _createError:errDesc withError:nil data:bCmd.item];
            [allErrors addObject:localError];
        }
    }
    
    if(allErrors.count > 0) {
        return false;
    }



    // LOS UPDATES NO FUNCIONAN. EN ESTE PUNTO GESTIONA UPDATES INDIVIDUALES
    for(GMTBatchCmd *bCmd in batchCmds) {

        if(bCmd.cmd != BATCH_CMD_UPDATE)
            continue;

        // Chequea periodicamente si debe cancelar
        if(checkCancelBlock!=nil && checkCancelBlock()) return false;
        
        
        NSError *localError = nil;
        GMTPoint *updPoint = [self updatePoint:(GMTPoint *)bCmd.item inMap:map error:&localError];

        bCmd.resultCode = updPoint != nil ? BATCH_RC_OK : BATCH_RC_ERROR;
        bCmd.resultItem = updPoint;

        if(localError) {
            [allErrors addObject:localError];
        }
    }

    
    // Chequea periodicamente si debe cancelar
    if(checkCancelBlock!=nil && checkCancelBlock()) return false;

    
    
    // LOS UPDATES NO FUNCIONAN. EN ESTE PUNTO GESTIONA LOS INSERT y DELETE
    NSString *atomData = [self _batchAtomFeedData:batchCmds];
    NSString *batchURL = [NSString stringWithFormat:@"%@/batch", map.featuresURL];
    NSError *localError = nil;
    NSDictionary *result = [self.httpDataFetcher gmapPOST:batchURL feedData:atomData error:&localError];


    if(localError != nil || ![result valueForKeyPath:@"atom:feed"]) {
        localError = [self _createError:@"Invalid answer received for 'batch update' " withError:localError data:result];
        [allErrors addObject:localError];
    } else {

        NSMutableArray *allEntries = [NSMutableArray array];

        // --- Busca las entradas de INSERT ---
        NSArray *insertEntries = [result valueForKeyPath:@"atom:feed.atom:entry"];

        // Si solo hay un elemento no retorna un array, sino un diccionario
        if([insertEntries isKindOfClass:[NSDictionary class]]) {
            insertEntries = [NSArray arrayWithObject:insertEntries];
        }

        if(insertEntries != nil) {
            [allEntries addObjectsFromArray:insertEntries];
        }

        // --- Busca las entradas de DELETE ---
        NSArray *deleteEntries = [result valueForKeyPath:@"atom:feed.entry"];

        // Si solo hay un elemento no retorna un array, sino un diccionario
        if([deleteEntries isKindOfClass:[NSDictionary class]]) {
            deleteEntries = [NSArray arrayWithObject:deleteEntries];
        }

        if(deleteEntries != nil) {
            [allEntries addObjectsFromArray:deleteEntries];
        }

        // Parsea todas las entradas encontradas actualizando el comando
        [self _parseDictBatchData:allEntries batchCmds:batchCmds allErrors:allErrors];
    }

    return allErrors.count == 0;

}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _itemAtomEntryData:(GMTItem *)item {

    NSMutableString *atomStr = [NSMutableString string];

    [atomStr appendString:@"<?xml version='1.0' encoding='UTF-8'?>"];
    [atomStr appendString:@"<atom:entry xmlns='http://www.opengis.net/kml/2.2'"];
    [atomStr appendString:@"            xmlns:atom='http://www.w3.org/2005/Atom'>"];

    [item atomEntryDataContent:atomStr];

    [atomStr appendString:@"</atom:entry>"];

    return atomStr;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _batchAtomFeedData:(NSArray *)batchCmds {

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
            [atomStr appendString:@"<atom:entry>"];
            [atomStr appendFormat:@"  <batch:operation type='%@'/>", BATCH_CMD_TEXTS[bCmd.cmd]];
            [atomStr appendFormat:@"  <batch:id>%u</batch:id>", n + 1];
            [bCmd.item atomEntryDataContent:atomStr];
            [atomStr appendString:@"</atom:entry>"];
        }
    }

    [atomStr appendString:@"</atom:feed>"];

    return atomStr;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _parseDictBatchData:(NSArray *)arrayBatchData batchCmds:(NSArray *)batchCmds allErrors:(NSMutableArray *)allErrors {

    for(NSDictionary *pointData in arrayBatchData) {

        NSError *loopError = nil;

        NSString *batchIDStr = [pointData valueForKeyPath:@"batch:id.text"];
        NSString *batchCmdStr = [pointData valueForKeyPath:@"batch:operation.type"];
        NSString *batchStatusCode = [pointData valueForKeyPath:@"batch:status.code"];
        NSString *batchStatusReason = [pointData valueForKeyPath:@"batch:status.reason"];
        int cmdIndex = [batchIDStr intValue] - 1;

        if(!batchIDStr || !batchCmdStr || !batchStatusCode || !batchStatusReason || cmdIndex < 0) {
            DDLogError(@"[parseDictBatchData] Batch info missing while parsing elemement: %@", pointData);
            loopError = [self _createError:@"Batch info missing while parsing elemement" withError:nil data:pointData];
            [allErrors addObject:loopError];
            continue;
        }

        if(cmdIndex >= batchCmds.count) {
            DDLogError(@"[parseDictBatchData] Batch info with erroneous index: %d", cmdIndex);
            loopError = [self _createError:@"Batch info with erroneous index" withError:nil data:pointData];
            [allErrors addObject:loopError];
            continue;
        }

        GMTBatchCmd *bCmd = batchCmds[cmdIndex];
        switch(bCmd.cmd) {

        case BATCH_CMD_INSERT:
            if([batchStatusCode isEqualToString:@"201"]) {
                GMTPoint *point = [self _parseDictPointData:pointData error:&loopError];
                bCmd.resultItem = point;
                bCmd.resultCode = point != nil ? BATCH_RC_OK : BATCH_RC_ERROR;
            } else {
                bCmd.resultItem = nil;
                bCmd.resultCode = BATCH_RC_ERROR;
                loopError = [self _createError:@"Batch insert error" withError:nil data:pointData];
                [allErrors addObject:loopError];
            }
            break;

        case BATCH_CMD_DELETE:
            bCmd.resultItem = nil;
            if([batchStatusCode isEqualToString:@"200"] || [batchStatusCode isEqualToString:@"404"]) {
                bCmd.resultCode = BATCH_RC_OK;
            } else {
                bCmd.resultCode = BATCH_RC_ERROR;
                loopError = [self _createError:@"Batch delete error" withError:nil data:pointData];
                [allErrors addObject:loopError];
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
            NSError *localError = [self _createError:@"Batch command still pending of execution" withError:nil data:bCmd];
            [allErrors addObject:localError];
        }
    }

    return allErrors.count == 0;

}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) _parseDictMapData:(NSDictionary *)dictMapData error:(NSError * __autoreleasing *)err {

    GMTMap __block *map = [GMTMap emptyMap];


    map.name = [[dictMapData valueForKeyPath:@"title.text"] gtm_stringByUnescapingFromHTML];
    map.summary = [dictMapData valueForKeyPath:@"summary.text"];
    if(map.summary == nil) map.summary = @"";
    map.etag = [dictMapData valueForKeyPath:@"gd:etag"];
    map.gID = [dictMapData valueForKeyPath:@"id.text"];
    map.published_Date = [GMTItem dateFromString:[dictMapData valueForKeyPath:@"published.text"]];
    map.updated_Date = [GMTItem dateFromString:[dictMapData valueForKeyPath:@"updated.text"]];


    // Chequea el resultado y lo retorna
    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        if(err != nil) {
            NSString *errDesc = [NSString stringWithFormat:@"Parsing NSDictionary object. %@", errMsg];
            *err = [self _createError:errDesc withError:nil data:dictMapData];
        }
        return nil;
    } else {
        return map;
    }
}


// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) _parseDictPointData:(NSDictionary *)dictPointData error:(NSError * __autoreleasing *)err {

    GMTPoint __block *point = [GMTPoint emptyPoint];

    
    point.name = [[dictPointData valueForKeyPath:@"atom:content.Placemark.name.text"] gtm_stringByUnescapingFromHTML];
    point.descr = [dictPointData valueForKeyPath:@"atom:content.Placemark.description.text"];
    
    if(point.descr == nil) point.descr = @"";
    point.iconHREF = [[dictPointData valueForKeyPath:@"atom:content.Placemark.Style.IconStyle.Icon.href.text"] gtm_stringByUnescapingFromHTML];
    if(point.iconHREF == nil) point.iconHREF = GM_DEFAULT_POINT_ICON_HREF;


    //<!-- lon,lat[,alt] -->
    NSString *coordinates = [dictPointData valueForKeyPath:@"atom:content.Placemark.Point.coordinates.text"];
    NSArray *splittedStr = [coordinates componentsSeparatedByString:@","];
    if(splittedStr.count == 3) {
        point.longitude = [splittedStr[0] doubleValue];
        point.latitude = [splittedStr[1] doubleValue];
    } else {
        point.longitude = 0;
        point.latitude = 0;
    }


    point.etag = [dictPointData valueForKeyPath:@"gd:etag"];
    point.gID = [dictPointData valueForKeyPath:@"atom:id.text"];
    point.published_Date = [GMTItem dateFromString:[dictPointData valueForKeyPath:@"atom:published.text"]];
    point.updated_Date = [GMTItem dateFromString:[dictPointData valueForKeyPath:@"atom:updated.text"]];

    
    // Chequea el resultado y lo retorna
    NSString *errMsg = [point verifyFieldsNotNil];
    if(errMsg) {
        if(err != nil) {
            NSString *errDesc = [NSString stringWithFormat:@"Parsing NSDictionary object. %@", errMsg];
            *err = [self _createError:errDesc withError:nil data:dictPointData];
        }
        return nil;
    } else {
        return point;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPolyLine *) _parseDictPolyLineData:(NSDictionary *)dictPointData error:(NSError * __autoreleasing *)err {
    
    GMTPolyLine __block *polyLine = [GMTPolyLine emptyPolyLine];
    
    polyLine.name = [[dictPointData valueForKeyPath:@"atom:content.Placemark.name.text"] gtm_stringByUnescapingFromHTML];
    polyLine.descr = [dictPointData valueForKeyPath:@"atom:content.Placemark.description.text"];
    if(polyLine.descr == nil) polyLine.descr = @"";
    
    
    //<!-- lon,lat[,alt] -->
    NSString *coordinates = [dictPointData valueForKeyPath:@"atom:content.Placemark.LineString.coordinates.text"];
    NSArray *splittedStr1 = [coordinates componentsSeparatedByString:@" "];
    for(NSString* singleCoordStr in splittedStr1) {
        
        NSArray *splittedStr2 = [singleCoordStr componentsSeparatedByString:@","];
        if(splittedStr2.count == 3) {
            CLLocationDegrees longitude = [splittedStr2[0] doubleValue];
            CLLocationDegrees latitude = [splittedStr2[1] doubleValue];
            CLLocation *coord = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            [polyLine.coordinates addObject:coord];
        }
        
    }
    

    // PolyLine color ------
    NSString *hexColorStr = [dictPointData valueForKeyPath:@"atom:content.Placemark.Style.LineStyle.color.text"];
    if(hexColorStr) {
        unsigned int hexValue;
        [[NSScanner scannerWithString:hexColorStr] scanHexInt:&hexValue];
        int a = (hexValue >> 24) & 0xFF;
        int b = (hexValue >> 16) & 0xFF;
        int g = (hexValue >>  8) & 0xFF;
        int r = (hexValue)       & 0xFF;
        UIColor *color = [UIColor colorWithRed:r/255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
        polyLine.color = color;
    } else {
        polyLine.color = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.6f];
    }
    
    
    polyLine.etag = [dictPointData valueForKeyPath:@"gd:etag"];
    polyLine.gID = [dictPointData valueForKeyPath:@"atom:id.text"];
    polyLine.published_Date = [GMTItem dateFromString:[dictPointData valueForKeyPath:@"atom:published.text"]];
    polyLine.updated_Date = [GMTItem dateFromString:[dictPointData valueForKeyPath:@"atom:updated.text"]];
    
    
    // Chequea el resultado y lo retorna
    NSString *errMsg = [polyLine verifyFieldsNotNil];
    if(errMsg) {
        if(err != nil) {
            NSString *errDesc = [NSString stringWithFormat:@"Parsing NSDictionary object. %@", errMsg];
            *err = [self _createError:errDesc withError:nil data:dictPointData];
        }
        return nil;
    } else {
        return polyLine;
    }
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
