//
//  CollectionMerger.m
//  WCDTest
//
//  Created by jzarzuela on 16/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CollectionMerger.h"
#import "TBaseEntity.h"
#import "TMap.h"
#import "TCategory.h"
#import "TPoint.h"
#import "MergeEntityCat.h"


//---------------------------------------------------------------------------------------------------------------------
TBaseEntity * _createNewLocalEntity(TMap *localMap, TBaseEntity *remoteEntity);
BOOL _needToBeUpdatedAfterCreateLocally(TBaseEntity *item1, TBaseEntity *item2);




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation CollectionMerger

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
    [super dealloc];
}



//---------------------------------------------------------------------------------------------------------------------
TBaseEntity * _createNewLocalEntity(TMap *localMap, TBaseEntity *remoteEntity) {
    
    if([remoteEntity isKindOfClass: [TMap class]]) {
        return [TMap insertNew];
    } else if([remoteEntity isKindOfClass: [TCategory class]]) {
        return [TCategory insertNewInMap:localMap];
    } else if([remoteEntity isKindOfClass: [TPoint class]]) {
        return [TPoint insertNewInMap:localMap];
    } else {
        return nil;
    }
    
}

// ----------------------------------------------------------------------------------------------------
BOOL _needToBeUpdatedAfterCreateLocally(TBaseEntity *item1, TBaseEntity *item2) {
    
    // Solo comprueba que las categorias terminan teniendo el mismo numero de subelementos
    if([item1 isKindOfClass:[TCategory class]]) {
        TCategory *c1 = (TCategory *)item1;
        TCategory *c2 = (TCategory *)item2;
        BOOL eq1 = [c1.points count] == [c2.points count];
        BOOL eq2 = [c1.subcategories count] == [c2.subcategories count];
        return eq1 && eq2;
    }else {
        return false;
    }
}


