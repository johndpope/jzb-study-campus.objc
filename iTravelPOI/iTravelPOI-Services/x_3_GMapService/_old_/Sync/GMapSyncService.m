//
// GMapSyncService.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMapSyncService_IMPL__
#import "GMapSyncService.h"


#import "GMapSyncComparator.h"
#import "GMPComparable.h"
#import "GMTCompTuple.h"
#import "DDLog.h"
#import "NSError+SimpleInit.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
#define _DELEGATE_ERROR_NOTIFICATION(THE_ERROR) \
    if([self.delegate respondsToSelector:@selector(errorNotification:)]) { \
        [self.delegate errorNotification:THE_ERROR]; \
    }


#define _DELEGATE_MAPS_SYNC_STARTED() \
    if([self.delegate respondsToSelector:@selector(syncStarted)]) { \
        [self.delegate syncStarted]; \
    }


#define _DELEGATE_MAPS_SYNC_FINISHED(ALL_WAS_OK) \
    if([self.delegate respondsToSelector:@selector(syncFinished:)]) { \
    [self.delegate syncFinished:ALL_WAS_OK]; \
    }


#define _DELEGATE_WILL_GET_REMOTE_MAPLIST() \
    if([self.delegate respondsToSelector:@selector(willGetRemoteMapList)]) { \
        [self.delegate willGetRemoteMapList]; \
    }

#define _DELEGATE_DID_GET_REMOTE_MAPLIST() \
    if([self.delegate respondsToSelector:@selector(didGetRemoteMapList)]) { \
        [self.delegate didGetRemoteMapList]; \
    }


#define _DELEGATE_WILL_COMPARE_LOCAL_AND_REMOTE_MAPS() \
    if([self.delegate respondsToSelector:@selector(willCompareLocalAndRemoteMaps)]) { \
        [self.delegate willCompareLocalAndRemoteMaps]; \
    }

#define _DELEGATE_DID_COMPARE_LOCAL_AND_REMOTE_MAPS(THE_TUPLES) \
    if([self.delegate respondsToSelector:@selector(didCompareLocalAndRemoteMaps:)]) { \
        [self.delegate didCompareLocalAndRemoteMaps:THE_TUPLES]; \
    }

#define _DELEGATE_WILL_SYNC_MAP_TUPLE(THE_TUPLE) \
    if([self.delegate respondsToSelector:@selector(willSyncMapTuple:)]) { \
        [self.delegate willSyncMapTuple:THE_TUPLE]; \
    }


#define _DELEGATE_DID_SYNC_MAP_TUPLE(THE_TUPLE) \
    if([self.delegate respondsToSelector:@selector(didSyncMapTuple:)]) { \
        [self.delegate didSyncMapTuple:THE_TUPLE]; \
    }


