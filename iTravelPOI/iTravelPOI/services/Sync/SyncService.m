//
//  SyncService.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncService.h"
#import "TMap.h"
#import "TCategory.h"
#import "TPoint.h"
#import "CollectionMerger.h"
#import "MergeEntityCat.h"
#import "ModelService.h"
#import "GMapService.h"




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface SyncService ()

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation SyncService


//---------------------------------------------------------------------------------------------------------------------
+ (SyncService *)sharedInstance {
    
	static SyncService *_globalModelInstance = nil;
	static dispatch_once_t _predicate;
	dispatch_once(&_predicate, ^{
        NSLog(@"SyncService - Creating sharedInstance");
        _globalModelInstance = [[self alloc] init];
    });
	return _globalModelInstance;
    
}


//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [super dealloc];
}



//---------------------------------------------------------------------------------------------------------------------
- (void) syncLocalMap:(TMap *) localMap withRemote:(TMap *)remoteMap {
    
    NSLog(@"SyncService - syncLocalMap [%@ - %@] witn [%@ - %@]", localMap.name, localMap.GID, remoteMap.name, remoteMap.GID);
    
    // Mezcla primero los puntos de ambos mapas sobre el mapa local
    [CollectionMerger merge:[localMap.points allObjects] remotes:[remoteMap.points allObjects] inLocalMap:localMap];
    
    // A continuación, mezcla las categorias. Pero primero las ordena poniendo primero a quien es subcategoria de otro
    NSArray *localCats = [[ModelService sharedInstance] sortCategoriesCategorized:localMap.categories];
    NSArray *remoteCats = [[ModelService sharedInstance] sortCategoriesCategorized:remoteMap.categories];
    [CollectionMerger merge:localCats remotes:remoteCats inLocalMap:localMap];
    
    // Por ultimo el ExtInfoPoint
    TPoint *leip = localMap.extInfo;
    TPoint *reip = remoteMap.extInfo;
    NSString *xml = leip.desc;
    [leip mergeFrom:reip withConflit:true]; 
    leip.desc = xml;
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) syncLocalMaps:(NSArray *)localMaps withRemotes:(NSArray *)remoteMaps {
    
    NSLog(@"SyncService - syncLocalMaps");
    
    
    // Mecla las diferencias entre las dos listas de mapas
    NSArray *addedMaps = [CollectionMerger merge:localMaps remotes:remoteMaps inLocalMap:nil];
    
    
    // Itera la lista de mapas recien creados
    for(TMap *localMap in addedMaps) {
        NSError *error;
        TMap *remoteMap = [TBaseEntity searchByGID:localMap.GID inArray:remoteMaps];
        [[GMapService sharedInstance] fetchMapData:remoteMap error:&error];
        [self syncLocalMap:localMap withRemote:remoteMap];
    }
    
    
    // Itera la lista de mapas actualizando su estado
    for(TMap *localMap in localMaps) {
        
        NSError *error;
        TMap *remoteMap;
        
        switch (localMap.syncStatus) {
                
                // -----------------------------------------------------
            case ST_Sync_Create_Remote:
                for(TPoint *point in localMap.points) {
                    point.syncStatus = ST_Sync_Create_Remote;
                }
                for(TCategory *cat in localMap.categories) {
                    cat.syncStatus = ST_Sync_Create_Remote;
                }
                [[GMapService sharedInstance] createNewEmptyGMap:localMap error:&error];
                [[GMapService sharedInstance] updateGMap:localMap error:&error];
                break;
                
                // -----------------------------------------------------
            case ST_Sync_Delete_Remote:
                [[GMapService sharedInstance] deleteGMap:localMap error:&error];
                break;
                
                // -----------------------------------------------------
            case ST_Sync_Update_Local:
            case ST_Sync_Update_Remote:
                remoteMap = [TBaseEntity searchByGID:localMap.GID inArray:remoteMaps];
                [[GMapService sharedInstance] fetchMapData:remoteMap error:&error];
                [self syncLocalMap:localMap withRemote:remoteMap];
                [[GMapService sharedInstance] updateGMap:localMap error:&error];
                break;
                
            default:
                break;
        }
    }
    
    // Elimina del modelo local todo lo que este marcado como borrado
    for(TMap *localMap in localMaps) {
        if(localMap.wasDeleted) {
            [localMap deleteFromModel];
        } else {
            [localMap markAsSynchronized];
        }
    }
    
    // Salva el contexto del modelo local para persistir los cambios de la sincronización
    [[ModelService sharedInstance] saveContext];
    
}


@end
