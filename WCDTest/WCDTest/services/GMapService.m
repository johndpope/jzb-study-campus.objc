//
//  GMapService.m
//  WCDTest
//
//  Created by jzarzuela on 11/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GMapService.h"
#import "ModelService.h"
#import "GData.h"
#import "JavaStringCat.h"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapService () {
@private
    BOOL _isLoggedIn;
    dispatch_queue_t _GMapServiceQueue;
}

@property (nonatomic,retain) GDataServiceGoogleMaps *service;


+ (NSString *) _extract_TMapID_fromEntry:(GDataEntryMap*) entry;
+ (NSString *) _extract_TPointID_fromEntry:(GDataEntryMapFeature*) entry;
+ (NSString *) _get_KML_fromEntry:(GDataEntryMapFeature*) entry;

+ (void) _fill_TMap:(TMap *)map withFeedMapEntry:(GDataEntryMap*) entry;
+ (void) _fill_TPoint:(TPoint *)point withFeedFeatureEntry:(GDataEntryMapFeature*) entry;

- (void) _readPointsForTMap:(TMap *) map  callback:(TBlock_FetchMapDataFinished)callbackBlock;


@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapService


@synthesize service = _service;



//---------------------------------------------------------------------------------------------------------------------
+ (GMapService *)sharedInstance {
    
	static GMapService *_globalGMapInstance = nil;
    
	static dispatch_once_t _predicate;
	dispatch_once(&_predicate, ^{
        NSLog(@"Creating sharedInstance");
        _globalGMapInstance = [[self alloc] init];
    });
	return _globalGMapInstance;
}

//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        
        self.service = [[GDataServiceGoogleMaps alloc] init];
        [self.service setShouldCacheDatedData:YES];
        [self.service setServiceShouldFollowNextLinks:YES];
        
        _GMapServiceQueue = dispatch_queue_create("GMapServiceQueue", NULL);
        
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [self.service release];
    dispatch_release(_GMapServiceQueue);
    
    [super dealloc];
}