#define _DELEGATE_SHOULD_PROCESS_MAP_TUPLE(THE_TUPLE) \
    if([self.delegate respondsToSelector:@selector(shouldProcessMapTuple:errRef:)]) { \
        NSError *localError = nil; \
        BOOL doProcessMap = [self.delegate shouldProcessMapTuple:tuple errRef:&localError]; \
        if(localError!=nil) { \
            NSError *anErr = [NSError errorWithDomain:@"GMapSyncService" reason:@"Error processing map tuple:%@.\nLocalError = %@", THE_TUPLE, localError]; \
            _DELEGATE_ERROR_NOTIFICATION(anErr); \
        } \
        if(!doProcessMap || localError!=nil) { \
            tuple.runStatus = ST_Run_Failed; \
        } \
    }



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
+ (GMapSyncService *) serviceWithEmail2:(NSString *)email
                              password:(NSString *)password
                            dataSource:(id<GMPSyncDataSource>)dataSource
                              delegate:(id<GMPSyncDelegate>)delegate
                                 errRef:(NSErrorRef *)errRef {


    DDLogVerbose(@"GMapSyncService - initWithEmailAndPassword");

    if(dataSource == nil) {
        DDLogVerbose(@"GMapSyncService - dataSource cannot be NIL");
        return nil;
    }

    GMapService *srvc = [GMapService serviceWithEmail2:email password:password errRef:errRef];
    if(srvc == nil) {
        DDLogVerbose(@"GMapSyncService - GMapService failed to initialize");
        return nil;
    }

    GMapSyncService *me = [GMapSyncService serviceWithGMapService:srvc dataSource:dataSource delegate:delegate];
    return me;

}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMapSyncService *) serviceWithGMapService:(GMapService *)gmService
                                  dataSource:(id<GMPSyncDataSource>)dataSource
                                    delegate:(id<GMPSyncDelegate>)delegate {
    
    DDLogVerbose(@"GMapSyncService - serviceWithGMapService");
    
    if(dataSource == nil) {
        DDLogVerbose(@"GMapSyncService - dataSource cannot be NIL");
        return nil;
    }

    if(gmService == nil) {
        DDLogVerbose(@"GMapSyncService - gmService cannot be NIL");
        return nil;
    }
    
    GMapSyncService *me = [[GMapSyncService alloc] init];
    me.gmService = gmService;
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
- (BOOL) syncMaps {


    DDLogVerbose(@"GMapSyncService - syncMaps");


    NSError *localError = nil;
    
    
    // Avisa del comienzo del proceso
    _DELEGATE_MAPS_SYNC_STARTED();

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;
    
    
    
    // Consigue la lista de los mapas remotos
    _DELEGATE_WILL_GET_REMOTE_MAPLIST();
    NSArray *remoteMaps = [self.gmService getMapList:&localError];
    if(!remoteMaps || localError!=nil) {
        // Ha habido un error al recuperar los mapas remotos
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Getting remote maps. LocalError = %@", localError]));
        return false;
    }
    _DELEGATE_DID_GET_REMOTE_MAPLIST();


    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // Consigue la lista de los mapas locales
    NSArray *localMaps = [self.dataSource getAllLocalMapList:&localError];
    if(!localMaps || localError!=nil) {
        // Ha habido un error al recuperar los mapas locales
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error getting local maps. LocalError = %@", localError]));
        return false;
    }


    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // Realiza la comparacion de elementos
    DDLogVerbose(@"GMapSyncService - Comparing map lists");
    _DELEGATE_WILL_COMPARE_LOCAL_AND_REMOTE_MAPS();
    NSArray *compTuples = [GMapSyncComparator compareLocalItems:localMaps withRemoteItems:remoteMaps];
    _DELEGATE_DID_COMPARE_LOCAL_AND_REMOTE_MAPS(compTuples);
    
    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return false;

    
    // Itera los resultados de la comparacion
    DDLogVerbose(@"GMapSyncService - ***************************************************************************");
    DDLogVerbose(@"GMapSyncService - Synchronizing map lists (will make changes!)");
    DDLogVerbose(@"GMapSyncService - ***************************************************************************");
    for(GMTCompTuple *tuple in compTuples) {

        // Chequea periodicamente si debe cancelar
        if(self.mustCancelSync) return false;

        
        // Marca la tupla en procesamiento
        tuple.runStatus = ST_Run_Processing;

        // Pregunta si debe procesar esta tupla
        _DELEGATE_SHOULD_PROCESS_MAP_TUPLE(tuple);
        if(tuple.runStatus != ST_Run_Processing) continue;
        
        // Apunta que va a procesar este elemento
        tuple.runStatus = ST_Run_Processing;

        // Avisa del mapa a sincronizar
        _DELEGATE_WILL_SYNC_MAP_TUPLE(tuple);
        
        // Actua en la tupla dependiendo de la accion a acometer
        switch(tuple.compStatus) {

            case ST_Comp_Create_Local:
                [self _createLocalMapWithTuple:tuple];
                break;
                
            case ST_Comp_Create_Remote:
                [self _createRemoteMapWithTuple:tuple];
                break;
                
            case ST_Comp_Delete_Local:
                [self _deleteLocalMapWithTuple:tuple];
                break;
                
            case ST_Comp_Delete_Remote:
                [self _deleteRemoteMapWithTuple:tuple];
                break;
                
            case ST_Comp_Update_Local:
            case ST_Comp_Update_Remote:
                [self _updateLocalAndRemoteMapWithTuple:tuple];
                break;
        }
        
        // Avisa del mapa a sincronizar
        _DELEGATE_DID_SYNC_MAP_TUPLE(tuple);
        
    }
    

    // Chequea si todo se proceso bien o hubo errores
    __block BOOL wasAllOK = TRUE;
    [compTuples enumerateObjectsUsingBlock:^(GMTCompTuple *tuple, NSUInteger idx, BOOL *stop) {
        if(tuple.runStatus != ST_Run_OK) wasAllOK = FALSE;
    }];
    
    
    // Avisa de la finalizacion de la sincronizacion
    _DELEGATE_MAPS_SYNC_FINISHED(wasAllOK);

    
    // Finaliza dando acceso a los errores si los hubo
    return wasAllOK;
}



// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) _createLocalMapWithTuple:(GMTCompTuple *)tuple {

    
    GMTMap *remoteMap = (GMTMap *)tuple.remoteItem;
    
    
    // Para controlar los errores locales
    NSError *localError = nil;

    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;

    
    // Se necesitan todos los puntos del mapa remoto
    localError = nil;
    NSArray *remotePlacemarks = [self.gmService getPlacemarkListFromMap:remoteMap errRef:&localError];
    if(remotePlacemarks == nil || localError!=nil) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error retrieving placemarks from remote map: %@. LocalError = %@", tuple, localError]));
        tuple.runStatus = ST_Run_Failed;
        return;
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;

    
    // Crea el mapa local
    localError = nil;
    id localMap = [self.dataSource createLocalMapFrom:remoteMap errRef:&localError];
    if(localMap == nil || localError!=nil) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error creating local map from remote: %@. LocalError = %@", tuple, localError]));
        tuple.runStatus = ST_Run_Failed;
        return;
    }

    
    // Itera creando todos los puntos locales a partir de los remotos
    BOOL allPlacemarksOK = TRUE;
    for(GMTPlacemark *gmPlacemark in remotePlacemarks) {

        localError = nil;
        id localItem = [self.dataSource createLocalPlacemarkFrom:gmPlacemark inLocalMap:localMap errRef:&localError];
        if(localItem == nil || localError!=nil) {
            _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error creating local placemark from remote: %@. LocalError = %@", tuple, localError]));
            tuple.runStatus = ST_Run_Failed;
            allPlacemarksOK = FALSE;
        }
    }
    
    
    // Actualiza de nuevo el mapa para que quede marcado como sincronizado si todos los puntos se crearon correctamente
    localError = nil;
    if(NO == [self.dataSource updateLocalMap:localMap withRemoteMap:remoteMap allPlacemarksOK:allPlacemarksOK errRef:&localError]) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error updating gID on local map from remote: %@. LocalError = %@", tuple, localError]));
        tuple.runStatus = ST_Run_Failed;
        return;
    }
    
    // Actualiza el estado final de procesado
    tuple.runStatus = (tuple.runStatus==ST_Run_Processing) ? ST_Run_OK : ST_Run_Failed;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _deleteLocalMapWithTuple:(GMTCompTuple *)tuple {

    NSError *localError = nil;
    if(NO == [self.dataSource deleteLocalMap:tuple.localItem errRef:&localError]) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error deleting local map: %@. LocalError = %@", tuple, localError]));
        tuple.runStatus = ST_Run_Failed;
    } else {
        tuple.runStatus = ST_Run_OK;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _createRemoteMapWithTuple:(GMTCompTuple *)tuple {

    // Para controlar los errores locales
    NSError *localError = nil;

    id<GMPComparable> localMap = tuple.localItem;
    
    
    // Consigue la lista de puntos locales
    NSArray *localPlacemarks = [self.dataSource getLocalPlacemarkListForMap:localMap errRef:&localError];
    if(localPlacemarks == nil) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error getting local Placemark list from map: %@. LocalError = %@", tuple, localError]));
        tuple.runStatus = ST_Run_Failed;
        return;
    }

    
    // Crea la version inicial del mapa remoto
    localError = nil;
    GMTMap *gmMap = [self.dataSource newRemoteMapFrom:localMap errRef:&localError];
    if(gmMap == nil || localError!=nil) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error initializing remote map from local data: %@. LocalError = %@", tuple, localError]));
        tuple.runStatus = ST_Run_Failed;
        return;
    }
    
    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;


    // Da la orden de creacion del mapa remoto
    localError = nil;
    GMTMap *createdMap = [self.gmService addMap:gmMap errRef:&localError];
    if(createdMap == nil || localError!=nil) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error creating remote map: %@. LocalError = %@", tuple, localError]));
        tuple.runStatus = ST_Run_Failed;
        return;
    }
    
    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;


    // La creacion del mapa remoto genera su gID y el ETAG inicial. Debe actualizar la info local
    localError = nil;
    if(NO == [self.dataSource updateLocalMap:tuple.localItem withRemoteMap:createdMap allPlacemarksOK:TRUE errRef:&localError]) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error updating local map gID & ETag: %@. LocalError = %@", tuple, localError]));
        tuple.runStatus = ST_Run_Failed;
        return;
    }

    
    // Itera creando comandos batch para la creacion de todos los puntos remotos a partir de los locales
    NSMutableArray *batchCmds = [NSMutableArray array];
    for(id localPlacemark in localPlacemarks) {

        // Inicializa el punto remoto a crear y crea el comando batch de actualizacion
        localError = nil;
        GMTPlacemark *remotePlacemark = [self.dataSource newRemotePlacemarkFrom:localPlacemark inLocalMap:localMap errRef:&localError];
        if(remotePlacemark == nil || localError!=nil) {
            _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error initializing remote placemark from local data: %@. LocalError = %@", tuple, localError]));
            tuple.runStatus = ST_Run_Failed;
        } else {
            GMTBatchCmd *bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_ADD withPlacemark:remotePlacemark];
            bCmd.extraData = localPlacemark;
            [batchCmds addObject:bCmd];
        }
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;

    
    // Da la orden de actualización batch
    // La creacion o actualizacion de los puntos remotos cambia su gID y el ETAG. Debe actualizar la info local
    [self _batchUpdateLocalPlacemarksForTuple:tuple batchCmds:(NSArray *)batchCmds localMap:localMap remoteMap:createdMap];
    
    
    // Actualiza el estado final de procesado
    tuple.runStatus = (tuple.runStatus==ST_Run_Processing) ? ST_Run_OK : ST_Run_Failed;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _deleteRemoteMapWithTuple:(GMTCompTuple *)tuple {

    NSError *localError = nil;
    if(NO == [self.gmService deleteMap:(GMTMap *)tuple.remoteItem errRef:&localError]) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error deleting remote map: %@. LocalError = %@", tuple, localError]));
        tuple.runStatus = ST_Run_Failed;
    } else {
        tuple.runStatus = ST_Run_OK;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _updateLocalAndRemoteMapWithTuple:(GMTCompTuple *)mapTuple {

    // Para controlar los errores locales
    NSError *localError = nil;


    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;

    
    // mapas involucrados
    id<GMPComparable> localMap = mapTuple.localItem;
    GMTMap *remoteMap = (GMTMap *)mapTuple.remoteItem;


    // Se apunta si el mapa local estaba borrado y se esta re-actualizando desde el remoto
    BOOL localMapWasDeleted = localMap.markedAsDeletedValue;


    // Actualiza primero la información del propio mapa
    if(mapTuple.compStatus == ST_Comp_Update_Local) {
        localError = nil;
        if(NO == [self.dataSource updateLocalMap:localMap withRemoteMap:remoteMap allPlacemarksOK:true errRef:&localError]) {
            _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error updating local map from remote: %@. LocalError = %@", mapTuple, localError]));
            mapTuple.runStatus = ST_Run_Failed;
            return;
        }
    } else {
        localError = nil;
        if(![self.dataSource setRemoteMap:remoteMap fromLocalMap:localMap errRef:&localError]) {
            _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error updating remote map from local: %@. LocalError = %@", mapTuple, localError]));
            mapTuple.runStatus = ST_Run_Failed;
            return;
        }
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;


    // Se necesitan todos los puntos del mapa remoto
    localError = nil;
    NSArray *remotePlacemarks = [self.gmService getPlacemarkListFromMap:remoteMap errRef:&localError];
    if(remotePlacemarks == nil || localError!=nil) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error getting placemark list from remote map: %@. LocalError = %@", mapTuple, localError]));
        mapTuple.runStatus = ST_Run_Failed;
        return;
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;


    // Consigue la lista de puntos locales
    localError = nil;
    NSArray *localPlacemarks = [self.dataSource getLocalPlacemarkListForMap:localMap errRef:&localError];
    if(localPlacemarks == nil || localError!=nil) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error getting placemark list from local map: %@. LocalError = %@", mapTuple, localError]));
        mapTuple.runStatus = ST_Run_Failed;
        return;
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;

    
    // Realiza la comparacion de elementos o su copia dependiendo de si el mapa local estaba borrado o no
    DDLogVerbose(@"GMapSyncService - Comparing Placemark lists");
    NSArray *compTuples;
    if(localMapWasDeleted) {
        compTuples = [self _makeLocalItems:localPlacemarks equalToRemoteItems:remotePlacemarks];
    } else {
        compTuples = [GMapSyncComparator compareLocalItems:localPlacemarks withRemoteItems:remotePlacemarks];
    }

    
    // Itera los resultados de la comparacion creando comandos de actualizacion en batch
    DDLogVerbose(@"GMapSyncService - ----------------------------------------------------------------");
    DDLogVerbose(@"GMapSyncService - Synchronizing Placemark lists in map (will make changes!)");
    DDLogVerbose(@"GMapSyncService - ----------------------------------------------------------------");
    NSMutableArray *batchCmds = [NSMutableArray array];
    for(GMTCompTuple *placemarkTuple in compTuples) {

        placemarkTuple.runStatus = ST_Run_Processing;
        
        // Chequea periodicamente si debe cancelar
        if(self.mustCancelSync) return;

        GMTPlacemark *remotePlacemark;
        GMTBatchCmd *bCmd;

        localError = nil;
        switch(placemarkTuple.compStatus) {

        case ST_Comp_Create_Local:
            localError = nil;
            [self.dataSource createLocalPlacemarkFrom:(GMTPlacemark *)placemarkTuple.remoteItem inLocalMap:localMap errRef:&localError];
            if(localError != nil) {
                _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error creating local placemark from remote: %@. LocalError = %@", mapTuple, localError]));
                placemarkTuple.runStatus = ST_Run_Failed;
            }
            break;

        case ST_Comp_Create_Remote:
            localError = nil;
            remotePlacemark = [self.dataSource newRemotePlacemarkFrom:placemarkTuple.localItem inLocalMap:localMap errRef:&localError];
            if(remotePlacemark == nil) {
                _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error initializing remote placemark from local: %@. LocalError = %@", mapTuple, localError]));
                placemarkTuple.runStatus = ST_Run_Failed;
            } else {
                bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_ADD withPlacemark:remotePlacemark];
                bCmd.extraData = placemarkTuple.localItem;
                [batchCmds addObject:bCmd];
            }
            break;

        case ST_Comp_Delete_Local:
            localError = nil;
            if(NO == [self.dataSource deleteLocalPlacemark:placemarkTuple.localItem inLocalMap:localMap errRef:&localError]) {
                _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error deleting local placemark: %@. LocalError = %@", mapTuple, localError]));
                placemarkTuple.runStatus = ST_Run_Failed;
            }
            break;

        case ST_Comp_Delete_Remote:
            localError = nil;
            remotePlacemark = [self.dataSource newRemotePlacemarkFrom:placemarkTuple.localItem inLocalMap:localMap errRef:&localError];
            if(remotePlacemark == nil) {
                _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error initializing remote placemark from local: %@. LocalError = %@", mapTuple, localError]));
                placemarkTuple.runStatus = ST_Run_Failed;
            } else {
                bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_DELETE withPlacemark:remotePlacemark];
                bCmd.extraData = placemarkTuple.localItem;
                [batchCmds addObject:bCmd];
            }
            break;

        case ST_Comp_Update_Local:
            localError = nil;
            if(NO == [self.dataSource updateLocalPlacemark:placemarkTuple.localItem inLocalMap:localMap withRemotePlacemark:(GMTPlacemark *)placemarkTuple.remoteItem errRef:&localError]) {
                _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error updating local placemark from remote: %@. LocalError = %@", mapTuple, localError]));
                placemarkTuple.runStatus = ST_Run_Failed;
            }
            break;

        case ST_Comp_Update_Remote:
            localError = nil;
            remotePlacemark = [self.dataSource newRemotePlacemarkFrom:placemarkTuple.localItem inLocalMap:localMap errRef:&localError];
            if(remotePlacemark == nil || localError!=nil) {
                _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error initializing remote placemark from local: %@. LocalError = %@", mapTuple, localError]));
                placemarkTuple.runStatus = ST_Run_Failed;
            } else {
                bCmd = [GMTBatchCmd batchCmd:BATCH_CMD_UPDATE withPlacemark:remotePlacemark];
                bCmd.extraData = placemarkTuple.localItem;
                [batchCmds addObject:bCmd];
            }
            break;
        }
        
    }

    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;


    // Da la orden de actualización batch
    // La creacion o actualizacion de los puntos remotos cambia su gID y el ETAG. Debe actualizar la info local
    [self _batchUpdateLocalPlacemarksForTuple:mapTuple batchCmds:(NSArray *)batchCmds localMap:localMap remoteMap:remoteMap];

    
    // Actualiza el estado de ejecucion de la tupla
    if(mapTuple.runStatus==ST_Run_Processing) mapTuple.runStatus = ST_Run_OK;

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _batchUpdateLocalPlacemarksForTuple:(GMTCompTuple *)mapTuple batchCmds:(NSArray *)batchCmds localMap:(id<GMPComparable>)localMap remoteMap:(GMTMap *)remoteMap {
    
    // Para controlar los errores locales
    NSError *localError = nil;
    BOOL allPlacemarksOK = TRUE;
    

    // Da la orden de actualización batch
    allPlacemarksOK = [self.gmService processBatchCmds:batchCmds inMap:remoteMap errRef:&localError checkCancelBlock:^BOOL{
        return self.mustCancelSync;
    }];
    if(!allPlacemarksOK || localError!=nil) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error executing batch map update: %@. LocalError = %@", mapTuple, localError]));
        mapTuple.runStatus = ST_Run_Failed;
    }

    // La creacion de los puntos remotos genera su gID y el ETAG inicial. Debe actualizar la info local
    for(GMTBatchCmd *bCmd in batchCmds) {
        
        // Chequea periodicamente si debe cancelar
        if(self.mustCancelSync) return;

        // No procesa los qur tuvieron error
        if(bCmd.resultCode != BATCH_RC_OK) {
            mapTuple.runStatus = ST_Run_Failed;
            allPlacemarksOK = FALSE;
            continue;
        }
        
        // Actualiza el punto local de acuerdo a al resultado del comando
        localError = nil;
        if(bCmd.cmd == BATCH_CMD_DELETE) {
            if(NO == [self.dataSource deleteLocalPlacemark:bCmd.extraData inLocalMap:localMap errRef:&localError]) {
                _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error deleting local placemark gID & ETag: %@. LocalError = %@", mapTuple, localError]));
                mapTuple.runStatus = ST_Run_Failed;
                allPlacemarksOK = FALSE;
            }
        } else {
            
            if(NO == [self.dataSource updateLocalPlacemark:bCmd.extraData inLocalMap:localMap withRemotePlacemark:bCmd.resultPlacemark errRef:&localError]) {
                _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error updating local placemark gID & ETag: %@. LocalError = %@", mapTuple, localError]));
                mapTuple.runStatus = ST_Run_Failed;
                allPlacemarksOK = FALSE;
            }
        }
        
    }
    
    
    // Chequea periodicamente si debe cancelar
    if(self.mustCancelSync) return;
    
    
    // La creacion de alguno de los puntos hace que el ETAG del mapa remoto cambie
    GMTMap *updatedMap;
    if(batchCmds.count > 0) {
        updatedMap = [self.gmService getMapFromEditURL:remoteMap.editLink errRef:&localError];
        if(updatedMap == nil) {
            _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error retrieving remote map for updating local gID & ETag: %@. LocalError = %@", mapTuple, localError]));
            mapTuple.runStatus = ST_Run_Failed;
            updatedMap = remoteMap;
            allPlacemarksOK = FALSE;
        }
    } else {
        updatedMap = remoteMap;
    }
    
    
    // Actualiza los datos del mapa local desde el remoto recien creado y actualizado con los puntos
    // (gID, ETAG, fechas, etc.)
    localError = nil;
    if(NO == [self.dataSource updateLocalMap:mapTuple.localItem withRemoteMap:updatedMap allPlacemarksOK:allPlacemarksOK errRef:&localError]) {
        _DELEGATE_ERROR_NOTIFICATION(([NSError errorWithDomain:@"GMapSyncService" reason:@"Error updating local map gID & ETag: %@. LocalError = %@", mapTuple, localError]));
        mapTuple.runStatus = ST_Run_Failed;
        return;
    }
    
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

        id<GMPComparable> localItem = (id<GMPComparable>)[GMapSyncComparator searchItemBygID : remoteItem.gID inArray : localItems];

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
    for(id<GMPComparable> localItem in localItems) {

        id<GMPComparable> remoteItem = [GMapSyncComparator searchItemBygID:localItem.gID inArray:remoteItems];
        if(remoteItem == nil) {
            [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Delete_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
        }
    }

    // Retorna el resultado
    return tuples;
}


@end
