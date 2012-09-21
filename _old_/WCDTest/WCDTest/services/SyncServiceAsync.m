//
//  SyncServiceAsync.m
//  WCDTest
//
//  Created by jzarzuela on 16/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncServiceAsync.h"
#import "SyncService.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface SyncServiceAsync () {
@private
    dispatch_queue_t _SyncServiceQueue;
}
@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation SyncServiceAsync

//---------------------------------------------------------------------------------------------------------------------
+ (SyncServiceAsync *)sharedInstance {
    
	static SyncServiceAsync *_globalGMapInstance = nil;
    
	static dispatch_once_t _predicate;
	dispatch_once(&_predicate, ^{
        NSLog(@"SyncServiceAsync - Creating sharedInstance");
        _globalGMapInstance = [[self alloc] init];
    });
	return _globalGMapInstance;
}


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
- (void)dealloc
{
    dispatch_release(_SyncServiceQueue);
    [super dealloc];
}


//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) syncLocalMap:(TMap *) localMap withRemote:(TMap *)remoteMap callback:(TBlock_SyncFinished)callbackBlock {
    
    NSLog(@"SyncServiceAsync - syncLocalMap [%@ - %@] witn [%@ - %@]", localMap.name, localMap.GID, remoteMap.name, remoteMap.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_SyncServiceQueue,^(void){
        [[SyncService sharedInstance] syncLocalMap:localMap withRemote:remoteMap];
        
        // Avisamos al llamante de que ya se ha creado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock();
        });
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) syncLocalMaps:(NSArray *)localMaps withRemotes:(NSArray *)remoteMaps callback:(TBlock_SyncFinished)callbackBlock {
    
    NSLog(@"SyncServiceAsync - syncLocalMaps");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_SyncServiceQueue,^(void){
        [[SyncService sharedInstance] syncLocalMaps:localMaps withRemotes:remoteMaps];
        
        // Avisamos al llamante de que ya se ha creado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock();
        });
    });
}

@end
