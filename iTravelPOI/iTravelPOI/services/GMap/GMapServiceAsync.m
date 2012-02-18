//
//  GMapServiceAsync.m
//  WCDTest
//
//  Created by jzarzuela on 13/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GMapServiceAsync.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapServiceAsync () 
@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapServiceAsync


dispatch_queue_t _GMapServiceQueue;


//---------------------------------------------------------------------------------------------------------------------
+ (GMapServiceAsync *)sharedInstance {
    
	static GMapServiceAsync *_globalGMapInstance = nil;
    
	static dispatch_once_t _predicate;
	dispatch_once(&_predicate, ^{
        NSLog(@"GMapServiceAsync - Creating sharedInstance");
        _globalGMapInstance = [[self alloc] init];
    });
	return _globalGMapInstance;
}


//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        _GMapServiceQueue = dispatch_queue_create("GMapServiceAsyncQueue", NULL);
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    dispatch_release(_GMapServiceQueue);
    [super dealloc];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password {
    NSLog(@"GMapServiceAsync - loginWithUser");
    [[GMapService sharedInstance] loginWithUser:email password:password];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) logout {
    NSLog(@"GMapServiceAsync - logout");
    [[GMapService sharedInstance] logout];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isLoggedIn {
    return [[GMapService sharedInstance] isLoggedIn];
}


//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) fetchUserMapList:(TBlock_FetchUserMapListFinished)callbackBlock {
    
    NSLog(@"GMapServiceAsync - fetchUserMapList");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_GMapServiceQueue,^(void){
        NSError *error;
        NSArray *maps = [[GMapService sharedInstance] fetchUserMapList:&error];
        
        // Avisamos al llamante de que ya tenemos la lista con los mapas
        dispatch_async(caller_queue, ^(void){
            callbackBlock(maps, error);
        });
    });
}


//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) fetchMapData:(TMap *)map callback:(TBlock_FetchMapDataFinished)callbackBlock {
    
    NSLog(@"GMapServiceAsync - fetchMapData (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_GMapServiceQueue,^(void){
        NSError *error;
        [[GMapService sharedInstance] fetchMapData:map error:&error];
        
        // Avisamos al llamante de que ya tenemos la información del mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(map, error);
        });
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) createNewEmptyGMap:(TMap *)map callback:(TBlock_CreateMapDataFinished)callbackBlock {
    
    NSLog(@"GMapServiceAsync - createNewGMap (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_GMapServiceQueue,^(void){
        NSError *error;
        [[GMapService sharedInstance] createNewEmptyGMap:map error:&error];
        
        // Avisamos al llamante de que ya se ha creado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(map, error);
        });
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) deleteGMap:(TMap *)map callback:(TBlock_DeleteMapDataFinished)callbackBlock {
    
    NSLog(@"GMapServiceAsync - deleteGMap (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_GMapServiceQueue,^(void){
        NSError *error;
        [[GMapService sharedInstance] deleteGMap:map error:&error];
        
        // Avisamos al llamante de que ya se ha borrado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(map, error);
        });
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) updateGMap:(TMap *)map callback:(TBlock_UpdateMapDataFinished)callbackBlock {
    
    NSLog(@"GMapServiceAsync - updateGMap (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_GMapServiceQueue,^(void){
        NSError *error;
        [[GMapService sharedInstance] updateGMap:map error:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(map, error);
        });
    });
}


@end
