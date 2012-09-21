//
//  GMapSyncWrapper.m
//  iTravelPOI
//
//  Created by JZarzuela on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GMapSyncWrapper.h"
#import "JavaStringCat.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
//---------------------------------------------------------------------------------------------------------------------
#define LOOP_WAIT_TIMEOUT 0.1


//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncWrapper PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapSyncWrapper () 


@property (nonatomic,retain) GDataServiceGoogleMaps *service;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncWrapper implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapSyncWrapper


@synthesize service = _service;


//*********************************************************************************************************************
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
        [GDataHTTPFetcher setDefaultRunLoopModes:[[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, nil] autorelease]];
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    [self.service release];
    
    [super dealloc];
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark GMapSyncWrapper CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) extract_Logged_UserID_fromFeed:(GDataFeedBase *) feed {
    
    // La URL tiene el formato:  http://maps.google.com/maps/feeds/maps/<<user_id>>/full
    
    NSString *str = [[feed postLink] href];
    
    NSUInteger p1 = [str lastIndexOf:@"/maps/"];
    NSUInteger p2 = [str lastIndexOf:@"/"];
    if(p1 > 0 && p2 > 0) {
        return [str subStrFrom:p1+6 to:p2];
    }
    else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) extract_MapID_fromEntry:(GDataEntryMap *) entry {
    
    // La URL tiene el formato: http://maps.google.com/maps/feeds/features/<<user_id>>/<<map_id>>/full
    
    NSString *str = [[entry featuresFeedURL] absoluteString];
    
    NSUInteger p1 = 10 + [str indexOf:@"/features/"];
    NSUInteger p2 = 1 + [str indexOf:@"/" startIndex:p1];
    NSUInteger p3 = [str indexOf:@"/" startIndex:p2];
    
    NSString *userID = [str subStrFrom:p1 to: p2-1];
    NSString *mapID = [str subStrFrom:p2 to: p3];
    
    return [[[NSString alloc] initWithFormat:@"%@#%@", userID, mapID] autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) extract_PointID_fromEntry:(GDataEntryMapFeature *) entry {
    
    // La URL tiene el formato:  http://maps.google.com/maps/feeds/features/<<user_id>>/<<map_id>>/full/<<feature_id>>
    
    NSString *str = [[entry editLink] href];
    
    NSUInteger p1 = 6 + [str indexOf:@"/full/"];
    NSString *featureId = [str substringFromIndex:p1];
    
    return featureId;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) get_KML_fromEntry:(GDataEntryMapFeature *) entry {
    
    if([[entry KMLValues] count]>0) {
        NSXMLNode* node = [[entry KMLValues] objectAtIndex:0];
        NSString *kml =  [node XMLString];
        return kml;
    } else {
        return @"";
    }
    
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void)  setUserCredentialsWithUsername:(NSString *)email password:(NSString *)password {
    [self.service setUserCredentialsWithUsername:email password:password];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataFeedBase *)  fetchUserMapList:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
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

//---------------------------------------------------------------------------------------------------------------------
- (GDataFeedBase *)  fetchMapDataWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona estableciendo una variable para avisar de la finalizacion
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full", [mapGID replaceStr:@"#" with:@"/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataQueryMaps *query = [GDataQueryMaps mapsQueryWithFeedURL:feedURL];
    GDataServiceTicket *ticket = [self.service fetchFeedWithQuery:query completionHandler:^(GDataServiceTicket *_ticket, GDataFeedBase *_feed, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:LOOP_WAIT_TIMEOUT]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataFeedBase *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMap *)  inserMapEntry:(GDataEntryMap *)gmapEntry userID:(NSString *)loggedID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona estableciendo una variable para avisar de la finalizacion
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/maps/%@/full", loggedID] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataServiceTicket *ticket = [self.service fetchEntryByInsertingEntry:gmapEntry forFeedURL:feedURL completionHandler:^(GDataServiceTicket *_ticket, GDataEntryBase *_entry, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:LOOP_WAIT_TIMEOUT]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMap *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMap *)  deleteMapWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona estableciendo una variable para avisar de la finalizacion
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/maps/%@", [mapGID replaceStr:@"#" with:@"/full/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataServiceTicket *ticket = [self.service deleteResourceURL:feedURL ETag:nil completionHandler:^(GDataServiceTicket *_ticket, id _object, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:LOOP_WAIT_TIMEOUT]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMap *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMap *)  fetchUpdatedMapDataWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona estableciendo una variable para avisar de la finalizacion
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/maps/%@", [mapGID replaceStr:@"#" with:@"/full/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataServiceTicket *ticket = [self.service fetchEntryWithURL:feedURL completionHandler:^(GDataServiceTicket *_ticket, GDataEntryBase *_entry, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:LOOP_WAIT_TIMEOUT]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMap *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMapFeature *) inserMapFeatureEntry:(GDataEntryMapFeature *)featureEntry  inMapWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona estableciendo una variable para avisar de la finalizacion
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full", [mapGID replaceStr:@"#" with:@"/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataServiceTicket *ticket = [self.service fetchEntryByInsertingEntry:featureEntry forFeedURL:feedURL completionHandler:^(GDataServiceTicket *_ticket, GDataEntryBase *_entry, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:LOOP_WAIT_TIMEOUT]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMapFeature *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMapFeature *) deleteMapFeatureEntryWithGID:(NSString *)featureGID  inMapWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona estableciendo una variable para avisar de la finalizacion
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full/%@", [mapGID replaceStr:@"#" with:@"/"], featureGID] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataServiceTicket *ticket = [self.service deleteResourceURL:feedURL ETag:nil completionHandler:^(GDataServiceTicket *_ticket, id _object, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:LOOP_WAIT_TIMEOUT]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMapFeature *)[ticket fetchedObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (GDataEntryMapFeature *) updateMapFeatureEntry:(GDataEntryMapFeature *)featureEntry  withGID:(NSString *)featureGID inMapWithGID:(NSString *)mapGID error:(NSError **)err {
    
    // Variable de salida del block
    __block BOOL endLoop = false;
    
    // Hace la llamada asincrona estableciendo una variable para avisar de la finalizacion
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full/%@", [mapGID replaceStr:@"#" with:@"/"], featureGID] autorelease];
    GDataLink * glink = [GDataLink linkWithRel:@"edit" type:nil href:urlStr];
    [featureEntry addObject:glink forExtensionClass:[GDataLink class]];
    GDataServiceTicket *ticket = [self.service fetchEntryByUpdatingEntry:featureEntry completionHandler:^(GDataServiceTicket *_ticket, GDataEntryBase *_entry, NSError *_error) {
        endLoop = true;
    }];
    
    //¿¿¿HAY QUE PONER UN TIMEOUT???
    // Bloqueamos el Thread actual iterando en el NSRunLoop hasta que se complete la peticion
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:LOOP_WAIT_TIMEOUT]];
    } while(!endLoop);
    
    *err = [ticket fetchError];
    return (GDataEntryMapFeature *)[ticket fetchedObject];
}

@end