//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password {
    
    NSLog(@"GMapService - loginWithUser");
    _isLoggedIn = true;
    [self.service setUserCredentialsWithUsername:email password:password];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) logout {
    NSLog(@"GMapService - logout");
    _isLoggedIn = false;
    [self.service setUserCredentialsWithUsername:nil password:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isLoggedIn {
    return _isLoggedIn;
}

//---------------------------------------------------------------------------------------------------------------------
// Consigue la lista de mapas de los que el usuario logado es dueño.
// Los mapas estan vacios (sin puntos)
- (ASYNCHRONOUS) fetchUserMapList:(TBlock_FetchUserMapListFinished)callbackBlock {
    
    
    NSLog(@"GMapService - fetchUserMapList");

    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    NSURL *feedURL = [GDataServiceGoogleMaps mapsFeedURLForUserID:kGDataServiceDefaultUser projection:kGDataMapsProjectionOwned];
    
    [self.service fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
        // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
        dispatch_async(_GMapServiceQueue,^(void){
            
            NSLog(@"GMapService - fetchUserMapList - completionHandler");

            // Iteramos por la lista de mapas que se han retornado en el feed
            NSMutableArray *mapList = [[[NSMutableArray alloc] init] autorelease];
            for(GDataEntryMap *mapEntry in [feed entries]) {
                
                // ************************************************************************************
                // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
                NSString *entryName = [[mapEntry title] stringValue];
                if(![entryName hasPrefix:@"@"]) {
                    NSLog(@"Skipping map named: '%@'",entryName);
                    //continue;
                }
                // ************************************************************************************
                
                
                TMap *map = [TMap insertTmpNew];
                [GMapService _fill_TMap:map withFeedMapEntry: mapEntry];
                
                [mapList addObject:map];
            }
            
            // Avisamos al llamante de que ya tenemos la lista con los mapas
            NSArray *maps = [[mapList copy] autorelease];
            dispatch_async(caller_queue, ^(void){
                callbackBlock(maps, error);
            });
            
        });
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
// Consigue la información, puntos y demas, del mapa pasado como parametro.
- (ASYNCHRONOUS) fetchMapData:(TMap *)map callback:(TBlock_FetchMapDataFinished)callbackBlock {
    
    
    NSLog(@"GMapService - fetchMapData (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // NO SE PUEDE PEDIR INFORMACION SOBRE UN MAPA LOCAL
    if (map.isLocal) {
        return;
    }
    
    // Borra info para leerla desde GMap
    [map clearAllData];
    
    // Lee las "map features" del GMap
    [self _readPointsForTMap:map callback:callbackBlock];
    
}


// ---------------------------------------------------------------------------------
// Lee la lista de elementos (DE MOMENTO SE QUEDA SOLO CON LOS PUNTOS) del mapa indicado
- (void) _readPointsForTMap:(TMap *) map  callback:(TBlock_FetchMapDataFinished)callbackBlock {
    
    
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Get a features feed for a specific map
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full", [map.GID replaceStr:@"#" With:@"/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    
    // fetch all features of the selected map
    GDataQueryMaps *query = [GDataQueryMaps mapsQueryWithFeedURL:feedURL];
    [self.service fetchFeedWithQuery:query completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
        // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
        dispatch_async(_GMapServiceQueue,^(void){
            
            NSLog(@"GMapService - _readPointsForTMap - completionHandler (%@-%@)",map.name,map.GID);

            for(GDataEntryMapFeature *featureEntry in [feed entries]) {
                
                // filtrar lo que no sea un punto
                NSString *kml = [GMapService _get_KML_fromEntry:featureEntry];
                if([kml indexOf:@"<Point"]==-1) {
                    continue;
                }

                // Creamos y parseamos la informacion del punto
                TPoint *point = [TPoint insertTmpNewInMap:map];
                [GMapService _fill_TPoint:point withFeedFeatureEntry:featureEntry];
                
                // Si no es extinfo lo añade
                if(point.isExtInfo) {
                    map.extInfo = point;
                }else {
                    [map addPoint:point];
                }
            }
            
            // Añade las categorias
            /************
             try {
             ExtendedInfo.parseMapExtInfo(map);
             } catch (Throwable th) {
             Tracer._error("Error parsin extended info: ", th);
             }
             ************/
            
            
            // Avisamos al llamante de que ya tenemos la lista con los mapas
            dispatch_async(caller_queue, ^(void){
                callbackBlock(map, error);
            });

        });
    }];
   
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _extract_TMapID_fromEntry:(GDataEntryMap*) entry {
    
    // La URL tiene el formato: http://maps.google.com/maps/feeds/features/<<user_id>>/<<map_id>>/full
    
    NSString *str = [[entry featuresFeedURL] absoluteString];
    
    NSUInteger p1 = 10 + [str indexOf:@"/features/"];
    NSUInteger p2 = 1 + [str indexOf:@"/" startIndex:p1];
    NSUInteger p3 = [str indexOf:@"/" startIndex:p2];
    
    NSString *userID = [str subStrFrom:p1 To: p2-1];
    NSString *mapID = [str subStrFrom:p2 To: p3];
    
    return [[[NSString alloc] initWithFormat:@"%@#%@", userID, mapID] autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _extract_TPointID_fromEntry:(GDataEntryMapFeature*) entry {
    
    // La URL tiene el formato:  http://maps.google.com/maps/feeds/features/<<user_id>>/<<map_id>>/full/<<feature_id>>

    NSString *str = [[entry editLink] href];
    
    NSUInteger p1 = 6 + [str indexOf:@"/full/"];
    NSString *featureId = [str substringFromIndex:p1];
    
    return featureId;
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) _fill_TMap:(TMap *)map withFeedMapEntry:(GDataEntryMap*) entry {
    
    map.GID = [GMapService _extract_TMapID_fromEntry:entry];
    map.name = [[entry title] stringValue];
    map.syncETag = [entry ETag];
    map.desc = [[entry summary] stringValue];
    map.ts_created = [[entry publishedDate] date];
    map.ts_updated = [[entry updatedDate] date];
    map.syncStatus = ST_Sync_OK;
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) _fill_TPoint:(TPoint *)point withFeedFeatureEntry:(GDataEntryMapFeature*) entry {
    
    point.GID = [GMapService _extract_TPointID_fromEntry:entry];
    point.name = [[entry title] stringValue];
    point.syncETag = [entry ETag];
    point.desc = [[entry summary] stringValue];
    point.ts_created = [[entry publishedDate] date];
    point.ts_updated = [[entry updatedDate] date];
    point.syncStatus = ST_Sync_OK;
    
    NSString *kml = [GMapService _get_KML_fromEntry:entry];
    [point parseFromKML:kml];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _get_KML_fromEntry:(GDataEntryMapFeature*) entry {
    
    if([[entry KMLValues] count]>0) {
        NSXMLNode* node = [[entry KMLValues] objectAtIndex:0];
        NSString *kml =  [node XMLString];
        return kml;
    } else {
        return @"";
    }

}

@end
