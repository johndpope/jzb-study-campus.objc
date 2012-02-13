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
#import "GMapServiceWrapper.h"
#import "PointXmlCat.h"
#import "JavaStringCat.h"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapService () {
@private
    BOOL _isLoggedIn;
}

@property (nonatomic,retain) GMapServiceWrapper *service;
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
        self.service = [[GMapServiceWrapper alloc] init];
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [self.service release];
    [self.loggedUser_ID release];
    
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
- (NSArray *) fetchUserMapList:(NSError **)error {
    
    NSLog(@"GMapService - fetchUserMapList");
    
    // Se pide la lista de mapas del usuario
    GDataFeedBase *feed = [self.service fetchUserMapList:error];
    if(*error) {
        return nil;
    }
    
    // Gets UserID for the logged user that requested the list
    self.loggedUser_ID = [GMapService _extract_Logged_UserID_fromFeed:feed];
    
    // Iteramos por la lista de mapas que se han retornado en el feed
    NSMutableArray *mapList = [[[NSMutableArray alloc] init] autorelease];
    for(GDataEntryMap *mapEntry in [feed entries]) {
        
        // ************************************************************************************
        // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
        NSString *entryName = [[mapEntry title] stringValue];
        if(![entryName hasPrefix:@"@"]) {
            NSLog(@"GMapService - fetchUserMapList - Skipping map named without @ for testing: '%@'",entryName);
            //continue;
        }
        // ************************************************************************************
        
        
        TMap *map = [TMap insertTmpNew];
        [GMapService _fill_TMap:map withFeedMapEntry: mapEntry];
        
        [mapList addObject:map];
    }
    
    // Retornamos el resultado
    return [[mapList copy] autorelease];
}


//---------------------------------------------------------------------------------------------------------------------
// Consigue la información, puntos y demas, del mapa pasado como parametro.
- (TMap *) fetchMapData:(TMap *)map error:(NSError **)error {
    
    NSLog(@"GMapService - fetchMapData (%@-%@)",map.name,map.GID);
    
    // Borra info para leerla desde GMap
    [map clearAllData];
    
    // Lee las "map features" del GMap
    GDataFeedBase *feed = [self.service fetchMapDataWithGID:map.GID error:error];
    if(*error) {
        return nil;
    }
    
    // Itera las features creando los TPoint equivalentes
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
    
    // Retorna el mapa actualizado
    return map;    
}


//---------------------------------------------------------------------------------------------------------------------
// OJO: El ID del mapa, puesto que es nuevo, se debe actualizar de la creación para que se pueda actualizar luego
// Lo mismo pasa con los tiempos de creación y actualización
- (TMap *) createNewGMap:(TMap *)map error:(NSError **)error {
    
    NSLog(@"GMapService - createNewGMap (%@-%@)", map.name, map.GID);
    
    // NO SE PUEDE CREAR UN MAPA QUE NO SEA LOCAL
    if (!map.isLocal) {
        NSLog(@"GMapService - createNewGMap - Maps must be local to be created on server");
        NSDictionary* details = [NSDictionary dictionaryWithObject:@"Maps must be local to be created on server" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"AppDomain" code:100 userInfo:details];
        return nil;
    }
    
    // Si no tenemos el ID del usuario no podemos crear el mapa
    if(self.loggedUser_ID == nil) {
        NSArray * maps=[self fetchUserMapList:error];
        if(!maps) {
            NSLog(@"GMapService - createNewGMap - Maps cannot be created without a User ID");
            NSDictionary* details = [NSDictionary dictionaryWithObject:@"Maps cannot be created without a User ID" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"AppDomain" code:200 userInfo:details];
            return nil;
        }
    }
    
    
    // ************************************************************************************
    // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
    if(![map.name hasPrefix:@"@"]) {
        NSLog(@"GMapService - createNewGMap - Skipping map named without @ for testing: '%@'",map.name);
        NSDictionary* details = [NSDictionary dictionaryWithObject:@"Skipping map named without @ for testing" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"AppDomain" code:200 userInfo:details];
        return nil;
    }
    // ************************************************************************************
    
    
    // Crea un feed entry desde los datos del mapa y lo da de alta en el servidor
    GDataEntryMap *gmapEntry = [GMapService _create_FeedMapEntry_fromTMap: map];
    
    // Añade la nueva entrada en el servidor
    GDataEntryBase *createdEntry = [self.service insertMapEntry:gmapEntry userID:self.loggedUser_ID error:error];
    if(*error) {
        return nil;
    }
    
    // Actualiza el mapa con la informacion que se ha recibido de GMap
    [GMapService _fill_TMap:map withFeedMapEntry:(GDataEntryMap *)createdEntry];
    
    // Retorna el mapa actualizado
    return map;    
}


//---------------------------------------------------------------------------------------------------------------------
- (TMap *) deleteGMap: (TMap *)map error:(NSError **)error {
    
    NSLog(@"GMapService - deleteGMap (%@-%@)",map.name,map.GID);
    
    // NO SE PUEDE BORRAR UN MAPA SI ES LOCAL
    if (!map.isLocal) {
        NSLog(@"GMapService - deleteGMap - Maps cannot be local to be deleted on server");
        NSDictionary* details = [NSDictionary dictionaryWithObject:@"Maps cannot be local to be deleted on server" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"AppDomain" code:300 userInfo:details];
        return nil;
    }
        
    
    // ************************************************************************************
    // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
    if(![map.name hasPrefix:@"@"]) {
        NSLog(@"GMapService - deleteGMap - Skipping map named without @ for testing: '%@'",map.name);
        NSDictionary* details = [NSDictionary dictionaryWithObject:@"Skipping map named without @ for testing" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"AppDomain" code:200 userInfo:details];
        return nil;
    }
    // ************************************************************************************
    
    
    // Crea un feed entry desde los datos del mapa y lo da de alta en el 
    GDataFeedBase * deletedEntry = [self.service deleteMapDataWithGID:map.GID error:error];
    if(*error) {
        return nil;
    }
    
    // Actualiza el mapa con la informacion que se ha recibido de GMap
    //[GMapService _fill_TMap:map withFeedMapEntry:(GDataEntryMap *)deletedEntry];
    //¿¿¿ HAY QUE HACER ALGO AQUI ???
    
    // Retorna el mapa elimindado
    return map;    
}


//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _extract_Logged_UserID_fromFeed:(GDataFeedBase *) feed {
    
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