//---------------------------------------------------------------------------------------------------------------------
// Pasos:
// Busca elementos remotos nuevos a crear en local [o borrar en remoto]
// Busca elementos locales nuevos a crear en remoto [o borrar en local]
// Busca elementos existentes en ambos para actualizar [Quien depende de info de cambios]
// [Debe ser el ultimo por cambios de dependencias contra algo nuevo que crean los anteriores]
// [En teoria, lo creado en pasos previos deberia dar OK en este y no hacer nada]
+ (NSArray *) merge:(NSArray *)locals remotes:(NSArray * )remotes inLocalMap:(TMap *)localMap {
    
    NSMutableArray *newAddedEntities = [NSMutableArray array];
    
    
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos remotos nuevos a crear en local [o borrar en remoto si fueron borrados]
    for(TBaseEntity *remoteEntity in remotes) {
        
        TBaseEntity *localEntity = [TBaseEntity searchByGID:remoteEntity.GID inArray:locals];
        
        // Solo procesa los nuevos
        if(localEntity != nil && !localEntity.wasDeleted) {
            continue;
        }
        
        // El que se hace dependera de si existio previamente en local y fue borrada
        if(localEntity == nil) {
            // Se crea una nueva entidad local desde la remota
            NSLog(@"Sync: Creating local entity from remote: %@",remoteEntity.name);
            TBaseEntity *newLocal = _createNewLocalEntity(localMap, remoteEntity);
            [newLocal mergeFrom:remoteEntity withConflit:false];
            newLocal.syncStatus = ST_Sync_Create_Local;
            [newAddedEntities addObject:newLocal];
            // Si no quedaron iguales, porque faltaban dependencias, hay que actualizar el remoto tambien
            if(_needToBeUpdatedAfterCreateLocally(newLocal, remoteEntity)){
                NSLog(@"Sync: Created local entity differs from the original remote and the later must be updated: %@",remoteEntity.name);
                newLocal.syncStatus = ST_Sync_Update_Remote;
            }
        } else {
            // La entidad local fue borrada
            if([localEntity.syncETag isEqualToString:remoteEntity.syncETag]) {
                // Puesto que tienen el mismo ETAG se borra la entidad remota
                NSLog(@"Sync: Delete remote as it wasn't modified and local was deleted: %@",remoteEntity.name);
                localEntity.syncStatus = ST_Sync_Delete_Remote;
            }else {
                // CONFLICTO: Se borró la entidad local y se modifico la remota
                // RESOLUCION: Se regenera la entidad local desde la remota.
                // Se manda actualizar la entidad remota
                localEntity.wasDeleted = false;
                [localEntity mergeFrom:remoteEntity withConflit:true];
                localEntity.syncStatus = ST_Sync_Update_Remote;
            }
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos locales nuevos a crear en remoto [o borrar en local si fueron borrados]
    for(TBaseEntity *localEntity in locals) {
        
        // No procesa los elementos locales borrados
        if(localEntity.wasDeleted) {
            continue;
        }
        
        TBaseEntity *remoteEntity = [TBaseEntity searchByGID:localEntity.GID inArray:remotes];
        
        // Solo procesa los nuevos
        if(remoteEntity != nil) {
            continue;
        }
        
        // Que se hace dependera de si se sincronizo previamente o es nueva
        if(localEntity.isLocal) {
            // Crea la entidad remota desde la local
            NSLog(@"Sync: Create new remote from local: %@",localEntity.name);
            localEntity.syncStatus = ST_Sync_Create_Remote;
        }
        else {
            if(localEntity.changed) {
                // CONFLICTO: La entidad remota fue borrada pero la local se modificó
                // RESOLUCION: Recrear la entidad remota desde la local de nuevo
                NSLog(@"Sync: Remote entity created again from local because the later was changed: %@",localEntity.name);
                localEntity.syncStatus = ST_Sync_Create_Remote;
            } else {
                // Borra la entidad local puesto que no fue modificada y la remota ya no existe
                NSLog(@"Sync: Local entity deleted as it wasn't modifies and remote was deleted previously: %@",localEntity.name);
                localEntity.syncStatus = ST_Sync_Delete_Local;
                localEntity.wasDeleted = true;
            }
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos locales y remotos que existan en ambos y difieran para ser actualizados [quien dependera de como esten]
    for(TBaseEntity *localEntity in locals) {
        
        // No procesa los elementos locales borrados
        if(localEntity.wasDeleted) {
            continue;
        }
        
        TBaseEntity *remoteEntity = [TBaseEntity searchByGID:localEntity.GID inArray:remotes];
        
        // Solo procesa lo existente
        if(remoteEntity == nil) {
            continue;
        }
        
        // Quien termina actualizado depende de la marca de modificado y los ETAGs
        if(localEntity.changed) {
            if([localEntity.syncETag isEqualToString:remoteEntity.syncETag]) {
                // No hay que hacer nada porque los dos son iguales
                NSLog(@"Sync: Nothing to be done as both are equals: %@",localEntity.name);
                localEntity.syncStatus = ST_Sync_OK;
            }else {
                // Actualizamos la entidad local desde la remota
                NSLog(@"Sync: Local entity has to be updated from remote: %@",localEntity.name);
                [localEntity mergeFrom:remoteEntity withConflit:false];
                localEntity.syncStatus = ST_Sync_Update_Local;
            }
        }else {
            if([localEntity.syncETag isEqualToString:remoteEntity.syncETag]) {
                // Actualiza la entidad remota desde la local
                NSLog(@"Sync: Remote entity has to be updated from local: %@",localEntity.name);
                localEntity.syncStatus = ST_Sync_Update_Remote;
            } else {
                // CONFLICTO: Las dos entidades tienen actualizaciones
                // RESOLUCION: Prevalecen los cambios remotos y la entidad local se actualiza
                // Para equilibrar los cambios (por si faltasen elementos referenciados) la entidad remota tambien se actualiza
                [localEntity mergeFrom:remoteEntity withConflit:true];
                localEntity.syncStatus = ST_Sync_Update_Remote;
            }
        }
    }
    
    // Retorna la lista de entidades creadas
    return [[newAddedEntities copy] autorelease];
    
}






@end
