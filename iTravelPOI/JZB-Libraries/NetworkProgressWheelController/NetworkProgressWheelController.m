//
// NetworkProgressWheelController.m
// iTravelPOI-FRWK
//
// Created by Jose Zarzuela on 29/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "NetworkProgressWheelController.h"
#import "ErrorManagerService.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Service private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark NetworkProgressWheelController Service private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface NetworkProgressWheelController ()


@property (assign, atomic) NSInteger usageCount;


+ (NetworkProgressWheelController *) sharedInstance;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark NetworkProgressWheelController Service implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation NetworkProgressWheelController




// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (void) start {
    
    [NetworkProgressWheelController.sharedInstance start];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) stop {
    
    [NetworkProgressWheelController.sharedInstance stop];
}






// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark private methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NetworkProgressWheelController *) sharedInstance {

    static NetworkProgressWheelController *_globalModelInstance = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
                      DDLogVerbose(@"NetworkProgressWheelController - Creating sharedInstance");
                      _globalModelInstance = [[self alloc] init];
                  });
    return _globalModelInstance;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) start {
    
    // Lo sincroniza con el thread main por si viene de otro hilo
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        // Incrementa el indicador de uso e indica que se muestre un "spinner" en la barra de estado para indicar el acceso a la red
        self.usageCount++;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
    });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) stop {
    
    // Lo sincroniza con el thread main por si viene de otro hilo
    dispatch_sync(dispatch_get_main_queue(), ^{

        // Decrementa el indicador de uso. Si ha llegado a cero para el "spinner".
        self.usageCount--;
        if(self.usageCount<=0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
        // Si es negativo saca una traza de error para avisar de que hay algo raro en la aplicacion
        if(self.usageCount<0) {
            self.usageCount=0;
            DDLogWarn(@"NetworkProgressWheelController usage count went belong zero. You should review the app's code.");
        }
    });
    
}



@end

