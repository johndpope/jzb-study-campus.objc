//
//  SyncService.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncService.h"

#import "CollectionMerger.h"
#import "MergeEntityCat.h"

#import "ModelService.h"
#import "GMapService.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface SyncService ()

- (void) _syncMapsInCtx:(NSManagedObjectContext *)moContext error:(NSError **)error;

- (void) _syncLocalMap:(MEMap *) localMap withRemote:(MEMap *)remoteMap inCtx:(NSManagedObjectContext *)moContext error:(NSError **)error;
- (void) _syncLocalMaps:(NSArray *)localMaps withRemotes:(NSArray *)remoteMaps inCtx:(NSManagedObjectContext *)moContext error:(NSError **)error;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation SyncService



//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        _SyncServiceQueue = dispatch_queue_create("SyncServiceAsyncQueue", NULL);
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    dispatch_release(_SyncServiceQueue);
    [super dealloc];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
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


//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) syncMapsInCtx:(NSManagedObjectContext *)moContext callback:(TBlock_SyncFinished)callbackBlock {
    
    NSLog(@"SyncService - Async - syncMapsInCtx");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_SyncServiceQueue,^(void){
        NSError *error = nil;
        [[SyncService sharedInstance] _syncMapsInCtx:moContext error:&error];
        
        // Avisamos al llamante de que ya tenemos la lista con los mapas
        dispatch_async(caller_queue, ^(void){
            callbackBlock(error);
        });
    });
    
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _syncMapsInCtx:(NSManagedObjectContext *)moContext error:(NSError **)error {

    NSLog(@"SyncService - _syncMapsInCtx");
    
    // Se deberia dar feedback de lo que se anda haciendo al GUI
    
    NSArray *localMaps = [[ModelService sharedInstance] getUserMapList:moContext orderBy:SORT_BY_NAME sortOrder:SORT_ASCENDING error:error];
    if(*error) {
        // Ha habido un error al recuperar los mapas locales
        NSLog(@"error: %@", *error);
        return;
    }
    
    [[GMapService sharedInstance] loginWithUser:@"jzarzuela@gmail.com" password:@"#webweb1971"];
    
    NSArray *remoteMaps = [[GMapService sharedInstance] fetchUserMapList:error];
    if(*error) {
        // Ha habido un error al recuperar los mapas remotos
        NSLog(@"error: %@", *error);
        return;
    }
    
    // No se pasa el &error???
    [self _syncLocalMaps:localMaps withRemotes:remoteMaps inCtx:moContext error:error];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _syncLocalMap:(MEMap *) localMap withRemote:(MEMap *)remoteMap inCtx:(NSManagedObjectContext *)moContext error:(NSError **)error {
    
    NSLog(@"SyncService - _syncLocalMap [%@ - %@] witn [%@ - %@]", localMap.name, localMap.GID, remoteMap.name, remoteMap.GID);
    
    // Mezcla primero los puntos de ambos mapas sobre el mapa local
    NSMutableArray *allLocalPoints = [NSMutableArray arrayWithArray:[localMap.points allObjects]];
    [allLocalPoints addObjectsFromArray:[localMap.deletedPoints allObjects]];
    NSMutableArray *allRemotePoints = [NSMutableArray arrayWithArray:[remoteMap.points allObjects]];
    [allRemotePoints addObjectsFromArray:[remoteMap.deletedPoints allObjects]];
    [CollectionMerger merge:allLocalPoints remotes:allRemotePoints inLocalMap:localMap moContext:moContext];
    
    // A continuación, mezcla las categorias. Pero primero las ordena poniendo primero a quien es subcategoria de otro
    NSMutableArray *allLocalCats = [NSMutableArray arrayWithArray:[MECategory sortCategorized:localMap.categories]];
    [allLocalCats addObjectsFromArray:[localMap.deletedCategories allObjects]];
    NSMutableArray *allRemoteCats = [NSMutableArray arrayWithArray:[MECategory sortCategorized:remoteMap.categories]]; 
    [allRemoteCats addObjectsFromArray:[remoteMap.deletedCategories allObjects]];
    [CollectionMerger merge:allLocalCats remotes:allRemoteCats inLocalMap:localMap moContext:moContext];
    
    // Por ultimo el ExtInfoPoint
    MEPoint *leip = localMap.extInfo;
    MEPoint *reip = remoteMap.extInfo;
    NSString *xml = leip.desc;
    [leip mergeFrom:reip withConflit:true]; 
    leip.desc = xml;
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _syncLocalMaps:(NSArray *)localMaps withRemotes:(NSArray *)remoteMaps inCtx:(NSManagedObjectContext *)moContext error:(NSError **)error {
    
    NSLog(@"SyncService - _syncLocalMaps");
    
    
    // Mecla las diferencias entre las dos listas de mapas
    NSArray *addedMaps = [CollectionMerger merge:localMaps remotes:remoteMaps inLocalMap:nil moContext:moContext];
    
    
    // Añade a  la lista de mapas locales recien creados (vacios) para copiarles la información del mapa remoto origen
    NSMutableArray *allMaps = [NSMutableArray arrayWithArray:localMaps];
    [allMaps addObjectsFromArray:addedMaps];
    localMaps = allMaps;
    
    
    // Itera la lista de mapas actualizando su estado
    for(MEMap *localMap in localMaps) {
        
        MEMap *remoteMap;
        
        switch (localMap.syncStatus) {
                
                // -----------------------------------------------------
            case ST_Sync_Create_Local:
                remoteMap = [MEBaseEntity searchByGID:localMap.GID inArray:remoteMaps];
                [[GMapService sharedInstance] fetchMapData:remoteMap error:error];
                [self _syncLocalMap:localMap withRemote:remoteMap inCtx:moContext error:error];
                [localMap commitChanges];
                break;
                
                // -----------------------------------------------------
            case ST_Sync_Create_Remote:
                for(MEPoint *point in localMap.points) {
                    point.syncStatus = ST_Sync_Create_Remote;
                }
                for(MECategory *cat in localMap.categories) {
                    cat.syncStatus = ST_Sync_Create_Remote;
                }
                [[GMapService sharedInstance] createNewEmptyGMap:localMap error:error];
                [[GMapService sharedInstance] updateGMap:localMap error:error];
                break;
                
                // -----------------------------------------------------
            case ST_Sync_Delete_Remote:
                [[GMapService sharedInstance] deleteGMap:localMap error:error];
                break;
                
                // -----------------------------------------------------
            case ST_Sync_Update_Local:
            case ST_Sync_Update_Remote:
                remoteMap = [MEBaseEntity searchByGID:localMap.GID inArray:remoteMaps];
                [[GMapService sharedInstance] fetchMapData:remoteMap error:error];
                [self _syncLocalMap:localMap withRemote:remoteMap inCtx:moContext error:error];
                [[GMapService sharedInstance] updateGMap:localMap error:error];
                [localMap commitChanges];
                break;
                
            default:
                break;
        }
    }
    
    // Elimina del modelo local todo lo que este marcado como borrado
    for(MEMap *localMap in localMaps) {
        if(localMap.isMarkedAsDeleted) {
            [localMap deleteFromModel];
        } else {
            [localMap markAsSynchronized];
        }
        [localMap commitChanges];
    }
    
}


@end
