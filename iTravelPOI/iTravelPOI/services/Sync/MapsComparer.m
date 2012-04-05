//
//  MapsComparer.m
//  iTravelPOI
//
//  Created by JZarzuela on 05/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapsComparer.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation MapsCompareItem

@synthesize localMap = _localMap;
@synthesize remoteMap = _remoteMap;
@synthesize syncStatus = _syncStatus;


//---------------------------------------------------------------------------------------------------------------------
+ itemForLocalMap:(MEMap *)localMap remoteMap:(MEMap *)remoteMap {
    
    MapsCompareItem *item = [[[MapsCompareItem alloc] init] autorelease];
    item.localMap = localMap;
    item.remoteMap = remoteMap;
    return item;
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
    [_localMap release];
    [_remoteMap release];
    [super dealloc];
}


@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation MapsComparer


//---------------------------------------------------------------------------------------------------------------------
+ (NSMutableArray *) compareLocals:(NSArray *)localMaps remoteMaps:(NSArray *)remoteMaps {
    
    NSMutableArray *result = [NSMutableArray array];
    
    
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos remotos nuevos a crear en local [o borrar en remoto si fueron borrados]
    for(MEMap *remoteMap in remoteMaps) {
        
        MEMap *localMap = [MEMap searchByGID:remoteMap.GID inArray:localMaps];
        
        // Si existe el elemento local y no esta marcado como borrado continua
        if(localMap != nil && localMap.isMarkedAsDeleted == NO) {
            continue;
        }
        
        
        // Nuevo elemento de comparacion
        MapsCompareItem *compItem = [MapsCompareItem itemForLocalMap:localMap remoteMap:remoteMap];
        [result addObject:compItem];
        
        
        // El que se hace dependera de si existio previamente en local y fue borrada
        if(localMap == nil) {
            // Se crea una nueva entidad local desde la remota
            NSLog(@"Sync: Create local entity from remote: %@",remoteMap.name);
            compItem.syncStatus = ST_Sync_Create_Local;
        } else {
            // La entidad local fue borrada
            if([localMap.syncETag isEqualToString:remoteMap.syncETag]) {
                // Puesto que tienen el mismo ETAG se borra la entidad remota
                NSLog(@"Sync: Delete remote as it wasn't modified and local was deleted: %@",remoteMap.name);
                compItem.syncStatus = ST_Sync_Delete_Remote;
            } else {
                // CONFLICTO: Se borró la entidad local y se modifico la remota
                // RESOLUCION: Se regenera la entidad local desde la remota.
                compItem.syncStatus = ST_Sync_Update_Local;
            }
        }
        
    }
    
    
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos locales nuevos a crear en remoto [o borrar en local si fueron borrados]
    for(MEMap *localMap in localMaps) {
        
        // No procesa los elementos locales borrados
        if(localMap.isMarkedAsDeleted) {
            continue;
        }
        
        MEMap *remoteMap = [MEMap searchByGID:localMap.GID inArray:remoteMaps];
        
        // Si la entidad remota existe continua
        if(remoteMap != nil) {
            continue;
        }
        
        
        // Nuevo elemento de comparacion
        MapsCompareItem *compItem = [MapsCompareItem itemForLocalMap:localMap remoteMap:remoteMap];
        [result addObject:compItem];
        
        
        // Que se hace dependera de si se sincronizo previamente o es nueva
        if(localMap.isLocal) {
            // Crea la entidad remota desde la local
            NSLog(@"Sync: Create new remote from local: %@",localMap.name);
            compItem.syncStatus = ST_Sync_Create_Remote;
        }
        else {
            if(localMap.changed) {
                // CONFLICTO: La entidad remota fue borrada pero la local se modificó
                // RESOLUCION: Recrear la entidad remota desde la local de nuevo
                NSLog(@"Sync: Remote entity created again from local because the later was changed: %@",localMap.name);
                compItem.syncStatus = ST_Sync_Create_Remote;
            } else {
                // Borra la entidad local puesto que no fue modificada y la remota ya no existe
                NSLog(@"Sync: Local entity deleted as it wasn't modifies and remote was deleted previously: %@",localMap.name);
                compItem.syncStatus = ST_Sync_Delete_Local;
            }
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------
    // Buscamos elementos locales y remotos que existan en ambos y difieran para ser actualizados [quien dependera de como esten]
    for(MEMap *localMap in localMaps) {
        
        // No procesa los elementos locales borrados
        if(localMap.isMarkedAsDeleted) {
            continue;
        }
        
        MEMap *remoteMap = [MEMap searchByGID:localMap.GID inArray:remoteMaps];
        
        // Solo procesa si ambas entidades existen
        if(remoteMap == nil) {
            continue;
        }
        
        
        // Nuevo elemento de comparacion
        MapsCompareItem *compItem = [MapsCompareItem itemForLocalMap:localMap remoteMap:remoteMap];
        [result addObject:compItem];
        
        
        // Quien termina actualizado depende de la marca de modificado y los ETAGs
        if(localMap.changed == NO) {
            if([localMap.syncETag isEqualToString:remoteMap.syncETag]) {
                // No hay que hacer nada porque los dos son iguales
                NSLog(@"Sync: Nothing to be done as both are equals: %@",localMap.name);
                compItem.syncStatus = ST_Sync_OK;
            } else {
                // Actualizamos la entidad local desde la remota
                NSLog(@"Sync: Local entity has to be updated from remote: %@",localMap.name);
                compItem.syncStatus = ST_Sync_Update_Local;
            }
        }else {
            if([localMap.syncETag isEqualToString:remoteMap.syncETag]) {
                // Actualiza la entidad remota desde la local
                NSLog(@"Sync: Remote entity has to be updated from local: %@",localMap.name);
                compItem.syncStatus = ST_Sync_Update_Remote;
            } else {
                // CONFLICTO: Las dos entidades tienen actualizaciones
                // RESOLUCION: Prevalecen los cambios remotos y la entidad local se actualiza
                compItem.syncStatus = ST_Sync_Update_Local;
            }
        }
    }
    
    
    return result;
}


@end
