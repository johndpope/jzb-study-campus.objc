//
// GMapSyncService.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMapSyncService_IMPL__
#import "GMapSyncService.h"


#import "GMapService.h"
#import "GMPComparable.h"
#import "GMTCompTuple.h"
#import "DDLog.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMapSyncService ()


@property (strong, nonatomic) id<GMPSyncDataSource> dataSource;
@property (strong, nonatomic) id<GMPSyncDelegate>   delegate;
@property (strong, nonatomic) GMapService           *gmService;
@property (assign, atomic)    BOOL                  mustCancelSync;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMapSyncService





// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMapSyncService *) serviceWithEmail:(NSString *)email
                              password:(NSString *)password
                            dataSource:(id<GMPSyncDataSource>)dataSource
                              delegate:(id<GMPSyncDelegate>)delegate
                                 error:(NSError * __autoreleasing *)err {


    DDLogVerbose(@"GMapSyncService - initWithEmailAndPassword");

    if(dataSource == nil) {
        DDLogVerbose(@"GMapSyncService - dataSource cannot be NIL");
        return nil;
    }

    GMapService *srvc = [GMapService serviceWithEmail:email password:password error:err];
    if(srvc == nil) {
        DDLogVerbose(@"GMapSyncService - GMapService failed to initialize");
        return nil;
    }

    GMapSyncService *me = [[GMapSyncService alloc] init];
    me.gmService = srvc;
    me.dataSource = dataSource;
    me.delegate = delegate;
    me.mustCancelSync = NO;
    
    return me;

}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) wasCanceled {
    return self.mustCancelSync;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) cancelSync {
    DDLogVerbose(@"GMapSyncService - cancelSync");
    self.mustCancelSync = true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) syncMaps:(NSError * __autoreleasing *)err {


    DDLogVerbose(@"GMapSyncService - syncMaps");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    // Para acumular errores
    NSMutableArray *allErrors = [NSMutableArray array];

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // Avisa de la actividad en la sincronizacion
    if([self.delegate respondsToSelector:@selector(willGetRemoteMapList)]) {
        [self.delegate willGetRemoteMapList];
    }

    // Consigue la lista de los mapas remotos
    NSArray *remoteMaps = [self.gmService getMapList:err];
    if(*err || !remoteMaps) {
        // Ha habido un error al recuperar los mapas locales
        DDLogVerbose(@"GMapSyncService - Error reading remote maps: %@", *err);
        return false;
    }
    

    // Avisa de la actividad en la sincronizacion
    if([self.delegate respondsToSelector:@selector(didGetRemoteMapList)]) {
        [self.delegate didGetRemoteMapList];
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // Consigue la lista de los mapas locales
    NSArray *localMaps = [self.dataSource getAllLocalMapList:err];
    if(*err || !localMaps) {
        // Ha habido un error al recuperar los mapas locales
        DDLogVerbose(@"GMapSyncService - Error reading local maps: %@", *err);
        return false;
    }


    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // Realiza la comparacion de elementos
    DDLogVerbose(@"GMapSyncService - Comparing map lists");
    if([self.delegate respondsToSelector:@selector(willCompareLocalAndRemoteMaps)]) {
        [self.delegate willCompareLocalAndRemoteMaps];
    }
    NSArray *compTuples = [self _compareLocalItems:localMaps withRemoteItems:remoteMaps];

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // Avisa de los mapas a sincronizar
    if([self.delegate respondsToSelector:@selector(didCompareLocalAndRemoteMaps:)]) {
        [self.delegate didCompareLocalAndRemoteMaps:compTuples];
    }

    
    // Itera los resultados de la comparacion
    DDLogVerbose(@"GMapSyncService - ***************************************************************************");
    DDLogVerbose(@"GMapSyncService - Synchronizing map lists (will make changes!)");
    DDLogVerbose(@"GMapSyncService - ***************************************************************************");
    for(int index=0;index<compTuples.count;index++) {

        GMTCompTuple *tuple = compTuples[index];
        
        // Chequea periodicamente si debe cancelar
        if(self.mustCancelSync) return false;

        // Pregunta si debe procesarlo
        if([self.delegate respondsToSelector:@selector(shouldProcessTuple:error:)]) {
            NSError *localError = nil;
            BOOL processMap = [self.delegate shouldProcessTuple:tuple error:&localError];
            
            if(localError!=nil) {
                [allErrors addObject:[self _createError:@"Map tuple processing skipped by delegate" withError:localError data:nil]];
            }
            
            if(!processMap || localError!=nil) {
                tuple.runStatus = ST_Run_Failed;
                continue;
            }
        }
        
        // Apunta que va a procesar este elemento
        tuple.runStatus = ST_Run_Processing;

        // Avisa del mapa a sincronizar
        if([self.delegate respondsToSelector:@selector(willSyncMapTuple:withIndex:)]) {
            [self.delegate willSyncMapTuple:tuple withIndex:index];
        }

        BOOL mapSyncOK;
        
        // Actua en la tupla dependiendo de la accion a acometer
        switch(tuple.compStatus) {

        case ST_Comp_Create_Local:
            mapSyncOK = [self _createLocalMapWithTuple:tuple allErrors:allErrors];
            break;

        case ST_Comp_Create_Remote:
            mapSyncOK = [self _createRemoteMapWithTuple:tuple allErrors:allErrors];
            break;

        case ST_Comp_Delete_Local:
            mapSyncOK = [self _deleteLocalMapWithTuple:tuple allErrors:allErrors];
            break;

        case ST_Comp_Delete_Remote:
            mapSyncOK = [self _deleteRemoteMapWithTuple:tuple allErrors:allErrors];
            break;

        case ST_Comp_Update_Local:
        case ST_Comp_Update_Remote:
            mapSyncOK = [self _updateLocalAndRemoteMapWithTuple:tuple allErrors:allErrors];
            break;
        }
        
        tuple.runStatus = mapSyncOK ? ST_Run_OK : ST_Run_Failed;
        
        // Avisa del mapa a sincronizar
        if([self.delegate respondsToSelector:@selector(didSyncMapTuple:withIndex:syncOK:)]) {
            [self.delegate didSyncMapTuple:tuple withIndex:index syncOK:mapSyncOK];
        }
        
    
    }
    


    // Todo termino bien si no hubo errores
    BOOL wasAllOK = allErrors.count == 0;
    
    // Avisa de la finalizacion de la sincronizacion
    if([self.delegate respondsToSelector:@selector(syncFinished:)]) {
        [self.delegate syncFinished:wasAllOK];
    }

    // Finaliza dando acceso a los errores si los hubo
    if(wasAllOK) {
        return true;
    } else {
        *err = [self _createError:@"There were errors during processing" withError:nil data:allErrors];
        return false;
    }

}



// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _createLocalMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors {

    // Para controlar los errores locales
    NSError *localError = nil;


    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // Se necesitan todos los puntos del mapa remoto
    localError = nil;
    NSArray *remotePoints = [self.gmService getPointListFromMap:tuple.remoteItem error:&localError];
    if(remotePoints == nil) {
        [allErrors addObject:[self _createError:@"remote from map returned nil" withError:localError data:nil]];
        return false;
    }

    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    // Crea el mapa local
    localError = nil;
    id localMap = [self.dataSource createLocalMapFrom:tuple.remoteItem error:&localError];
    if(localMap == nil) {
        [allErrors addObject:[self _createError:@"local map from remote returned nil" withError:localError data:nil]];
        return false;
    }

    // Itera creando todos los puntos locales a partir de los remotos
    BOOL allOK = true;
    for(GMTItem *gmItem in remotePoints) {
        localError = nil;
        
        id localItem = [self.dataSource createLocalPointFrom:(GMTPoint *)gmItem inLocalMap:localMap error:&localError];
        if(localItem == nil) {
            allOK = false;
            [allErrors addObject:[self _createError:@"local point from remote returned nil" withError:localError data:nil]];
        }
    }
    
    // Actualiza de nuevo el mapa para que quede marcado como sincronizado si todos los puntos se crearon correctamente
    localError = nil;
    if(NO == [self.dataSource updateLocalMap:localMap withRemoteMap:tuple.remoteItem allPointsOK:allOK error:&localError]) {
        [allErrors addObject:[self _createError:@"update local map from remote" withError:localError data:nil]];
        return false;
    }

    return allOK;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _deleteLocalMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors {

    BOOL allOK = true;
    NSError *localError = nil;
    if(NO == [self.dataSource deleteLocalMap:tuple.localItem error:&localError]) {
        allOK = false;
        [allErrors addObject:[self _createError:@"delete local map" withError:localError data:nil]];
    }
    return allOK;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _createRemoteMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors {

    // Para controlar los errores locales
    NSError *localError = nil;
    BOOL allOK = true;

    // Consigue la lista de puntos locales
    NSArray *localPoints = [self.dataSource getLocalPointListForMap:tuple.localItem error:&localError];
    if(localPoints == nil) {
        [allErrors addObject:[self _createError:@"get local point list from map" withError:localError data:nil]];
        return false;
    }

    // Consigue el mapa remoto a crear
    localError = nil;
    GMTMap *gmMap = [self.dataSource createRemoteMapFrom:tuple.localItem error:&localError];
    if(gmMap == nil) {
        [allErrors addObject:[self _createError:@"remote map from local" withError:localError data:nil]];
        return false;
    }
    
    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;


    // Da la orden de creacion del mapa remoto
    localError = nil;
    GMTMap *createdMap = [self.gmService addMap:gmMap error:&localError];
    if(createdMap == nil) {
        [allErrors addObject:[self _createError:@"create remote map" withError:localError data:nil]];
        return false;
    }
    
    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;


    // La creacion del mapa remoto genera su gID y el ETAG inicial. Debe actualizar la info local
    localError = nil;
    if(NO == [self.dataSource updateLocalMap:tuple.localItem withRemoteMap:createdMap allPointsOK:true error:&localError]) {
        [allErrors addObject:[self _createError:@"update local map from remote" withError:localError data:nil]];
        return false;
    }

    // Itera creando ordenes batch de creacion de todos los puntos remotos a partir de los locales
    NSMutableArray *batchCmds = [NSMutableArray array];
    for(id localPoint in localPoints) {

        // Consigue el punto remoto a crear
        localError = nil;
        
        GMTItem *remotePoint = [self.dataSource createRemotePointFrom:localPoint error:&localError];
        if(remotePoint == nil) {
            allOK = false;
            [allErrors addObject:[self _createError:@"remote point from local" withError:localError data:nil]];
        }


        // Crea el comando batch de actualizacion
        if(remotePoint != nil) {
            GMTBatchCmd *bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_INSERT withItem:remotePoint];
            bCmd.extraData = localPoint;
            [batchCmds addObject:bCmd];
        }
    }

    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    // Da la orden de actualización batch
    BOOL allPointsOK = [self.gmService processBatchCmds:batchCmds inMap:createdMap allErrors:allErrors  checkCancelBlock:^BOOL{
        return self.mustCancelSync;
    }];
    allOK &= allPointsOK;

    // La creacion de los puntos remotos genera su gID y el ETAG inicial. Debe actualizar la info local
    for(GMTBatchCmd *bCmd in batchCmds) {
        localError = nil;
        if(NO == [self.dataSource updateLocalPoint:bCmd.extraData withRemotePoint:(GMTPoint *)bCmd.resultItem error:&localError]) {
            allOK = false;
            [allErrors addObject:[self _createError:@"update local point from remote" withError:localError data:nil]];
        }
    }

    // La creacion de alguno de los puntos hace que el ETAG del mapa remoto cambie
    GMTMap *updatedMap;
    if(batchCmds.count > 0) {
        updatedMap = [self.gmService getMapFromEditURL:createdMap.editLink error:&localError];
        if(updatedMap == nil) {
            allOK = false;
            [allErrors addObject:[self _createError:@"update remote map" withError:localError data:nil]];
            updatedMap = createdMap;
        }
    } else {
        updatedMap = createdMap;
    }

    // Actualiza los datos del mapa local desde el remoto recien creado y actualizado con los puntos
    // (gID, ETAG, fechas, etc.)
    localError = nil;
    if(NO == [self.dataSource updateLocalMap:tuple.localItem withRemoteMap:updatedMap allPointsOK:allPointsOK error:&localError]) {
        allOK = false;
        [allErrors addObject:[self _createError:@"update local map from remote" withError:localError data:nil]];
    }
    
    return  allOK;

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _deleteRemoteMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors {

    BOOL allOK = true;
    NSError *localError = nil;
    [self.gmService deleteMap:tuple.remoteItem error:&localError];
    if(localError != nil) {
        allOK = false;
        [allErrors addObject:[self _createError:@"delete remote map" withError:localError data:nil]];
    }
    return allOK;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) _updateLocalAndRemoteMapWithTuple:(GMTCompTuple *)mapTuple allErrors:(NSMutableArray *)allErrors {

    // Para controlar los errores locales
    NSError *localError = nil;
    BOOL allOK = true;


    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // mapas involucrados
    id<GMPComparableLocal> localMap = mapTuple.localItem;
    GMTMap *remoteMap = mapTuple.remoteItem;


    // Se apunta si el mapa local estaba borrado y se esta re-actualizando desde el remoto
    BOOL localMapWasDeleted = localMap.markedAsDeletedValue;


    // Actualiza primero la información del propio mapa
    if(mapTuple.compStatus == ST_Comp_Update_Local) {
        if(NO == [self.dataSource updateLocalMap:localMap withRemoteMap:remoteMap allPointsOK:true error:&localError]) {
            [allErrors addObject:[self _createError:@"update local map from remote" withError:localError data:nil]];
            return false;
        }
    } else {
        localError = nil;
        if(![self.dataSource updateRemoteMap:remoteMap withLocalMap:localMap error:&localError]) {
            [allErrors addObject:[self _createError:@"update remote map from local information" withError:localError data:nil]];
            return false;
        }
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;


    // Se necesitan todos los puntos del mapa remoto
    localError = nil;
    NSArray *remotePoints = [self.gmService getPointListFromMap:remoteMap error:&localError];
    if(remotePoints == nil) {
        [allErrors addObject:[self _createError:@"get point list from remote map" withError:localError data:nil]];
        return false;
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;


    // Consigue la lista de puntos locales
    NSArray *localPoints = [self.dataSource getLocalPointListForMap:localMap error:&localError];
    if(localPoints == nil) {
        [allErrors addObject:[self _createError:@"get point list from local map" withError:localError data:nil]];
        return false;
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // Realiza la comparacion de elementos o su copia dependiendo de si el mapa local estaba borrado o no
    DDLogVerbose(@"GMapSyncService - Comparing point lists");
    NSArray *compTuples;
    if(localMapWasDeleted) {
        compTuples = [self _makeLocalItems:localPoints equalToRemoteItems:remotePoints];
    } else {
        compTuples = [self _compareLocalItems:localPoints withRemoteItems:remotePoints];
    }

    // Itera los resultados de la comparacion creando comandos de actualizacion en batch
    DDLogVerbose(@"GMapSyncService - ----------------------------------------------------------------");
    DDLogVerbose(@"GMapSyncService - Synchronizing point lists in map (will make changes!)");
    DDLogVerbose(@"GMapSyncService - ----------------------------------------------------------------");
    NSMutableArray *batchCmds = [NSMutableArray array];
    for(GMTCompTuple *tuple in compTuples) {

        tuple.runStatus = ST_Run_Processing;
        
        // Chequea periodicamente si debe cancelar
        if(self.mustCancelSync) return false;

        GMTItem *remotePoint;
        GMTBatchCmd *bCmd;

        localError = nil;
        switch(tuple.compStatus) {

        case ST_Comp_Create_Local:
            [self.dataSource createLocalPointFrom:tuple.remoteItem inLocalMap:localMap error:&localError];
            if(localError != nil) {
                tuple.runStatus = ST_Run_Failed;
                allOK = false;
                [allErrors addObject:[self _createError:@"create local point" withError:localError data:nil]];
            }
            break;

        case ST_Comp_Create_Remote:
            remotePoint = [self.dataSource createRemotePointFrom:tuple.localItem error:&localError];
            if(remotePoint == nil) {
                tuple.runStatus = ST_Run_Failed;
                allOK = false;
                [allErrors addObject:[self _createError:@"remote point from local" withError:localError data:nil]];
            } else {
                bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_INSERT withItem:remotePoint];
                bCmd.extraData = tuple.localItem;
                [batchCmds addObject:bCmd];
            }
            break;

        case ST_Comp_Delete_Local:
            if(NO == [self.dataSource deleteLocalPoint:tuple.localItem inLocalMap:localMap error:&localError]) {
                tuple.runStatus = ST_Run_Failed;
                allOK = false;
                [allErrors addObject:[self _createError:@"delete local point" withError:localError data:nil]];
            }
            break;

        case ST_Comp_Delete_Remote:
            remotePoint = [self.dataSource createRemotePointFrom:tuple.localItem error:&localError];
            if(remotePoint == nil) {
                tuple.runStatus = ST_Run_Failed;
                allOK = false;
                [allErrors addObject:[self _createError:@"remote point from local" withError:localError data:nil]];
            } else {
                bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_DELETE withItem:remotePoint];
                bCmd.extraData = tuple.localItem;
                [batchCmds addObject:bCmd];
            }
            break;

        case ST_Comp_Update_Local:
            if(NO == [self.dataSource updateLocalPoint:tuple.localItem withRemotePoint:tuple.remoteItem error:&localError]) {
                tuple.runStatus = ST_Run_Failed;
                allOK = false;
                [allErrors addObject:[self _createError:@"update local point from remote" withError:localError data:nil]];
            }
            break;

        case ST_Comp_Update_Remote:
                
            remotePoint = [self.dataSource createRemotePointFrom:tuple.localItem error:&localError];
            if(remotePoint == nil) {
                tuple.runStatus = ST_Run_Failed;
                allOK = false;
                [allErrors addObject:[self _createError:@"remote point from local" withError:localError data:nil]];
            } else {
                bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_UPDATE withItem:remotePoint];
                bCmd.extraData = tuple.localItem;
                [batchCmds addObject:bCmd];
            }
            break;
        }
        
        // Actualiza el estado de ejecucion de la tupla
        if(tuple.runStatus==ST_Run_Processing) tuple.runStatus = ST_Run_OK;
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;


    // Da la orden de actualización batch
    BOOL allPointsOK = [self.gmService processBatchCmds:batchCmds inMap:remoteMap allErrors:allErrors checkCancelBlock:^BOOL{
        return self.mustCancelSync;
    }];
    allOK &= allPointsOK;

    // La creacion o actualizacion de los puntos remotos cambia su gID y el ETAG. Debe actualizar la info local
    for(GMTBatchCmd *bCmd in batchCmds) {
        localError = nil;
        if(bCmd.cmd == BATCH_CMD_DELETE) {
            if(NO == [self.dataSource deleteLocalPoint:bCmd.extraData inLocalMap:localMap error:&localError]) {
                allOK = false;
                [allErrors addObject:[self _createError:@"delete local point after deleting remote" withError:localError data:nil]];
            }
        } else {
            if(NO == [self.dataSource updateLocalPoint:bCmd.extraData withRemotePoint:(GMTPoint *)bCmd.resultItem error:&localError]) {
                allOK = false;
                [allErrors addObject:[self _createError:@"update local point from remote" withError:localError data:nil]];
            }
        }
    }

    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // La creacion de alguno de los puntos hace que el ETAG del mapa remoto cambie
    // Actualiza los datos del mapa local desde el remoto recien actualizado
    // (gID, ETAG, fechas, etc.)
    GMTMap *updatedMap = [self.gmService getMapFromEditURL:remoteMap.editLink error:&localError];
    if(updatedMap == nil) {
        allOK = false;
        [allErrors addObject:[self _createError:@"update remote map" withError:localError data:nil]];
    } else {
        localError = nil;
        if(NO == [self.dataSource updateLocalMap:localMap withRemoteMap:updatedMap allPointsOK:allPointsOK error:&localError]) {
            allOK = false;
            [allErrors addObject:[self _createError:@"update local map" withError:localError data:nil]];
        }
    }

    return allOK;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _makeLocalItems:(NSArray *)localItems equalToRemoteItems:(NSArray *)remoteItems {

    // Aqui se almacenara el resultado de la comparacion
    NSMutableArray *tuples = [NSMutableArray array];

    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Todos los elementos remotos o se crean o se actualizan en local
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparable> remoteItem in remoteItems) {

        id<GMPComparableLocal> localItem = (id<GMPComparableLocal>)[self _searchItemBygID : remoteItem.gID inArray : localItems];

        if(localItems != nil) {
            [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
        } else {
            [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Create_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
        }
    }


    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Todos los elementos locales que no esten en remotos se eliminan
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparableLocal> localItem in localItems) {

        id<GMPComparable> remoteItem = [self _searchItemBygID:localItem.gID inArray:remoteItems];
        if(remoteItem == nil) {
            [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Delete_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
        }
    }

    // Retorna el resultado
    return tuples;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _compareLocalItems:(NSArray *)localItems withRemoteItems:(NSArray *)remoteItems {

    // Aqui se almacenara el resultado de la comparacion
    NSMutableArray *tuples = [NSMutableArray array];


    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos remotos nuevos a crear en local [o borrar en remoto si fueron borrados]
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparable> remoteItem in remoteItems) {

        id<GMPComparableLocal> localItem = (id<GMPComparableLocal>)[self _searchItemBygID : remoteItem.gID inArray : localItems];

        // Si existe el elemento local y no esta marcado como borrado continua
        // (Se actualizara luego al iterar los items locales)
        if(localItem != nil && localItem.markedAsDeletedValue == NO) {
            continue;
        }

        // El que se hace dependera de si existio previamente en local y fue borrada
        if(localItem == nil) {
            // Se crea una nueva entidad local desde la remota
            DDLogVerbose(@"GMapSyncService - Comp: Will create new local entity from remote: %@", remoteItem.name);
            [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Create_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
        } else {
            // Aqui se sabe que la entidad local fue borrada
            if([localItem.etag isEqualToString:remoteItem.etag]) {
                // Puesto que tienen el mismo ETAG se borra la entidad remota
                DDLogVerbose(@"GMapSyncService - Comp: Will delete remote as it wasn't modified and local was deleted: %@", remoteItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Delete_Remote localItem:localItem remoteItem:remoteItem conflicted:false]];
            } else {
                // CONFLICTO: Se borro la entidad local y se modifico la remota
                // RESOLUCION: Se regenera la entidad local desde la remota actualizandola.
                // Se manda actualizar la entidad remota ¿por qué?
                DDLogVerbose(@"GMapSyncService - Comp[WARNING!]: Will update local entity because it was deleted but remote was modified: %@", remoteItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:true]];
            }
        }
    }


    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos locales nuevos a crear en remoto [o borrar en local si fueron borrados]
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparableLocal> localItem in localItems) {

        // No procesa los elementos locales borrados
        if(localItem.markedAsDeletedValue) {
            continue;
        }

        id<GMPComparable> remoteItem = [self _searchItemBygID:localItem.gID inArray:remoteItems];

        // Si la entidad remota existe continua
        // (la gestion de actualizacion se hara despues)
        if(remoteItem != nil) {
            continue;
        }

        // Que se hace dependera de si se sincronizo previamente o es nueva
        if(!localItem.wasSynchronizedValue) {
            // Crea la entidad remota desde la local
            DDLogVerbose(@"GMapSyncService - Comp: Will create new remote from local: %@", localItem.name);
            [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Create_Remote localItem:localItem remoteItem:remoteItem conflicted:false]];
        } else {
            if(!localItem.modifiedSinceLastSyncValue) {
                // Borra la entidad local puesto que no fue modificada y la remota ya no existe
                DDLogVerbose(@"GMapSyncService - Comp: Will delete Local entity as it wasn't modified and remote was deleted previously: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Delete_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
            } else {
                // CONFLICTO: La entidad remota fue borrada pero la local se modificó
                // RESOLUCION: Recrear la entidad remota desde la local de nuevo
                DDLogVerbose(@"GMapSyncService - Comp[WARNING!]: Will create remote entity again from local because the later was changed: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Create_Remote localItem:localItem remoteItem:remoteItem conflicted:true]];
            }
        }
    }


    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos locales y remotos, que existan ambos y difieran para ser actualizados
    // [cual de los dos elementos se actualiza dependera de como esten]
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparableLocal> localItem in localItems) {

        // No procesa los elementos locales borrados
        if(localItem.markedAsDeletedValue) {
            continue;
        }

        id<GMPComparable> remoteItem = [self _searchItemBygID:localItem.gID inArray:remoteItems];

        // Solo procesa si ambas entidades existen
        if(remoteItem == nil) {
            continue;
        }

        // Quien termina actualizado depende de la marca de modificado y los ETAGs
        if(localItem.modifiedSinceLastSyncValue == NO) {
            if([localItem.etag isEqualToString:remoteItem.etag]) {
                // No hay que hacer nada porque los dos son iguales
                DDLogVerbose(@"GMapSyncService - Comp: Nothing will be done as both are equals: %@", localItem.name);
            } else {
                // Actualizamos la entidad local desde la remota
                DDLogVerbose(@"GMapSyncService - Comp: Will update local entity from remote: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
            }
        } else {
            if([localItem.etag isEqualToString:remoteItem.etag]) {
                // Actualiza la entidad remota desde la local
                DDLogVerbose(@"GMapSyncService - Comp: Will update remote entity from local: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Update_Remote localItem:localItem remoteItem:remoteItem conflicted:false]];
            } else {
                // CONFLICTO: Las dos entidades tienen actualizaciones
                // RESOLUCION: Prevalecen los cambios remotos y la entidad local se actualiza
                DDLogVerbose(@"GMapSyncService - Comp[WARNING!]: Will update local entity again from remote because both were changed: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:true]];
            }
        }
    }


    // Retorna el resultado
    return tuples;

}

// ---------------------------------------------------------------------------------------------------------------------
- (id<GMPComparable>) _searchItemBygID:(NSString *)gID inArray:(NSArray *)items {


    for(id<GMPComparable> item in items) {
        if([gID isEqualToString:item.gID]) {
            return item;
        }
    }
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSError *) _createError:(NSString *)desc withError:(NSError *)prevErr data:(id)data {

    NSString *content = data == nil ? @"" : [data description];
    NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             desc, NSLocalizedDescriptionKey,
                             [NSString stringWithFormat:@"Data: %@", content], @"ErrorData",
                             [NSString stringWithFormat:@"%@", prevErr], @"PreviousErrorInfo", nil];
    NSError *err = [NSError errorWithDomain:@"GMapSyncServiceErrorDomain" code:200 userInfo:errInfo];
    return err;
}

@end
