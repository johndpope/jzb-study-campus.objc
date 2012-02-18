//
//  ModelServiceAsync.m
//  WCDTest
//
//  Created by jzarzuela on 13/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelServiceAsync.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface ModelServiceAsync () 

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation ModelServiceAsync


dispatch_queue_t _ModelServiceQueue;


//---------------------------------------------------------------------------------------------------------------------
+ (ModelServiceAsync *)sharedInstance {
    
	static ModelServiceAsync *_globalGMapInstance = nil;
    
	static dispatch_once_t _predicate;
	dispatch_once(&_predicate, ^{
        NSLog(@"ModelServiceAsync - Creating sharedInstance");
        _globalGMapInstance = [[self alloc] init];
    });
	return _globalGMapInstance;
}


//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        _ModelServiceQueue = dispatch_queue_create("ModelServiceAsyncQueue", NULL);
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    dispatch_release(_ModelServiceQueue);
    [super dealloc];
}


//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) getUserMapList:(TBlock_getUserMapListFinished)callbackBlock {
    
    NSLog(@"ModelServiceAsync - getUserMapList");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_ModelServiceQueue,^(void){
        NSError *error;
        NSArray * maps = [[ModelService sharedInstance] getUserMapList:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(maps, error);
        });
    });
}


@end
