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
#import "PointXmlCat.h"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapService () {
@private
    dispatch_queue_t _GMapServiceQueue;
    BOOL _isLoggedIn;
}

@property (nonatomic,retain) GDataServiceGoogleMaps *service;
@property (nonatomic,retain) NSString *loggedUser_ID;



+ (NSString *)      _extract_Logged_UserID_fromFeed:(GDataFeedBase *) feed;
+ (NSString *)      _extract_TMapID_fromEntry:(GDataEntryMap *) entry;
+ (NSString *)      _extract_TPointID_fromEntry:(GDataEntryMapFeature *) entry;
+ (NSString *)      _get_KML_fromEntry:(GDataEntryMapFeature *) entry;

+ (void)            _fill_TMap:(TMap *)map withFeedMapEntry:(GDataEntryMap *) entry;
+ (GDataEntryMap*)  _create_FeedMapEntry_fromTMap:(TMap *) map;
+ (void)            _fill_TPoint:(TPoint *)point withFeedFeatureEntry:(GDataEntryMapFeature *) entry;


@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapService


@synthesize service = _service;
@synthesize loggedUser_ID = _loggedUser_ID;



//---------------------------------------------------------------------------------------------------------------------
+ (GMapService *)sharedInstance {
    
	static GMapService *_globalGMapInstance = nil;
    
	static dispatch_once_t _predicate;
	dispatch_once(&_predicate, ^{
        NSLog(@"GMapService - Creating sharedInstance");
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
    [self.loggedUser_ID release];
    dispatch_release(_GMapServiceQueue);
    
    [super dealloc];
}



//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password {
    
    NSLog(@"GMapService - loginWithUser");
    _isLoggedIn = true;
    self.loggedUser_ID = nil;
    [self.service setUserCredentialsWithUsername:email password:password];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) logout {
    NSLog(@"GMapService - logout");
    _isLoggedIn = false;
    self.loggedUser_ID = nil;
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
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Se pide la lista de mapas del usuario
    NSURL *feedURL = [GDataServiceGoogleMaps mapsFeedURLForUserID:kGDataServiceDefaultUser projection:kGDataMapsProjectionOwned];
    [self.service fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
        // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
        dispatch_async(_GMapServiceQueue,^(void){
            
            NSLog(@"GMapService - fetchUserMapList - completionHandler");
            
            // Gets UserID for the logged user that requested the list
            self.loggedUser_ID = [GMapService _extract_Logged_UserID_fromFeed:feed];
            
            // Iteramos por la lista de mapas que se han retornado en el feed
            NSMutableArray *mapList = [[[NSMutableArray alloc] init] autorelease];
            for(GDataEntryMap *mapEntry in [feed entries]) {
                
                // ************************************************************************************
                // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
                NSString *entryName = [[mapEntry title] stringValue];
                if(![entryName hasPrefix:@"@"]) {
                    NSLog(@"GMapService - fetchUserMapList - Skipping map named: '%@'",entryName);
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
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Borra info para leerla desde GMap
    [map clearAllData];
    
    // Lee las "map features" del GMap
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full", [map.GID replaceStr:@"#" With:@"/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    GDataQueryMaps *query = [GDataQueryMaps mapsQueryWithFeedURL:feedURL];
    [self.service fetchFeedWithQuery:query completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
        // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
        dispatch_async(_GMapServiceQueue,^(void){
            
            NSLog(@"GMapService - fetchMapData - completionHandler (%@-%@)",map.name,map.GID);
            
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
            
            // Añade la informacion extendida del mapa y las categorias
            [map.extInfo parseExtInfoFromString: map.extInfo.desc];
            
            // Avisamos al llamante de que ya tenemos la lista con los mapas
            dispatch_async(caller_queue, ^(void){
                callbackBlock(map, error);
            });
            
        });
    }];
    
}


//---------------------------------------------------------------------------------------------------------------------
// COMO HACE FALTA EL ID DEL USUARIO LOGADO PARA PODER CREAR MAPAS, ES OBLIGATORIO QUE ANTES DE AÑADIR UN MAPA SE PIDA
// EL LISTADO DE MAPAS DE ESE USARIO PARA CONSEGUIR ESE ID (NO HAY OTRA FORMA)
//
// OJO: El ID del mapa, puesto que es nuevo, se debe actualizar de la creación para que se pueda actualizar luego
// Lo mismo pasa con los tiempos de creación y actualización
- (ASYNCHRONOUS) createNewGMap:(TMap *)map callback:(TBlock_CreateMapDataFinished)callbackBlock {
    
    
    NSLog(@"GMapService - createNewGMap (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // NO SE PUEDE CREAR UN MAPA QUE NO SEA LOCAL
    if (!map.isLocal) {
        return;
    }
    
    // Si no tenemos el ID del usuario no podemos crear el mapa
    if(self.loggedUser_ID == nil) {
        NSLog(@"GMapService - createNewGMap - No se puede crear sin ID de usuario");
        return;
    }
    
    
    // ************************************************************************************
    // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
    if(![map.name hasPrefix:@"@"]) {
        NSLog(@"GMapService - createNewGMap - Skipping map named: '%@'",map.name);
        return;
    }
    // ************************************************************************************
    
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Crea un feed entry desde los datos del mapa y lo da de alta en el servidor
    GDataEntryMap *gmapEntry = [GMapService _create_FeedMapEntry_fromTMap: map];
    
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/maps/%@/full", self.loggedUser_ID] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];
    [self.service fetchEntryByInsertingEntry:gmapEntry forFeedURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *createdEntry, NSError *error) {
        
        // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
        dispatch_async(_GMapServiceQueue,^(void){
            
            NSLog(@"GMapService - createNewGMap - completionHandler (%@-%@)",map.name,map.GID);
            
            // Actualiza el mapa con la informacion que se ha recibido de GMap
            [GMapService _fill_TMap:map withFeedMapEntry:(GDataEntryMap *)createdEntry];
            
            // Avisamos al llamante de que ya tenemos la lista con los mapas
            dispatch_async(caller_queue, ^(void){
                callbackBlock(map, error);
            });
            
        });
    }];
    
}


//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) deleteGMap:(TMap *)map callback:(TBlock_DeleteMapDataFinished)callbackBlock {
    
    
    NSLog(@"GMapService - deleteGMap (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // NO SE PUEDE BORRAR UN MAPA QUE NO SEA LOCAL
    if (!map.isLocal) {
        return;
    }
    
    // Si no tenemos el ID del usuario no podemos crear el mapa
    if(self.loggedUser_ID == nil) {
        NSLog(@"GMapService - createNewGMap - No se puede crear sin ID de usuario");
        return;
    }
    
    
    // ************************************************************************************
    // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
    if(![map.name hasPrefix:@"@"]) {
        NSLog(@"GMapService - deleteGMap - Skipping map named: '%@'",map.name);
        return;
    }
    // ************************************************************************************
    
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Crea un feed entry desde los datos del mapa y lo da de alta en el 
    NSString *urlStr = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/feeds/features/%@/full", [map.GID replaceStr:@"#" With:@"/"]] autorelease];
    NSURL *feedURL = [NSURL URLWithString:urlStr];

    [self.service deleteResourceURL:feedURL ETag:nil completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *deletedEntry, NSError *error) {
        
        // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
        dispatch_async(_GMapServiceQueue,^(void){
            
            NSLog(@"GMapService - deleteGMap - completionHandler (%@-%@)",map.name,map.GID);
            
            NSLog(@"entry %@",deletedEntry);
            
            // Avisamos al llamante de que ya tenemos la lista con los mapas
            dispatch_async(caller_queue, ^(void){
                callbackBlock(map, error);
            });
            
        });
    }];
    
}


//---------------------------------------------------------------------------------------------------------------------
+ (NSString *)      _extract_Logged_UserID_fromFeed:(GDataFeedBase *) feed {
    
    // La URL tiene el formato:  http://maps.google.com/maps/feeds/maps/<<user_id>>/full
    
    NSString *str = [[feed postLink] href];
    
    NSUInteger p1 = [str lastIndexOf:@"/maps/"];
    NSUInteger p2 = [str lastIndexOf:@"/"];
    if(p1 > 0 && p2 > 0) {
        return [str subStrFrom:p1+6 To:p2];
    }
    else {
        return nil;
    }
    
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
    point.kmlBlob = kml;
}

//---------------------------------------------------------------------------------------------------------------------
+ (GDataEntryMap*) _create_FeedMapEntry_fromTMap:(TMap *)map {
    
    GDataEntryMap *newEntry = [GDataEntryMap mapEntryWithTitle:map.name];
    
    // Por algun tipo de problema, la descripcion NO puede ir vacia
    NSString *trimmed = [map.desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(!trimmed || [trimmed length]==0) {
        [newEntry setSummaryWithString:@"Summary"];
    }else {
        [newEntry setSummaryWithString:trimmed];
    }
    
    // Se podria añadir el dueño
    //[newEntry addAuthor:[GDataPerson personWithName:@"name" email:@"name@gmail.com"]];
    
    return newEntry;
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
