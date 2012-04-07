//
//  SyncService.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncService.h"

#import "DelegateMapCompare.h"
#import "DelegateMapMerge.h"
#import "MergeEntityCat.h"

#import "ModelService.h"
#import "GMapService.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface SyncService ()

- (NSMutableArray *) _compareMaps:(NSError **)error;
- (void)             _syncMaps:(NSArray *)compItems error:(NSError **)error;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation SyncService



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
- (SRVC_ASYNCHRONOUS) compareMaps:(TBlock_compareMapsFinished)callbackBlock {
    
    NSLog(@"SyncService - Async - compareMapsInCtx");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(self.serviceQueue, ^(void){
        NSError *error = nil;
        NSMutableArray *compItems = [[SyncService sharedInstance] _compareMaps:&error];
        
        // Avisamos al llamante de que ya tenemos la lista con los mapas
        dispatch_async(caller_queue, ^(void){
            callbackBlock(compItems, error);
        });
    });
    
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) syncMaps:(NSArray *)compItems callback:(TBlock_SyncMapsFinished)callbackBlock {
    
    NSLog(@"SyncService - Async - syncMapsInCtx");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(self.serviceQueue, ^(void){
        NSError *error = nil;
        [[SyncService sharedInstance] _syncMaps:compItems error:&error];
        
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
- (NSMutableArray *) _compareMaps:(NSError **)error {
    
    NSLog(@"SyncService - _compareMapsInCtx");
    
    
    // Consigue la lista de los mapas locales
    NSArray *localMaps = [[ModelService sharedInstance] getUserMapList:error];
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
    DelegateMapCompare *delegate = [[DelegateMapCompare alloc] init];
    [MEComparer compareLocals:localMaps remotes:remoteMaps compDelegate:delegate];
    NSMutableArray *compItems = delegate.compItems;
    [delegate release];
    
    
    // Retorna lo calculado
    return compItems;
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _syncMaps:(NSArray *)compItems error:(NSError **)error {
    
    NSLog(@"SyncService - _syncMapsInCtx");

    // Crea el delegate que procesara las tuplas
    DelegateMapMerge *delegate = [[DelegateMapMerge alloc] init];
    
    // Itera la lista de items comparados que nos han pasado
    for(MECompareTuple *tuple in compItems) {
        [delegate processTuple:tuple];
        // Se deberia dar feedback de lo que se anda haciendo al GUI
        // Hay que comprobar el error en cada iteracion
    }
    
    [delegate release];
    
}


@end
