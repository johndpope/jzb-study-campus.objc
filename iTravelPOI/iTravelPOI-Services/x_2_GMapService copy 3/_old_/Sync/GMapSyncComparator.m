//
// GMapSyncComparator.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMapSyncComparator_IMPL__
#import "GMapSyncComparator.h"

#import "GMTItem.h"
#import "DDLog.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMapSyncComparator ()




@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMapSyncComparator





// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) compareLocalItems:(NSArray *)localItems withRemoteItems:(NSArray *)remoteItems {
    
    // Aqui se almacenara el resultado de la comparacion
    NSMutableArray *tuples = [NSMutableArray array];
    
    
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos remotos nuevos a crear en local [o borrar en remoto si fueron borrados]
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparable> remoteItem in remoteItems) {
        
        id<GMPComparable> localItem = (id<GMPComparable>)[self searchItemBygID : remoteItem.gID inArray : localItems];
        
        // Si existe el elemento local y no esta marcado como borrado continua
        // (Se actualizara luego al iterar los items locales)
        if(localItem != nil && localItem.markedAsDeletedValue == NO) {
            continue;
        }
        
        // El que se hace dependera de si existio previamente en local y fue borrada
        if(localItem == nil) {
            // Se crea una nueva entidad local desde la remota
            DDLogVerbose(@"GMapSyncComparator - Comp: Will create new local entity from remote: %@", remoteItem.name);
            [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Create_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
        } else {
            // Aqui se sabe que la entidad local fue borrada
            if([localItem.etag isEqualToString:remoteItem.etag]) {
                // Puesto que tienen el mismo ETAG se borra la entidad remota
                DDLogVerbose(@"GMapSyncComparator - Comp: Will delete remote as it wasn't modified and local was deleted: %@", remoteItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Delete_Remote localItem:localItem remoteItem:remoteItem conflicted:false]];
            } else {
                // CONFLICTO: Se borro la entidad local y se modifico la remota
                // RESOLUCION: Se regenera la entidad local desde la remota actualizandola.
                // Se manda actualizar la entidad remota ¿por qué?
                DDLogVerbose(@"GMapSyncComparator - Comp[WARNING!]: Will update local entity because it was deleted but remote was modified: %@", remoteItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:true]];
            }
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos locales nuevos a crear en remoto [o borrar en local si fueron borrados]
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparable> localItem in localItems) {
        
        // No procesa los elementos locales borrados
        if(localItem.markedAsDeletedValue) {
            continue;
        }
        
        id<GMPComparable> remoteItem = [self searchItemBygID:localItem.gID inArray:remoteItems];
        
        // Si la entidad remota existe continua
        // (la gestion de actualizacion se hara despues)
        if(remoteItem != nil) {
            continue;
        }
        
        // Que se hace dependera de si se sincronizo previamente o es nueva
        if(localItem.hasNoSyncLocalETag) {
            // Crea la entidad remota desde la local
            DDLogVerbose(@"GMapSyncComparator - Comp: Will create new remote from local: %@", localItem.name);
            [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Create_Remote localItem:localItem remoteItem:remoteItem conflicted:false]];
        } else {
            if(!localItem.modifiedSinceLastSyncValue) {
                // Borra la entidad local puesto que no fue modificada y la remota ya no existe
                DDLogVerbose(@"GMapSyncComparator - Comp: Will delete Local entity as it wasn't modified and remote was deleted previously: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Delete_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
            } else {
                // CONFLICTO: La entidad remota fue borrada pero la local se modificó
                // RESOLUCION: Recrear la entidad remota desde la local de nuevo
                DDLogVerbose(@"GMapSyncComparator - Comp[WARNING!]: Will create remote entity again from local because the later was changed: %@", localItem.name);
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
    for(id<GMPComparable> localItem in localItems) {
        
        // No procesa los elementos locales borrados
        if(localItem.markedAsDeletedValue) {
            continue;
        }
        
        id<GMPComparable> remoteItem = [self searchItemBygID:localItem.gID inArray:remoteItems];
        
        // Solo procesa si ambas entidades existen
        if(remoteItem == nil) {
            continue;
        }
        
        // Quien termina actualizado depende de la marca de modificado y los ETAGs
        if(localItem.modifiedSinceLastSyncValue == NO) {
            if([localItem.etag isEqualToString:remoteItem.etag]) {
                // No hay que hacer nada porque los dos son iguales
                DDLogVerbose(@"GMapSyncComparator - Comp: Nothing will be done as both are equals: %@", localItem.name);
            } else {
                // Actualizamos la entidad local desde la remota
                DDLogVerbose(@"GMapSyncComparator - Comp: Will update local entity from remote: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:false]];
            }
        } else {
            if([localItem.etag isEqualToString:remoteItem.etag]) {
                // Actualiza la entidad remota desde la local
                DDLogVerbose(@"GMapSyncComparator - Comp: Will update remote entity from local: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Update_Remote localItem:localItem remoteItem:remoteItem conflicted:false]];
            } else {
                // CONFLICTO: Las dos entidades tienen actualizaciones
                // RESOLUCION: Prevalecen los cambios remotos y la entidad local se actualiza
                DDLogVerbose(@"GMapSyncComparator - Comp[WARNING!]: Will update local entity again from remote because both were changed: %@", localItem.name);
                [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Update_Local localItem:localItem remoteItem:remoteItem conflicted:true]];
            }
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos locales borrados para ser actualizados
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    for(id<GMPComparable> localItem in localItems) {
        
        // Solo procesa los elementos locales borrados
        if(!localItem.markedAsDeletedValue) {
            continue;
        }
        
        // Solo los que no tenian un elemento remoto
        id<GMPComparable> remoteItem = [self searchItemBygID:localItem.gID inArray:remoteItems];
        if(remoteItem) {
            continue;
        }
        
        // Borra la entidad local puesto que no fue modificada y la remota ya no existe
        DDLogVerbose(@"GMapSyncComparator - Comp: Will delete Local entity as remote was also deleted: %@", localItem.name);
        [tuples addObject:[GMTCompTuple tupleWithCompStatus:ST_Comp_Delete_Local localItem:localItem remoteItem:remoteItem conflicted:false]];

    }
    
    // Retorna el resultado
    return tuples;
    
}

// ---------------------------------------------------------------------------------------------------------------------
+ (id<GMPComparable>) searchItemBygID:(NSString *)gID inArray:(NSArray *)items {
    
    
    for(id<GMPComparable> item in items) {
        if([gID isEqualToString:item.gID]) {
            return item;
        }
    }
    return nil;
}





// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------



// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
