//
//  GMapSync.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 19/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "GMapSync.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Definitions and Constants
//---------------------------------------------------------------------------------------------------------------------
#define LOOP_WAIT_TIMEOUT 0.1




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private GMapSync definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapSync()

@property (nonatomic,strong) GDataServiceGoogleMaps *service;


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapSync implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapSync



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        self.service = [[GDataServiceGoogleMaps alloc] init];
        [self.service setShouldCacheDatedData:YES];
        [self.service setServiceShouldFollowNextLinks:YES];
        [GDataHTTPFetcher setDefaultRunLoopModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, nil]];
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public CLASS methods
//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password {
    
    NSLog(@"GMapService - loginWithUser");
    //    _isLoggedIn = true;
    //self.loggedUser_ID = nil;
    [self.service setUserCredentialsWithUsername:nil password:nil];
    [self.service setUserCredentialsWithUsername:email password:password];
}


//---------------------------------------------------------------------------------------------------------------------
- (GDataFeedBase *)  fetchUserMapList:(NSError * __autoreleasing *)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // De momento no hay error
    *err = nil;
    
    // Hace la llamada asincrona estableciendo una variable para avisar de la finalizacion
    NSURL *feedURL = [GDataServiceGoogleMaps mapsFeedURLForUserID:kGDataServiceDefaultUser projection:kGDataMapsProjectionOwned];
    GDataServiceTicket *ticket = [self.service fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *_ticket, GDataFeedBase *_feed, NSError *_error) {
        endLoop = true;
    }];
    
    
    /**
     [[ticket currentFetcher] setReceivedDataBlock:^(NSData *info) {
     // un aviso de progreso
     NSLog(@"aqui estamos...");
     }];
     **/
    
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:LOOP_WAIT_TIMEOUT]];
    } while(!endLoop);
    
    
    *err = [ticket fetchError];
    return (GDataFeedBase *)[ticket fetchedObject];
}


@end
