//
//  GMapServiceWrapper.m
//  WCDTest
//
//  Created by jzarzuela on 13/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GMapServiceWrapper.h"
#import "JavaStringCat.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapServiceWrapper () 

@property (nonatomic,retain) GDataServiceGoogleMaps *service;

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapServiceWrapper

@synthesize service = _service;


//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        self.service = [[GDataServiceGoogleMaps alloc] init];
        [self.service setShouldCacheDatedData:YES];
        [self.service setServiceShouldFollowNextLinks:YES];
        [GDataHTTPFetcher setDefaultRunLoopModes:[[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, nil] autorelease]];
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [self.service release];
    
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setUserCredentialsWithUsername:(NSString *)email password:(NSString *)password {
    [self.service setUserCredentialsWithUsername:email password:password];
}


//---------------------------------------------------------------------------------------------------------------------
- (GDataFeedBase *) fetchUserMapList:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona
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
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    } while(!endLoop);
    
    
    *err = [ticket fetchError];
    return (GDataFeedBase *)[ticket fetchedObject];
}


//---------------------------------------------------------------------------------------------------------------------
- (GDataFeedBase *) fetchMapDataWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full", [mapGID replaceStr:@"#" With:@"/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataQueryMaps *query = [GDataQueryMaps mapsQueryWithFeedURL:feedURL];
    GDataServiceTicket *ticket = [self.service fetchFeedWithQuery:query completionHandler:^(GDataServiceTicket *_ticket, GDataFeedBase *_feed, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataFeedBase *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMap *) inserMEMapEntry:(GDataEntryMap *)gmapEntry userID:(NSString *)loggedID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/maps/%@/full", loggedID] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataServiceTicket *ticket = [self.service fetchEntryByInsertingEntry:gmapEntry forFeedURL:feedURL completionHandler:^(GDataServiceTicket *_ticket, GDataEntryBase *_entry, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMap *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMap *)  deleteMapDataWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/maps/%@", [mapGID replaceStr:@"#" With:@"/full/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataServiceTicket *ticket = [self.service deleteResourceURL:feedURL ETag:nil completionHandler:^(GDataServiceTicket *_ticket, id _object, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMap *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMap *) fetchUpdatedMapDataWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/maps/%@", [mapGID replaceStr:@"#" With:@"/full/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataServiceTicket *ticket = [self.service fetchEntryWithURL:feedURL completionHandler:^(GDataServiceTicket *_ticket, GDataEntryBase *_entry, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMap *)[ticket fetchedObject];
}




//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMapFeature *) inserMEMapFeatureEntry:(GDataEntryMapFeature *)featureEntry  inMapWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full", [mapGID replaceStr:@"#" With:@"/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataServiceTicket *ticket = [self.service fetchEntryByInsertingEntry:featureEntry forFeedURL:feedURL completionHandler:^(GDataServiceTicket *_ticket, GDataEntryBase *_entry, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMapFeature *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMapFeature *) deleteMapFeatureEntryWithGID:(NSString *)featureGID  inMapWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full/%@", [mapGID replaceStr:@"#" With:@"/"], featureGID] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataServiceTicket *ticket = [self.service deleteResourceURL:feedURL ETag:nil completionHandler:^(GDataServiceTicket *_ticket, id _object, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMapFeature *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMapFeature *) updateMapFeatureEntry:(GDataEntryMapFeature *)featureEntry  withGID:(NSString *)featureGID inMapWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full/%@", [mapGID replaceStr:@"#" With:@"/"], featureGID] autorelease];
    GDataLink * glink = [GDataLink linkWithRel:@"edit" type:nil href:urlStr];
    [featureEntry addObject:glink forExtensionClass:[GDataLink class]];
    GDataServiceTicket *ticket = [self.service fetchEntryByUpdatingEntry:featureEntry completionHandler:^(GDataServiceTicket *_ticket, GDataEntryBase *_entry, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMapFeature *)[ticket fetchedObject];
}


@end
