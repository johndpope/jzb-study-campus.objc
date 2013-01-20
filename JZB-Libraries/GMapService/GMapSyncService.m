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


@property (strong) GMapService *gmService;
@property (strong) id<GMPSyncDelegate> delegate;


- (NSArray *) compareLocalItems:(NSArray *)localItems withRemoteItems:(NSArray *)remoteItems;
- (id<GMPComparable>) searchItemByGMID:(NSString *)gmID inArray:(NSArray *)items;

- (void) createLocalMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors;
- (void) deleteLocalMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors;

- (void) createRemoteMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors;
- (void) deleteRemoteMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors;

- (void) updateLocalAndRemoteMapWithTuple:(GMTCompTuple *)mapTuple allErrors:(NSMutableArray *)allErrors;

- (NSError *) anError:(NSString *)desc withError:(NSError *)prevErr data:(id)data;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMapSyncService


@synthesize gmService = _gmService;
@synthesize delegate = _delegate;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMapSyncService *) serviceWithEmail:(NSString *)email
                              password:(NSString *)password
                              delegate:(id<GMPSyncDelegate>)delegate
                                 error:(NSError **)err {


    DDLogVerbose(@"GMapSyncService - initWithEmailAndPassword");

    if(delegate == nil) {
        DDLogVerbose(@"GMapSyncService - delegate cannot be NIL");
        return nil;
    }

    GMapService *srvc = [GMapService serviceWithEmail:email password:password error:err];
    if(srvc == nil) {
        DDLogVerbose(@"GMapSyncService - GMapService failed to initialize");
        return nil;
    }

    GMapSyncService *me = [[GMapSyncService alloc] init];
    me.gmService = srvc;
    me.delegate = delegate;
    return me;

}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) syncMaps:(NSError **)err {


    DDLogVerbose(@"GMapSyncService - syncMaps");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;



    // Para acumular errores
    NSMutableArray *allErrors = [NSMutableArray array];


    // Consigue la lista de los mapas remotos
    NSArray *remoteMaps = [self.gmService getMapList:err];
    if(*err || !remoteMaps) {
        // Ha habido un error al recuperar los mapas locales
        DDLogVerbose(@"GMapSyncService - Error reading remote maps: %@", *err);
        return false;
    }


    // Consigue la lista de los mapas locales
    NSArray *localMaps = [self.delegate getAllLocalMapList:err];
    if(*err || !localMaps) {
        // Ha habido un error al recuperar los mapas locales
        DDLogVerbose(@"GMapSyncService - Error reading local maps: %@", *err);
        return false;
    }



    // Realiza la comparacion de elementos
    DDLogVerbose(@"GMapSyncService - Comparing map lists");
    NSArray *compTuples = [self compareLocalItems:localMaps withRemoteItems:remoteMaps];

    // Itera los resultados de la comparacion
    DDLogVerbose(@"GMapSyncService - Synchronizing map lists");
    for(GMTCompTuple *tuple in compTuples) {

        switch(tuple.status) {

        case ST_Comp_Create_Local:
            [self createLocalMapWithTuple:tuple allErrors:allErrors];
            break;

        case ST_Comp_Create_Remote:
            [self createRemoteMapWithTuple:tuple allErrors:allErrors];
            break;

        case ST_Comp_Delete_Local:
            [self deleteLocalMapWithTuple:tuple allErrors:allErrors];
            break;

        case ST_Comp_Delete_Remote:
            [self deleteRemoteMapWithTuple:tuple allErrors:allErrors];
            break;

        case ST_Comp_Update_Local:
        case ST_Comp_Update_Remote:
            [self updateLocalAndRemoteMapWithTuple:tuple allErrors:allErrors];
            break;
        }
    }


    // Todo termino bien si no hubo errores
    if(allErrors.count > 0) {
        *err = [self anError:@"There were errors during processing" withError:nil data:allErrors];
        return false;
    } else {
        return true;
    }

}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) createLocalMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors {

    // Para controlar los errores locales
    NSError *localError = nil;


    // Se necesitan todos los puntos del mapa remoto
    localError = nil;
    NSArray *remotePoints = [self.gmService getPointListFromMap:tuple.remoteItem error:&localError];
    if(remotePoints == nil) {
        [allErrors addObject:[self anError:@"remote point from local" withError:localError data:nil]];
        return;
    }

    // Crea el mapa local
    localError = nil;
    id localMap = [self.delegate createLocalMapFrom:tuple.remoteItem error:&localError];
    if(localMap == nil) {
        [allErrors addObject:[self anError:@"local map from remote" withError:localError data:nil]];
        return;
    }

    // Itera creando todos los puntos locales a partir de los remotos
    for(GMTPoint *gmPoint in remotePoints) {
        localError = nil;
        id localPoint = [self.delegate createLocalPointFrom:gmPoint inLocalMap:localMap error:&localError];
        if(localPoint == nil) {
            [allErrors addObject:[self anError:@"local point from remote" withError:localError data:nil]];
        }
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) deleteLocalMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors {

    NSError *localError = nil;
    if(NO == [self.delegate deleteLocalMap:tuple.localItem error:&localError]) {
        [allErrors addObject:[self anError:@"delete local map" withError:localError data:nil]];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) createRemoteMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors {

    // Para controlar los errores locales
    NSError *localError = nil;

    // Consigue la lista de puntos locales
    NSArray *localPoints = [self.delegate localPointListForMap:tuple.localItem error:&localError];
    if(localPoints == nil) {
        [allErrors addObject:[self anError:@"get local point list from map" withError:localError data:nil]];
        return;
    }

    // Consigue el mapa remoto a crear
    localError = nil;
    GMTMap *gmMap = [self.delegate gmMapFromLocalMap:tuple.localItem error:&localError];
    if(gmMap == nil) {
        [allErrors addObject:[self anError:@"remote map from local" withError:localError data:nil]];
        return;
    }

    // Da la orden de creacion del mapa remoto
    localError = nil;
    GMTMap *createdMap = [self.gmService addMap:gmMap error:&localError];
    if(createdMap == nil) {
        [allErrors addObject:[self anError:@"create remote map" withError:localError data:nil]];
        return;
    }

    // La creacion del mapa remoto genera su gmID y el ETAG inicial. Debe actualizar la info local
    localError = nil;
    if(NO == [self.delegate updateLocalMap:tuple.localItem withRemoteMap:createdMap allPointsOK:true error:&localError]) {
        [allErrors addObject:[self anError:@"update local map from remote" withError:localError data:nil]];
    }

    // Itera creando ordenes batch de creacion de todos los puntos remotos a partir de los locales
    NSMutableArray *batchCmds = [NSMutableArray array];
    for(id localPoint in localPoints) {

        // Consigue el punto remoto a crear
        localError = nil;
        GMTPoint *remotePoint = [self.delegate gmPointFromLocalPoint:localPoint error:&localError];
        if(remotePoint == nil) {
            [allErrors addObject:[self anError:@"remote point from local" withError:localError data:nil]];
            return;
        }


        // Crea el comando batch de actualizacion
        if(remotePoint != nil) {
            GMTBatchCmd *bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_INSERT withItem:remotePoint];
            bCmd.extraData = localPoint;
            [batchCmds addObject:bCmd];
        }
    }

    // Da la orden de actualización batch
    BOOL allPointsOK = [self.gmService processBatchCmds:batchCmds inMap:createdMap allErrors:allErrors];

    // La creacion de los puntos remotos genera su gmID y el ETAG inicial. Debe actualizar la info local
    for(GMTBatchCmd *bCmd in batchCmds) {
        localError = nil;
        if(NO == [self.delegate updateLocalPoint:bCmd.extraData withRemotePoint:(GMTPoint *)bCmd.resultItem error:&localError]) {
            [allErrors addObject:[self anError:@"update local point from remote" withError:localError data:nil]];
        }
    }

    // La creacion de alguno de los puntos hace que el ETAG del mapa remoto cambie
    GMTMap *updatedMap;
    if(batchCmds.count > 0) {
        updatedMap = [self.gmService getMapFromEditURL:createdMap.editLink error:&localError];
        if(updatedMap == nil) {
            [allErrors addObject:[self anError:@"update remote map" withError:localError data:nil]];
            updatedMap = createdMap;
        }
    } else {
        updatedMap = createdMap;
    }

    // Actualiza los datos del mapa local desde el remoto recien creado y actualizado con los puntos
    // (gmID, ETAG, fechas, etc.)
    localError = nil;
    if(NO == [self.delegate updateLocalMap:tuple.localItem withRemoteMap:updatedMap allPointsOK:allPointsOK error:&localError]) {
        [allErrors addObject:[self anError:@"update local map from remote" withError:localError data:nil]];
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) deleteRemoteMapWithTuple:(GMTCompTuple *)tuple allErrors:(NSMutableArray *)allErrors {

    NSError *localError = nil;
    [self.gmService deleteMap:tuple.remoteItem error:&localError];
    if(localError != nil) {
        [allErrors addObject:[self anError:@"delete remote map" withError:localError data:nil]];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) updateLocalAndRemoteMapWithTuple:(GMTCompTuple *)mapTuple allErrors:(NSMutableArray *)allErrors {

    // Para controlar los errores locales
    NSError *localError = nil;


    // mapas involucrados
    id<GMPComparableLocal> localMap = mapTuple.localItem;
    GMTMap *remoteMap = mapTuple.remoteItem;

    
    // Se apunta si el mapa local estaba borrado y se esta re-actualizando desde el remoto
    BOOL localMapWasDeleted = localMap.markedAsDeletedValue;


    // Actualiza primero la información del propio mapa
    if(mapTuple.status == ST_Comp_Update_Local) {
        if(NO == [self.delegate updateLocalMap:localMap withRemoteMap:remoteMap allPointsOK:true error:&localError]) {
            [allErrors addObject:[self anError:@"update local map from remote" withError:localError data:nil]];
            return;
        }
    } else {
        localError = nil;
        GMTMap *mapToUpdate = [self.delegate gmMapFromLocalMap:localMap error:&localError];
        if(mapToUpdate == nil) {
            [allErrors addObject:[self anError:@"remote map from local" withError:localError data:nil]];
            return;
        }

        localError = nil;
        remoteMap = [self.gmService updateMap:mapToUpdate error:&localError];
        if(remoteMap == nil) {
            [allErrors addObject:[self anError:@"update remote map" withError:localError data:nil]];
            return;
        }
        
        // Tiene que actualizar el ETAG del mapa local tras la actualizacion remota
        if(NO == [self.delegate updateLocalMap:localMap withRemoteMap:remoteMap allPointsOK:true error:&localError]) {
            [allErrors addObject:[self anError:@"update local map from remote" withError:localError data:nil]];
            return;
        }

    }


    // Se necesitan todos los puntos del mapa remoto
    localError = nil;
    NSArray *remotePoints = [self.gmService getPointListFromMap:remoteMap error:&localError];
    if(remotePoints == nil) {
        [allErrors addObject:[self anError:@"get point list from remote map" withError:localError data:nil]];
        return;
    }

    // Consigue la lista de puntos locales
    NSArray *localPoints = [self.delegate localPointListForMap:localMap error:&localError];
    if(localPoints == nil) {
        [allErrors addObject:[self anError:@"get point list from local map" withError:localError data:nil]];
        return;
    }

    // Realiza la comparacion de elementos o su copia dependiendo de si el mapa local estaba borrado o no
    DDLogVerbose(@"GMapSyncService - Comparing point lists");
    NSArray *compTuples;
    if(localMapWasDeleted) {
        compTuples = [self makeEqualLocalItems:localPoints toRemoteItems:remotePoints];
    } else {
        compTuples = [self compareLocalItems:localPoints withRemoteItems:remotePoints];
    }

    // Itera los resultados de la comparacion creando comandos de actualizacion en batch
    DDLogVerbose(@"GMapSyncService - Synchronizing point lists");
    NSMutableArray *batchCmds = [NSMutableArray array];
    for(GMTCompTuple *tuple in compTuples) {

        GMTPoint *remotePoint;
        GMTBatchCmd *bCmd;

        switch(tuple.status) {

        case ST_Comp_Create_Local:
            localError = nil;
            [self.delegate createLocalPointFrom:tuple.remoteItem inLocalMap:localMap error:&localError];
            if(localError != nil) {
                [allErrors addObject:[self anError:@"create local pointe" withError:localError data:nil]];
            }
            break;

        case ST_Comp_Create_Remote:
            localError = nil;
            remotePoint = [self.delegate gmPointFromLocalPoint:tuple.localItem error:&localError];
            if(remotePoint == nil) {
                [allErrors addObject:[self anError:@"remote point from local" withError:localError data:nil]];
                return;
            }

            bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_INSERT withItem:remotePoint];
            bCmd.extraData = tuple.localItem;
            [batchCmds addObject:bCmd];
            break;

        case ST_Comp_Delete_Local:
            localError = nil;
            if(NO == [self.delegate deleteLocalPoint:tuple.localItem inLocalMap:localMap error:&localError]) {
                [allErrors addObject:[self anError:@"delete local point" withError:localError data:nil]];
            }
            break;

        case ST_Comp_Delete_Remote:
            localError = nil;
            remotePoint = [self.delegate gmPointFromLocalPoint:tuple.localItem error:&localError];
            if(remotePoint == nil) {
                [allErrors addObject:[self anError:@"remote point from local" withError:localError data:nil]];
                return;
            }
            bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_DELETE withItem:remotePoint];
            bCmd.extraData = tuple.localItem;
            [batchCmds addObject:bCmd];
            break;

        case ST_Comp_Update_Local:
            if(NO == [self.delegate updateLocalPoint:tuple.localItem withRemotePoint:tuple.remoteItem error:&localError]) {
                [allErrors addObject:[self anError:@"update local point from remote" withError:localError data:nil]];
            }
            break;

        case ST_Comp_Update_Remote:
            localError = nil;
            remotePoint = [self.delegate gmPointFromLocalPoint:tuple.localItem error:&localError];
            if(remotePoint == nil) {
                [allErrors addObject:[self anError:@"remote point from local" withError:localError data:nil]];
                return;
            }
            bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_UPDATE withItem:remotePoint];
            bCmd.extraData = tuple.localItem;
            [batchCmds addObject:bCmd];
            break;
        }
    }

    // Da la orden de actualización batch
    BOOL allPointsOK = [self.gmService processBatchCmds:batchCmds inMap:remoteMap allErrors:allErrors];

    // La creacion o actualizacion de los puntos remotos cambia su gmID y el ETAG. Debe actualizar la info local
    for(GMTBatchCmd *bCmd in batchCmds) {
        localError = nil;
        if(NO == [self.delegate updateLocalPoint:bCmd.extraData withRemotePoint:(GMTPoint *)bCmd.resultItem error:&localError]) {
            [allErrors addObject:[self anError:@"update local point from remote" withError:localError data:nil]];
        }
    }

    // La creacion de alguno de los puntos hace que el ETAG del mapa remoto cambie
    GMTMap *updatedMap;
    if(batchCmds.count > 0) {
        updatedMap = [self.gmService getMapFromEditURL:remoteMap.editLink error:&localError];
        if(updatedMap == nil) {
            [allErrors addObject:[self anError:@"update remote map" withError:localError data:nil]];
            updatedMap = remoteMap;
        }
    } else {
        updatedMap = remoteMap;
    }

    // Actualiza los datos del mapa local desde el remoto recien actualizado
    // (gmID, ETAG, fechas, etc.)
    localError = nil;
    if(NO == [self.delegate updateLocalMap:localMap withRemoteMap:updatedMap allPointsOK:allPointsOK error:&localError]) {
        [allErrors addObject:[self anError:@"update local map" withError:localError data:nil]];
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) makeEqualLocalItems:(NSArray *)localItems toRemoteItems:(NSArray *)remoteItems {
    
    // Aqui se almacenara el resultado de la comparacion
    NSMutableArray *tuples = [NSMutableArray array];
    
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Todos los elementos remotos o se crean o se actualizan en local
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparable> remoteItem in remoteItems) {

        id<GMPComparableLocal> localItem = (id<GMPComparableLocal>)[self searchItemByGMID : remoteItem.gmID inArray : localItems];
        
        if(localItems!=nil) {
            [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
        } else {
            [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Create_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Todos los elementos locales que no esten en remotos se eliminan
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparableLocal> localItem in localItems) {
        
        id<GMPComparable> remoteItem = [self searchItemByGMID:localItem.gmID inArray:remoteItems];
        if(remoteItem==nil) {
            [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Delete_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
        }
    }
    
    // Retorna el resultado
    return tuples;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) compareLocalItems:(NSArray *)localItems withRemoteItems:(NSArray *)remoteItems {

    // Aqui se almacenara el resultado de la comparacion
    NSMutableArray *tuples = [NSMutableArray array];


    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos remotos nuevos a crear en local [o borrar en remoto si fueron borrados]
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparable> remoteItem in remoteItems) {

        id<GMPComparableLocal> localItem = (id<GMPComparableLocal>)[self searchItemByGMID : remoteItem.gmID inArray : localItems];

        // Si existe el elemento local y no esta marcado como borrado continua
        // (Se actualizara luego al iterar los items locales)
        if(localItem != nil && localItem.markedAsDeletedValue == NO) {
            continue;
        }

        // El que se hace dependera de si existio previamente en local y fue borrada
        if(localItem == nil) {
            // Se crea una nueva entidad local desde la remota
            DDLogVerbose(@"GMapSyncService - Comp: Create new local entity from remote: %@", remoteItem.name);
            [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Create_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
        } else {
            // Aqui se sabe que la entidad local fue borrada
            if([localItem.etag isEqualToString:remoteItem.etag]) {
                // Puesto que tienen el mismo ETAG se borra la entidad remota
                DDLogVerbose(@"GMapSyncService - Comp: Delete remote as it wasn't modified and local was deleted: %@", remoteItem.name);
                [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Delete_Remote localItem:localItem remoteItem:remoteItem conflicted:false]];
            } else {
                // CONFLICTO: Se borro la entidad local y se modifico la remota
                // RESOLUCION: Se regenera la entidad local desde la remota actualizandola.
                // Se manda actualizar la entidad remota ¿por qué?
                DDLogVerbose(@"GMapSyncService - Comp[!]: Update local entity because it was deleted but remote was modified: %@", remoteItem.name);
                [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:true]];
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

        id<GMPComparable> remoteItem = [self searchItemByGMID:localItem.gmID inArray:remoteItems];

        // Si la entidad remota existe continua
        // (la gestion de actualizacion se hara despues)
        if(remoteItem != nil) {
            continue;
        }

        // Que se hace dependera de si se sincronizo previamente o es nueva
        if(!localItem.wasSynchronizedValue) {
            // Crea la entidad remota desde la local
            DDLogVerbose(@"GMapSyncService - Comp: Create new remote from local: %@", localItem.name);
            [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Create_Remote localItem:localItem remoteItem:remoteItem conflicted:false]];
        } else {
            if(!localItem.modifiedSinceLastSyncValue) {
                // Borra la entidad local puesto que no fue modificada y la remota ya no existe
                DDLogVerbose(@"GMapSyncService - Comp: Delete Local entity as it wasn't modified and remote was deleted previously: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Delete_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
            } else {
                // CONFLICTO: La entidad remota fue borrada pero la local se modificó
                // RESOLUCION: Recrear la entidad remota desde la local de nuevo
                DDLogVerbose(@"GMapSyncService - Comp[!]: Remote entity created again from local because the later was changed: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Create_Remote localItem:localItem remoteItem:remoteItem conflicted:true]];
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

        id<GMPComparable> remoteItem = [self searchItemByGMID:localItem.gmID inArray:remoteItems];

        // Solo procesa si ambas entidades existen
        if(remoteItem == nil) {
            continue;
        }

        // Quien termina actualizado depende de la marca de modificado y los ETAGs
        if(localItem.modifiedSinceLastSyncValue == NO) {
            if([localItem.etag isEqualToString:remoteItem.etag]) {
                // No hay que hacer nada porque los dos son iguales
                DDLogVerbose(@"GMapSyncService - Comp: Nothing to be done as both are equals: %@", localItem.name);
            } else {
                // Actualizamos la entidad local desde la remota
                DDLogVerbose(@"GMapSyncService - Comp: Update local entity from remote: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
            }
        } else {
            if([localItem.etag isEqualToString:remoteItem.etag]) {
                // Actualiza la entidad remota desde la local
                DDLogVerbose(@"GMapSyncService - Comp: Update remote entity from local: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Update_Remote localItem:localItem remoteItem:remoteItem conflicted:false]];
            } else {
                // CONFLICTO: Las dos entidades tienen actualizaciones
                // RESOLUCION: Prevalecen los cambios remotos y la entidad local se actualiza
                DDLogVerbose(@"GMapSyncService - Comp[!]: Local entity updated again from remote because both were changed: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:true]];
            }
        }
    }


    // Retorna el resultado
    return tuples;

}

// ---------------------------------------------------------------------------------------------------------------------
- (id<GMPComparable>) searchItemByGMID:(NSString *)gmID inArray:(NSArray *)items {


    for(id<GMPComparable> item in items) {
        if([gmID isEqualToString:item.gmID]) {
            return item;
        }
    }
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSError *) anError:(NSString *)desc withError:(NSError *)prevErr data:(id)data {

    NSString *content = data == nil ? @"" : [data description];
    NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             desc, NSLocalizedDescriptionKey,
                             [NSString stringWithFormat:@"Data: %@", content], @"ErrorData",
                             [NSString stringWithFormat:@"%@", prevErr], @"PreviousErrorInfo", nil];
    NSError *err = [NSError errorWithDomain:@"GMapSyncServiceErrorDomain" code:200 userInfo:errInfo];
    return err;
}

@end
