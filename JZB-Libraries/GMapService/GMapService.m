//
// GMapService.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMapService_IMPL__
#import "GMapService.h"

#import "GMapDataFetcher.h"
#import "NSString+JavaStr.h"
#import "DDLog.h"
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

@property (strong) GMapDataFetcher *fetcher;


- (GMTMap *) parseDictMapData:(NSDictionary *)dictMapData error:(NSError **)err;
- (GMTPoint *) parseDictPointData:(NSDictionary *)dictPointData error:(NSError **)err;
- (BOOL) parseDictBatchData:(NSArray *)arrayBatchData batchCmds:(NSArray *)batchCmds allErrors:(NSMutableArray *)allErrors;

- (NSError *) anError:(NSString *)desc withError:(NSError *)prevErr data:(id)data;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMapService


@synthesize fetcher = _fetcher;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMapService *) serviceWithEmail:(NSString *)email password:(NSString *)password error:(NSError **)err {

    DDLogVerbose(@"GMapService - initWithEmailAndPassword");

    GMapService *me = [[GMapService alloc] init];
    me.fetcher = [[GMapDataFetcher alloc] init];
    BOOL rc = [me.fetcher loginWithEmail:email password:password error:err];

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
- (NSArray *) getMapList:(NSError **)err {

    // ------------------------------------------------------------------------------
    // URL con el formato:URL_FETCH_ALL_MAPS
    // ------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - getMapList");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;



    NSDictionary *result = [self.fetcher getServiceInfo:URL_FETCH_ALL_MAPS error:err];

    if(result == nil || ![result valueForKeyPath:@"feed"]) {
        *err = [self anError:@"Invalid answer received for 'getMapList' " withError:*err data:result];
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
                GMTMap *map = [self parseDictMapData:entry error:err];
                if(!map) {
                    return nil;
                }

                // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                // ******* SEGURO ***************************
                // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                if(![map.name hasPrefix:@"@"]) {
                    continue;
                }

                [maps addObject:map];
            }
        }

        // Retorna los mapas leidos
        return maps;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) getMapFromEditURL:(NSString *)mapEditURL error:(NSError **)err {

    // ------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/maps/userID/full/mapID
    // ------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - getMapFromEditURL");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;



    NSDictionary *result = [self.fetcher getServiceInfo:mapEditURL error:err];

    NSDictionary *mapDictData = [result objectForKey:@"entry"];
    if(mapDictData == nil) {
        *err = [self anError:@"Invalid answer received for 'getMapFromEditURL' " withError:*err data:result];
        return nil;
    } else {
        GMTMap *map = [self parseDictMapData:mapDictData error:err];
        return map;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) addMap:(GMTMap *)map error:(NSError **)err {

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
    if(![map.name hasPrefix:@"@"]) {
        *err = [self anError:@"Map name must start with @" withError:nil data:map];
        return nil;
    }


    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg];
        *err = [self anError:errDesc withError:nil data:map];
        return nil;
    }


    NSString *atomData = [self itemAtomEntryData:map];
    NSDictionary *result = [self.fetcher postServiceInfo:URL_ADD_NEW_MAP feedData:atomData error:err];

    NSDictionary *mapDictData = [result objectForKey:@"entry"];
    if(mapDictData == nil) {
        *err = [self anError:@"Invalid answer received for 'addMap' " withError:*err data:result];
        return nil;
    } else {
        GMTMap *updMap = [self parseDictMapData:mapDictData error:err];
        return updMap;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) updateMap:(GMTMap *)map error:(NSError **)err {

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
    if(![map.name hasPrefix:@"@"]) {
        *err = [self anError:@"Map name must start with @" withError:nil data:map];
        return nil;
    }


    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg];
        *err = [self anError:errDesc withError:nil data:map];
        return nil;
    }


    NSString *atomData = [self itemAtomEntryData:map];
    NSDictionary *result = [self.fetcher updateServiceInfo:map.editLink feedData:atomData error:err];

    NSDictionary *mapDictData = [result objectForKey:@"entry"];
    if(mapDictData == nil) {
        *err = [self anError:@"Invalid answer received for 'updateMap' " withError:*err data:result];
        return nil;
    } else {
        GMTMap *updMap = [self parseDictMapData:mapDictData error:err];
        return updMap;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteMap:(GMTMap *)map error:(NSError **)err {

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
    if(![map.name hasPrefix:@"@"]) {
        *err = [self anError:@"Map name must start with @" withError:nil data:map];
        return false;
    }


    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg];
        *err = [self anError:errDesc withError:nil data:map];
        return false;
    }


    NSString *atomData = [self itemAtomEntryData:map];
    BOOL result = [self.fetcher deleteServiceInfo:map.editLink feedData:atomData error:err];
    return result;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getPointListFromMap:(GMTMap *)map error:(NSError **)err {

    // --------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full
    // --------------------------------------------------------------------------------


    DDLogVerbose(@"GMapService - getPointListFromMap [%@]", map.name);


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![map.name hasPrefix:@"@"]) {
        *err = [self anError:@"Map name must start with @" withError:nil data:map];
        return nil;
    }



    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg];
        *err = [self anError:errDesc withError:nil data:map];
        return nil;
    }


    NSDictionary *result = [self.fetcher getServiceInfo:[NSString stringWithFormat:@"%@?max-results=999999", map.featuresURL] error:err];

    if(result == nil || ![result valueForKeyPath:@"atom:feed"]) {
        *err = [self anError:@"Invalid answer received for 'getPointListFromMap' " withError:*err data:result];
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

                // Solo procesa las features tipo "point"
                BOOL isPoint = [entry valueForKeyPath:@"atom:content.Placemark.Point"] != nil;
                if(!isPoint) {
                    continue;
                }

                GMTPoint *point = [self parseDictPointData:entry error:err];
                if(!point) {
                    return nil;
                }
                [points addObject:point];

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
- (GMTPoint *) addPoint:(GMTPoint *)point inMap:(GMTMap *)map error:(NSError **)err {

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
    if(![map.name hasPrefix:@"@"]) {
        *err = [self anError:@"Map name must start with @" withError:nil data:map];
        return nil;
    }


    NSString *errMsg1 = [map verifyFieldsNotNil];
    if(errMsg1) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg1];
        *err = [self anError:errDesc withError:nil data:map];
        return nil;
    }
    NSString *errMsg2 = [point verifyFieldsNotNil];
    if(errMsg2) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input point: %@", errMsg2];
        *err = [self anError:errDesc withError:nil data:point];
        return nil;
    }


    NSString *atomData = [self itemAtomEntryData:point];
    NSDictionary *result = [self.fetcher postServiceInfo:map.featuresURL feedData:atomData error:err];

    NSDictionary *pointDictData = [result objectForKey:@"atom:entry"];
    if(pointDictData == nil) {
        *err = [self anError:@"Invalid answer received for 'addPoint' " withError:*err data:result];
        return nil;
    } else {
        GMTPoint *updPoint = [self parseDictPointData:pointDictData error:err];
        return updPoint;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) updatePoint:(GMTPoint *)point inMap:(GMTMap *)map error:(NSError **)err {

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
    if(![map.name hasPrefix:@"@"]) {
        *err = [self anError:@"Map name must start with @" withError:nil data:map];
        return nil;
    }


    NSString *errMsg1 = [map verifyFieldsNotNil];
    if(errMsg1) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg1];
        *err = [self anError:errDesc withError:nil data:map];
        return nil;
    }
    NSString *errMsg2 = [point verifyFieldsNotNil];
    if(errMsg2) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input point: %@", errMsg2];
        *err = [self anError:errDesc withError:nil data:point];
        return nil;
    }


    NSString *atomData = [self itemAtomEntryData:point];
    NSDictionary *result = [self.fetcher updateServiceInfo:point.editLink feedData:atomData error:err];


    NSDictionary *pointDictData = [result objectForKey:@"atom:entry"];
    if(pointDictData == nil) {
        *err = [self anError:@"Invalid answer received for 'updatePoint' " withError:*err data:result];
        return nil;
    } else {
        GMTPoint *updPoint = [self parseDictPointData:pointDictData error:err];
        return updPoint;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deletePoint:(GMTPoint *)point inMap:(GMTMap *)map error:(NSError **)err {

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
    if(![map.name hasPrefix:@"@"]) {
        *err = [self anError:@"Map name must start with @" withError:nil data:map];
        return false;
    }


    NSString *errMsg1 = [map verifyFieldsNotNil];
    if(errMsg1) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg1];
        *err = [self anError:errDesc withError:nil data:map];
        return false;
    }
    NSString *errMsg2 = [point verifyFieldsNotNil];
    if(errMsg2) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input point: %@", errMsg2];
        *err = [self anError:errDesc withError:nil data:point];
        return false;
    }


    NSString *atomData = [self itemAtomEntryData:point];
    BOOL result = [self.fetcher deleteServiceInfo:point.editLink feedData:atomData error:err];
    return result;
}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC BATCH methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) processBatchCmds:(NSArray *)batchCmds inMap:(GMTMap *)map allErrors:(NSMutableArray *)allErrors {

    // --------------------------------------------------------------------------------------
    // URL con el formato: http://maps.google.com/maps/feeds/features/userID/mapID/full/batch
    // --------------------------------------------------------------------------------------



    DDLogVerbose(@"GMapService - processBatchCmds [%@][%lu]", map.name, batchCmds.count);


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ******* SEGURO ***************************
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if(![map.name hasPrefix:@"@"]) {
        NSError *localError = [self anError:@"Map name must start with @" withError:nil data:map];
        [allErrors addObject:localError];
        return false;
    }


    // Si la lista esta vacia no hace nada
    if(batchCmds == nil || batchCmds.count == 0) {
        return true;
    }


    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        NSString *errDesc = [NSString stringWithFormat:@"Validating input map: %@", errMsg];
        NSError *localError = [self anError:errDesc withError:nil data:map];
        [allErrors addObject:localError];
        return false;
    }

    for(GMTBatchCmd *bCmd in batchCmds) {
        NSString *errMsg2 = [bCmd.item verifyFieldsNotNil];
        if(errMsg2) {
            NSString *errDesc = [NSString stringWithFormat:@"Validating input point: %@", errMsg2];
            NSError *localError = [self anError:errDesc withError:nil data:bCmd.item];
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

        NSError *localError = nil;
        GMTPoint *updPoint = [self updatePoint:(GMTPoint *)bCmd.item inMap:map error:&localError];

        bCmd.resultCode = updPoint != nil ? BATCH_RC_OK : BATCH_RC_ERROR;
        bCmd.resultItem = updPoint;

        if(localError) {
            [allErrors addObject:localError];
        }
    }


    // LOS UPDATES NO FUNCIONAN. EN ESTE PUNTO GESTIONA LOS INSERT y DELETE
    NSString *atomData = [self batchAtomFeedData:batchCmds];
    NSString *batchURL = [NSString stringWithFormat:@"%@/batch", map.featuresURL];
    NSError *localError = nil;
    NSDictionary *result = [self.fetcher postServiceInfo:batchURL feedData:atomData error:&localError];


    if(localError != nil || ![result valueForKeyPath:@"atom:feed"]) {
        localError = [self anError:@"Invalid answer received for 'batch update' " withError:localError data:result];
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
        [self parseDictBatchData:allEntries batchCmds:batchCmds allErrors:allErrors];
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
- (NSString *) itemAtomEntryData:(GMTItem *)item {

    NSMutableString *atomStr = [NSMutableString string];

    [atomStr appendString:@"<?xml version='1.0' encoding='UTF-8'?>"];
    [atomStr appendString:@"<atom:entry xmlns='http://www.opengis.net/kml/2.2'"];
    [atomStr appendString:@"            xmlns:atom='http://www.w3.org/2005/Atom'>"];

    [item atomEntryDataContent:atomStr];

    [atomStr appendString:@"</atom:entry>"];

    return atomStr;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) batchAtomFeedData:(NSArray *)batchCmds {

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
- (BOOL) parseDictBatchData:(NSArray *)arrayBatchData batchCmds:(NSArray *)batchCmds allErrors:(NSMutableArray *)allErrors {

    for(NSDictionary *pointData in arrayBatchData) {

        NSError *loopError = nil;

        NSString *batchIDStr = [pointData valueForKeyPath:@"batch:id.text"];
        NSString *batchCmdStr = [pointData valueForKeyPath:@"batch:operation.type"];
        NSString *batchStatusCode = [pointData valueForKeyPath:@"batch:status.code"];
        NSString *batchStatusReason = [pointData valueForKeyPath:@"batch:status.reason"];
        int cmdIndex = [batchIDStr intValue] - 1;

        if(!batchIDStr || !batchCmdStr || !batchStatusCode || !batchStatusReason || cmdIndex < 0) {
            DDLogError(@"[parseDictBatchData] Batch info missing while parsing elemement: %@", pointData);
            loopError = [self anError:@"Batch info missing while parsing elemement" withError:nil data:pointData];
            [allErrors addObject:loopError];
            continue;
        }

        if(cmdIndex >= batchCmds.count) {
            DDLogError(@"[parseDictBatchData] Batch info with erroneous index: %d", cmdIndex);
            loopError = [self anError:@"Batch info with erroneous index" withError:nil data:pointData];
            [allErrors addObject:loopError];
            continue;
        }

        GMTBatchCmd *bCmd = batchCmds[cmdIndex];
        switch(bCmd.cmd) {

        case BATCH_CMD_INSERT:
            if([batchStatusCode isEqualToString:@"201"]) {
                GMTPoint *point = [self parseDictPointData:pointData error:&loopError];
                bCmd.resultItem = point;
                bCmd.resultCode = point != nil ? BATCH_RC_OK : BATCH_RC_ERROR;
            } else {
                bCmd.resultItem = nil;
                bCmd.resultCode = BATCH_RC_ERROR;
                loopError = [self anError:@"Batch insert error" withError:nil data:pointData];
                [allErrors addObject:loopError];
            }
            break;

        case BATCH_CMD_DELETE:
            bCmd.resultItem = nil;
            if([batchStatusCode isEqualToString:@"200"] || [batchStatusCode isEqualToString:@"404"]) {
                bCmd.resultCode = BATCH_RC_OK;
            } else {
                bCmd.resultCode = BATCH_RC_ERROR;
                loopError = [self anError:@"Batch delete error" withError:nil data:pointData];
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
            NSError *localError = [self anError:@"Batch command still pending of execution" withError:nil data:bCmd];
            [allErrors addObject:localError];
        }
    }

    return allErrors.count == 0;

}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) parseDictMapData:(NSDictionary *)dictMapData error:(NSError **)err {

    GMTMap __block *map = [GMTMap emptyMap];


    map.name = [[dictMapData valueForKeyPath:@"title.text"] gtm_stringByUnescapingFromHTML];
    map.summary = [[dictMapData valueForKeyPath:@"summary.text"] gtm_stringByUnescapingFromHTML];
    if(map.summary == nil) map.summary = @"";
    map.etag = [dictMapData valueForKeyPath:@"gd:etag"];
    map.gmID = [dictMapData valueForKeyPath:@"id.text"];
    map.published_Date = [GMTItem dateFromString:[dictMapData valueForKeyPath:@"published.text"]];
    map.updated_Date = [GMTItem dateFromString:[dictMapData valueForKeyPath:@"updated.text"]];


    // Chequea el resultado y lo retorna
    NSString *errMsg = [map verifyFieldsNotNil];
    if(errMsg) {
        if(err != nil) {
            NSString *errDesc = [NSString stringWithFormat:@"Parsing NSDictionary object. %@", errMsg];
            *err = [self anError:errDesc withError:nil data:dictMapData];
        }
        return nil;
    } else {
        return map;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) parseDictPointData:(NSDictionary *)dictPointData error:(NSError **)err {

    GMTPoint __block *point = [GMTPoint emptyPoint];

    point.name = [[dictPointData valueForKeyPath:@"atom:content.Placemark.name.text"] gtm_stringByUnescapingFromHTML];
    point.descr = [[dictPointData valueForKeyPath:@"atom:content.Placemark.description.text"] gtm_stringByUnescapingFromHTML];
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
    point.gmID = [dictPointData valueForKeyPath:@"atom:id.text"];
    point.published_Date = [GMTItem dateFromString:[dictPointData valueForKeyPath:@"atom:published.text"]];
    point.updated_Date = [GMTItem dateFromString:[dictPointData valueForKeyPath:@"atom:updated.text"]];

    
    // Chequea el resultado y lo retorna
    NSString *errMsg = [point verifyFieldsNotNil];
    if(errMsg) {
        if(err != nil) {
            NSString *errDesc = [NSString stringWithFormat:@"Parsing NSDictionary object. %@", errMsg];
            *err = [self anError:errDesc withError:nil data:dictPointData];
        }
        return nil;
    } else {
        return point;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSError *) anError:(NSString *)desc withError:(NSError *)prevErr data:(id)data {

    NSString *content = data == nil ? @"" : [data description];
    NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             desc, NSLocalizedDescriptionKey,
                             [NSString stringWithFormat:@"Data: %@", content], @"ErrorData",
                             [NSString stringWithFormat:@"%@", prevErr], @"PreviousErrorInfo", nil];
    NSError *err = [NSError errorWithDomain:@"GMapServiceErrorDomain" code:200 userInfo:errInfo];
    return err;
}

@end
