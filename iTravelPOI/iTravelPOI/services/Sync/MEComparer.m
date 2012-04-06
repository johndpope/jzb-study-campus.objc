//
//  MapEntitiesComparer.m
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEComparer.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation MECompareTuple

@synthesize localEntity = _localEntity;
@synthesize remoteEntity = _remoteEntity;
@synthesize syncStatus = _syncStatus;
@synthesize withConflict =_withConflict;

//---------------------------------------------------------------------------------------------------------------------
+ tupleForLocal:(MEBaseEntity *) local 
        remote:(MEBaseEntity *)  remote 
    syncStatus:(SyncStatusType)  syncStatus
   withConflict:(BOOL)           withConflict {
    
    MECompareTuple *tuple = [[[MECompareTuple alloc] init] autorelease];
    tuple.localEntity = local;
    tuple.remoteEntity = remote;
    tuple.syncStatus = syncStatus;
    tuple.withConflict = withConflict;
    
    return tuple;
}

//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_localEntity release];
    [_remoteEntity release];
    [super dealloc];
}

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation MEComparer



//---------------------------------------------------------------------------------------------------------------------
+ (void) compareLocals:(NSArray *)locals remotes:(NSArray *)remotes compDelegate:(id <MEComparerDelegate>)compDelegate {
    
    
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos remotos nuevos a crear en local [o borrar en remoto si fueron borrados]
    for(MEBaseEntity *remoteEntity in remotes) {
        
        MEBaseEntity *localEntity = [MEBaseEntity searchByGID:remoteEntity.GID inArray:locals];
        
        // Si existe el elemento local y no esta marcado como borrado continua
        if(localEntity != nil && localEntity.isMarkedAsDeleted == NO) {
            continue;
        }
        
        // El que se hace dependera de si existio previamente en local y fue borrada
        if(localEntity == nil) {
            // Se crea una nueva entidad local desde la remota
            NSLog(@"Sync: Create new local entity from remote: %@",remoteEntity.name);
            [compDelegate processTuple:[MECompareTuple tupleForLocal:localEntity remote:remoteEntity 
                                                          syncStatus:ST_Sync_Create_Local withConflict:false]];
        } else {
            // La entidad local fue borrada
            if([localEntity.syncETag isEqualToString:remoteEntity.syncETag]) {
                // Puesto que tienen el mismo ETAG se borra la entidad remota
                NSLog(@"Sync: Delete remote as it wasn't modified and local was deleted: %@",remoteEntity.name);
                [compDelegate processTuple:[MECompareTuple tupleForLocal:localEntity remote:remoteEntity 
                                                              syncStatus:ST_Sync_Delete_Remote withConflict:false]];
            } else {
                // CONFLICTO: Se borró la entidad local y se modifico la remota
                // RESOLUCION: Se regenera la entidad local desde la remota.
                // Se manda actualizar la entidad remota
                NSLog(@"Sync: Update remote entity because it was modified and local was deleted: %@",remoteEntity.name);
                [compDelegate processTuple:[MECompareTuple tupleForLocal:localEntity remote:remoteEntity 
                                                              syncStatus:ST_Sync_Update_Remote withConflict:true]];
            }
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos locales nuevos a crear en remoto [o borrar en local si fueron borrados]
    for(MEBaseEntity *localEntity in locals) {
        
        // No procesa los elementos locales borrados
        if(localEntity.isMarkedAsDeleted) {
            continue;
        }
        
        MEBaseEntity *remoteEntity = [MEBaseEntity searchByGID:localEntity.GID inArray:remotes];
        
        // Si la entidad remota existe continua
        if(remoteEntity != nil) {
            continue;
        }
        
        // Que se hace dependera de si se sincronizo previamente o es nueva
        if(localEntity.isLocal) {
            // Crea la entidad remota desde la local
            NSLog(@"Sync: Create new remote from local: %@",localEntity.name);
            [compDelegate processTuple:[MECompareTuple tupleForLocal:localEntity remote:remoteEntity 
                                                          syncStatus:ST_Sync_Create_Remote withConflict:false]];
        }
        else {
            if(localEntity.changed) {
                // CONFLICTO: La entidad remota fue borrada pero la local se modificó
                // RESOLUCION: Recrear la entidad remota desde la local de nuevo
                NSLog(@"Sync: Remote entity created again from local because the later was changed: %@",localEntity.name);
                [compDelegate processTuple:[MECompareTuple tupleForLocal:localEntity remote:remoteEntity 
                                                              syncStatus:ST_Sync_Create_Remote withConflict:true]];
            } else {
                // Borra la entidad local puesto que no fue modificada y la remota ya no existe
                NSLog(@"Sync: Delete Local entity as it wasn't modified and remote was deleted previously: %@",localEntity.name);
                [compDelegate processTuple:[MECompareTuple tupleForLocal:localEntity remote:remoteEntity 
                                                              syncStatus:ST_Sync_Delete_Local withConflict:false]];
            }
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos locales y remotos que existan en ambos y difieran para ser actualizados [quien dependera de como esten]
    for(MEBaseEntity *localEntity in locals) {
        
        // No procesa los elementos locales borrados
        if(localEntity.isMarkedAsDeleted) {
            continue;
        }
        
        MEBaseEntity *remoteEntity = [MEBaseEntity searchByGID:localEntity.GID inArray:remotes];
        
        // Solo procesa si ambas entidades existen
        if(remoteEntity == nil) {
            continue;
        }
        
        // Quien termina actualizado depende de la marca de modificado y los ETAGs
        if(localEntity.changed == NO) {
            if([localEntity.syncETag isEqualToString:remoteEntity.syncETag]) {
                // No hay que hacer nada porque los dos son iguales
                NSLog(@"Sync: Nothing to be done as both are equals: %@",localEntity.name);
                [compDelegate processTuple:[MECompareTuple tupleForLocal:localEntity remote:remoteEntity 
                                                              syncStatus:ST_Sync_OK withConflict:false]];
            }else {
                // Actualizamos la entidad local desde la remota
                NSLog(@"Sync: Update local entity from remote: %@",localEntity.name);
                [compDelegate processTuple:[MECompareTuple tupleForLocal:localEntity remote:remoteEntity 
                                                              syncStatus:ST_Sync_Update_Local withConflict:false]];
            }
        } else {
            if([localEntity.syncETag isEqualToString:remoteEntity.syncETag]) {
                // Actualiza la entidad remota desde la local
                NSLog(@"Sync: Update remote entity from local: %@",localEntity.name);
                [compDelegate processTuple:[MECompareTuple tupleForLocal:localEntity remote:remoteEntity 
                                                              syncStatus:ST_Sync_Update_Remote withConflict:false]];
            } else {
                // CONFLICTO: Las dos entidades tienen actualizaciones
                // RESOLUCION: Prevalecen los cambios remotos y la entidad local se actualiza
                // Para equilibrar los cambios (por si faltasen elementos referenciados) la entidad remota tambien se actualiza
                [compDelegate processTuple:[MECompareTuple tupleForLocal:localEntity remote:remoteEntity 
                                                              syncStatus:ST_Sync_Update_Remote withConflict:true]];
            }
        }
    }
    
}


@end
