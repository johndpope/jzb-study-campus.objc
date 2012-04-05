//
//  SyncService.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncService.h"

#import "MapsComparer.h"
#import "CollectionMerger.h"
#import "MergeEntityCat.h"

#import "ModelService.h"
#import "GMapService.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface SyncService ()

- (NSMutableArray *) _compareMapsInCtx:(NSManagedObjectContext *)moContext error:(NSError **)error;
- (void)             _syncMapsInCtx:(NSManagedObjectContext *)moContext compItems:(NSArray *)compItems error:(NSError **)error;

- (void) _syncLocalMap:(MEMap *) localMap withRemote:(MEMap *)remoteMap inCtx:(NSManagedObjectContext *)moContext error:(NSError **)error;

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
- (SRVC_ASYNCHRONOUS) compareMapsInCtx:(NSManagedObjectContext *) moContext callback:(TBlock_compareMapsFinished)callbackBlock {
    
    NSLog(@"SyncService - Async - compareMapsInCtx");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_SyncServiceQueue,^(void){
        NSError *error = nil;
        NSMutableArray *compItems = [[SyncService sharedInstance] _compareMapsInCtx:moContext error:&error];
        
        // Avisamos al llamante de que ya tenemos la lista con los mapas
        dispatch_async(caller_queue, ^(void){
            callbackBlock(compItems, error);
        });
    });
    
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) syncMapsInCtx:(NSManagedObjectContext *) moContext compItems:(NSArray *)compItems callback:(TBlock_SyncMapsFinished)callbackBlock {
    
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
        [[SyncService sharedInstance] _syncMapsInCtx:moContext compItems:compItems error:&error];
        
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
- (NSMutableArray *) _compareMapsInCtx:(NSManagedObjectContext *) moContext error:(NSError **)error {
    
    NSLog(@"SyncService - _compareMapsInCtx");
    
    
    // Consigue la lista de los mapas locales
    NSArray *localMaps = [[ModelService sharedInstance] getUserMapList:moContext orderBy:SORT_BY_NAME sortOrder:SORT_ASCENDING error:error];
    if(*error) {
        // Ha habido un error al recuperar los mapas locales
        NSLog(@"error: %@", *error);
        return nil;
    }
    
    // Consigue la lista de los mapas remotos (logandose antes)
    [[GMapService sharedInstance] loginWithUser:@"jzarzuela@gmail.com" password:@"#webweb1971"];
    NSArray *remoteMaps = [[GMapService sharedInstance] fetchUserMapList:error];
    if(*error) {
        // Ha habido un error al recuperar los mapas remotos
        NSLog(@"error: %@", *error);
        return nil;
    }
    
    
    // Mezcla las diferencias entre las dos listas de mapas
    NSArray *compItems = [MapsComparer compareLocals:localMaps remoteMaps:remoteMaps];
    
    // Algoritmo de comparacion para ordenar los elementos segun el nombre
    NSComparator comparator = ^NSComparisonResult(id obj1, id obj2) {
        MapsCompareItem *ce1 = obj1;
        MapsCompareItem *ce2 = obj2;
        NSString *name1 = ce1.localMap ? ce1.localMap.name : ce1.remoteMap.name;
        NSString *name2 = ce2.localMap ? ce2.localMap.name : ce2.remoteMap.name;
        return [name1 compare:name2];
    };
    
    // Las ordena y retorna
    NSArray *sortedCompItems = [compItems sortedArrayUsingComparator:comparator];
    return [NSMutableArray arrayWithArray:sortedCompItems];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _syncMapsInCtx:(NSManagedObjectContext *)moContext compItems:(NSArray *)compItems error:(NSError **)error {
    
    NSLog(@"SyncService - _syncMapsInCtx");
    
    // Se deberia dar feedback de lo que se anda haciendo al GUI
    
    // Itera la lista de items comparados que nos han pasado
    for(MapsCompareItem *compItem in compItems) {
        
        *error = nil;
        
        MEMap *localMap = compItem.localMap;
        MEMap *remoteMap = compItem.remoteMap;
        
        switch (compItem.syncStatus) {
                
                // -----------------------------------------------------
            case ST_Sync_Create_Local:
                localMap = [MEMap insertNew:moContext];
                [localMap mergeFrom:remoteMap withConflit:false];
                [[GMapService sharedInstance] fetchMapData:remoteMap error:error];
                [self _syncLocalMap:localMap withRemote:remoteMap inCtx:moContext error:error];
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
                if(localMap.isDeleted) {
                    [localMap unmarkAsDeleted];
                }
                [localMap mergeFrom:remoteMap withConflit:false];
                [[GMapService sharedInstance] fetchMapData:remoteMap error:error];
                [self _syncLocalMap:localMap withRemote:remoteMap inCtx:moContext error:error];
                [[GMapService sharedInstance] updateGMap:localMap error:error];
                break;
                
            default:
                break;
        }
        
        // Elimina del modelo local todo lo que este marcado como borrado
        if(localMap.isMarkedAsDeleted) {
            [localMap deleteFromModel];
        }
        
        // Graba los cambios en el mapa local
        [compItem.localMap markAsSynchronized];
        [localMap commitChanges];
    }
    
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


@end
