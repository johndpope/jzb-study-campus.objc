//
//  GMapService.m
//  WCDTest
//
//  Created by jzarzuela on 11/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GMapService.h"
#import "GMapSyncWrapper.h"
#import "PointXmlCat.h"
#import "JavaStringCat.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapService PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapService ()


@property (nonatomic,retain)  GMapSyncWrapper *service;
@property (nonatomic,retain)  NSString        *loggedUser_ID;
@property (nonatomic, assign) BOOL             isLoggedIn;



// Metodos privados de apoyo
+ (void)                  __fill_MEMap:(MEMap *)map withFeedMapEntry:(GDataEntryMap *) entry;
+ (GDataEntryMap*)        __create_FeedMapEntry_fromMEMap:(MEMap *) map;
+ (void)                  __fill_MEPoint:(MEPoint *)point withFeedFeatureEntry:(GDataEntryMapFeature *) entry;
+ (GDataEntryMapFeature*) __create_FeedFeatureEntry_fromMEPoint:(MEPoint *)point;



- (BOOL) __processPoint:(MEPoint *) point inMap:(MEMap *) map;


@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation GMapService


@synthesize service = _service;
@synthesize loggedUser_ID = _loggedUser_ID;
@synthesize isLoggedIn = _isLoggedIn;



//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        _GMapServiceQueue = dispatch_queue_create("GMapServiceAsyncQueue", NULL);
        self.service = [[GMapSyncWrapper alloc] init];
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



//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
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


//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password {
    
    NSLog(@"GMapService - loginWithUser");
    _isLoggedIn = true;
    self.loggedUser_ID = nil;
    [self.service setUserCredentialsWithUsername:nil password:nil];
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
- (SRVC_ASYNCHRONOUS) asyncFetchUserMapList:(TBlock_FetchUserMapListFinished)callbackBlock {
    
    NSLog(@"GMapService - Async - fetchUserMapList");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_GMapServiceQueue,^(void){
        NSError *error = nil;
        NSArray *maps = [[GMapService sharedInstance] fetchUserMapList:&error];
        
        // Avisamos al llamante de que ya tenemos la lista con los mapas
        dispatch_async(caller_queue, ^(void){
            callbackBlock(maps, error);
        });
    });
}



//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) asyncFetchMapData:(MEMap *)map callback:(TBlock_FetchMapDataFinished)callbackBlock {
    
    NSLog(@"GMapService - Async - fetchMapData (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_GMapServiceQueue,^(void){
        NSError *error = nil;
        [[GMapService sharedInstance] fetchMapData:map error:&error];
        
        // Avisamos al llamante de que ya tenemos la información del mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(map, error);
        });
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) asyncCreateNewEmptyGMap:(MEMap *)map callback:(TBlock_CreateMapDataFinished)callbackBlock {
    
    NSLog(@"GMapService - Async - createNewGMap (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_GMapServiceQueue,^(void){
        NSError *error = nil;
        [[GMapService sharedInstance] createNewEmptyGMap:map error:&error];
        
        // Avisamos al llamante de que ya se ha creado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(map, error);
        });
    });
}    

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) asyncDeleteGMap:(MEMap *)map callback:(TBlock_DeleteMapDataFinished)callbackBlock {
    
    NSLog(@"GMapService - Async - deleteGMap (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_GMapServiceQueue,^(void){
        NSError *error = nil;
        [[GMapService sharedInstance] deleteGMap:map error:&error];
        
        // Avisamos al llamante de que ya se ha borrado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(map, error);
        });
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) asyncUpdateGMap:(MEMap *)map callback:(TBlock_UpdateMapDataFinished)callbackBlock {
    
    NSLog(@"GMapService - Async - updateGMap (%@-%@)",map.name,map.GID);
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_GMapServiceQueue,^(void){
        NSError *error = nil;
        [[GMapService sharedInstance] updateGMap:map error:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(map, error);
        });
    });
}

//---------------------------------------------------------------------------------------------------------------------
// Consigue la lista de mapas de los que el usuario logado es dueño.
// Los mapas estan vacios (sin puntos)
- (NSArray *) fetchUserMapList:(NSError **)error {
    
    NSLog(@"GMapService - fetchUserMapList");
    
    // Se pide la lista de mapas del usuario
    GDataFeedBase *feed = [self.service fetchUserMapList:error];
    if(*error) {
        NSLog(@"GMapService - fetchUserMapList - error: %@ / %@", *error, [*error userInfo]);
        return nil;
    }
    
    // Gets UserID for the logged user that requested the list
    self.loggedUser_ID = [GMapSyncWrapper extract_Logged_UserID_fromFeed:feed];
    
    // Iteramos por la lista de mapas que se han retornado en el feed
    NSMutableArray *mapList = [[[NSMutableArray alloc] init] autorelease];
    for(GDataEntryMap *mapEntry in [feed entries]) {
        
        // ************************************************************************************
        // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
        NSString *entryName = [[mapEntry title] stringValue];
        if(![entryName hasPrefix:@"@"]) {
            NSLog(@"GMapService - fetchUserMapList - Skipping map named without @ for testing: '%@'",entryName);
            continue;
        }
        // ************************************************************************************
        
        
        MEMap *map = [MEMap insertTmpNew];
        [GMapService __fill_MEMap:map withFeedMapEntry: mapEntry];
        
        [mapList addObject:map];
    }
    
    // Retornamos el resultado
    NSLog(@"GMapService - fetchUserMapList - exit");
    return [[mapList copy] autorelease];
}


//---------------------------------------------------------------------------------------------------------------------
// Consigue la información, puntos y demas, del mapa pasado como parametro.
- (MEMap *) fetchMapData:(MEMap *)map error:(NSError **)error {
    
    NSLog(@"GMapService - fetchMapData (%@-%@)",map.name,map.GID);
    
    // Borra info para leerla desde GMap
    [map removeAllPointsAndCategories];
    
    
    // Lee las "map features" del GMap
    GDataFeedBase *feed = [self.service fetchMapDataWithGID:map.GID error:error];
    if(*error) {
        NSLog(@"GMapService - fetchMapData - error: %@ / %@", *error, [*error userInfo]);
        return nil;
    }
    
    // Itera las features creando los MEPoint equivalentes
    for(GDataEntryMapFeature *featureEntry in [feed entries]) {
        
        // filtrar lo que no sea un punto
        NSString *kml = [GMapSyncWrapper get_KML_fromEntry:featureEntry];
        if([kml indexOf:@"<Point"]==-1) {
            continue;
        }
        
        // Creamos y parseamos la informacion del punto
        MEPoint *point;
        if([MEPoint isExtInfoName:[[featureEntry title] stringValue]]){
            point = [MEPoint insertTmpEmptyExtInfoInMap:map];
        }else {
            point = [MEPoint insertTmpNewInMap:map];
        }
        [GMapService __fill_MEPoint:point withFeedFeatureEntry:featureEntry];
    }
    
    // Añade la informacion extendida del mapa y las categorias
    [map.extInfo parseExtInfoFromString: map.extInfo.desc];
    
    // Retorna el mapa actualizado
    NSLog(@"GMapService - fetchMapData - exit");
    return map;    
}


//---------------------------------------------------------------------------------------------------------------------
// OJO: El ID del mapa, puesto que es nuevo, se debe actualizar de la creación para que se pueda actualizar luego
// Lo mismo pasa con los tiempos de creación y actualización
- (MEMap *) createNewEmptyGMap:(MEMap *)map error:(NSError **)error {
    
    NSLog(@"GMapService - _createNewGMap (%@-%@)", map.name, map.GID);
    
    // NO SE PUEDE CREAR UN MAPA QUE NO SEA LOCAL
    if (!map.isLocal) {
        NSLog(@"GMapService - _createNewGMap - Maps must be local to be created on server");
        NSDictionary* details = [NSDictionary dictionaryWithObject:@"Maps must be local to be created on server" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"AppDomain" code:100 userInfo:details];
        return nil;
    }
    
    // Si no tenemos el ID del usuario no podemos crear el mapa
    if(self.loggedUser_ID == nil) {
        NSArray * maps=[self fetchUserMapList:error];
        if(!maps) {
            NSLog(@"GMapService - _createNewGMap - Maps cannot be created without a User ID");
            NSDictionary* details = [NSDictionary dictionaryWithObject:@"Maps cannot be created without a User ID" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"AppDomain" code:200 userInfo:details];
            return nil;
        }
    }
    
    
    // ************************************************************************************
    // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
    if(![map.name hasPrefix:@"@"]) {
        NSLog(@"GMapService - _createNewGMap - Skipping map named without @ for testing: '%@'",map.name);
        NSDictionary* details = [NSDictionary dictionaryWithObject:@"Skipping map named without @ for testing" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"AppDomain" code:200 userInfo:details];
        return nil;
    }
    // ************************************************************************************
    
    
    // Crea un feed entry desde los datos del mapa y lo da de alta en el servidor
    GDataEntryMap *gmapEntry = [GMapService __create_FeedMapEntry_fromMEMap: map];
    
    // Añade la nueva entrada en el servidor
    GDataEntryMap *createdEntry = [self.service inserMapEntry:gmapEntry userID:self.loggedUser_ID error:error];
    if(*error) {
        NSLog(@"GMapService - _createNewGMap - error: %@ / %@", *error, [*error userInfo]);
        return nil;
    }
    
    // Actualiza el mapa con la informacion que se ha recibido de GMap
    [GMapService __fill_MEMap:map withFeedMapEntry:createdEntry];
    
    // Retorna el mapa actualizado
    NSLog(@"GMapService - _createNewGMap - exit");
    return map;    
}


//---------------------------------------------------------------------------------------------------------------------
- (MEMap *) deleteGMap: (MEMap *)map error:(NSError **)error {
    
    NSLog(@"GMapService - deleteGMap (%@-%@)",map.name,map.GID);
    
    // NO SE PUEDE BORRAR UN MAPA SI ES LOCAL
    if (map.isLocal) {
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
    //GDataFeedBase * deletedEntry = 
    [self.service deleteMapWithGID:map.GID error:error];
    if(*error) {
        NSLog(@"GMapService - deleteGMap - error: %@ / %@", *error, [*error userInfo]);
        return nil;
    }
    
    // Actualiza el mapa con la informacion que se ha recibido de GMap
    //[GMapService __fill_MEMap:map withFeedMapEntry:(GDataEntryMap *)deletedEntry];
    //¿¿¿ HAY QUE HACER ALGO AQUI ???
    
    // Retorna el mapa elimindado
    NSLog(@"GMapService - deleteGMap - exit");
    [map markAsDeleted];
    return map;    
}


//---------------------------------------------------------------------------------------------------------------------
- (MEMap *) updateGMap: (MEMap *)map error:(NSError **)error {
    
    NSLog(@"GMapService - updateGMap (%@-%@)",map.name,map.GID);
    
    // NO SE PUEDE ACTUALIZAR UN MAPA SI ES LOCAL
    if (map.isLocal) {
        NSLog(@"GMapService - updateGMap - Maps cannot be local to be deleted on server");
        NSDictionary* details = [NSDictionary dictionaryWithObject:@"Maps cannot be local to be deleted on server" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"AppDomain" code:300 userInfo:details];
        return nil;
    }
    
    
    // ************************************************************************************
    // MIENTRAS ESTEMOS EN PRUEBAS!!!!!!!
    if(![map.name hasPrefix:@"@"]) {
        NSLog(@"GMapService - updateGMap - Skipping map named without @ for testing: '%@'",map.name);
        NSDictionary* details = [NSDictionary dictionaryWithObject:@"Skipping map named without @ for testing" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"AppDomain" code:200 userInfo:details];
        return nil;
    }
    // ************************************************************************************
    
    
    
    // -----------------------------------------------------------------------------------
    // Primero todas las categorias
    for(MECategory *cat in map.categories) {
        NSLog(@"  ---> Sync Category: %@ - %@",cat.name, SyncStatusType_Names[cat.syncStatus]);
        switch (cat.syncStatus) {
                
            case ST_Sync_Create_Remote:
            case ST_Sync_Update_Remote:
                [cat updateToRemoteETag];
                break;
                
            case ST_Sync_Delete_Remote:
                [cat markAsDeleted];
                break;
                
            default:
                // No se hace nada con el resto de estados
                break;
        }
    }
    
    
    // -----------------------------------------------------------------------------------
    // Luego todos los puntos
    BOOL allOK = true;
    for(MEPoint *point in map.points) {
        allOK &= [self __processPoint:point inMap: map];
    }
    
    
    // -----------------------------------------------------------------------------------
    // Actualiza el punto de informacion extendida y lo graba
    [map.extInfo updateExtInfoFromMap];
    if (map.extInfo.isLocal) {
        map.extInfo.syncStatus = ST_Sync_Create_Remote;
        allOK &= [self __processPoint:map.extInfo inMap: map];
    } else {
        map.extInfo.syncStatus = ST_Sync_Update_Remote;
        allOK &= [self __processPoint:map.extInfo inMap: map];
    }
    
    
    // -----------------------------------------------------------------------------------
    // Solo si actualizo bien todos los puntos actualiza el ETAG mapa.
    // En otro caso lo deja el ETag antiguo para forzar una resincronizacion la proxima vez
    if (allOK) {
        GDataEntryBase *updatedEntry = [self.service fetchUpdatedMapDataWithGID:map.GID error:error];
        if(*error) {
            NSLog(@"GMapService - updateGMap - error: %@ / %@", *error, [*error userInfo]);
            return nil;
        } else {
            // Actualiza ETAG y UpdateTime del mapa
            [GMapService __fill_MEMap:map withFeedMapEntry:(GDataEntryMap *)updatedEntry];
        }
    }
    
    // Retorna el mapa actualizado
    NSLog(@"GMapService - updateGMap - exit");
    return map;    
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) __processPoint:(MEPoint *) point inMap:(MEMap *) map {
    
    GDataEntryMapFeature *featureEntryOrig;
    GDataEntryMapFeature *featureEntryUptd;
    NSError *error;
    
    NSLog(@"  ---> Sync Point: %@ - %@", SyncStatusType_Names[point.syncStatus], point.name);
    featureEntryOrig = [GMapService __create_FeedFeatureEntry_fromMEPoint:point];
    if(!featureEntryOrig) {
        return false;
    }
    
    switch (point.syncStatus) {
            
        case ST_Sync_Create_Remote:
            featureEntryUptd = [self.service inserMapFeatureEntry:featureEntryOrig inMapWithGID:map.GID error:&error];
            break;
            
        case ST_Sync_Delete_Remote:
            featureEntryUptd = [self.service deleteMapFeatureEntryWithGID:point.GID inMapWithGID:map.GID error:&error];
            if(!error) {
                [point markAsDeleted];
            }
            break;
            
        case ST_Sync_Update_Remote:
            featureEntryUptd = [self.service updateMapFeatureEntry:featureEntryOrig withGID:point.GID inMapWithGID:map.GID error:&error];
            break;
            
        default:
            // No se hace nada con el resto de estados
            break;
    }
    
    if(!error) {
        [GMapService __fill_MEPoint:point withFeedFeatureEntry:featureEntryUptd];
        return true;
    } else {
        NSLog(@"  >> Sync Error: %@ / %@", error, [error userInfo]);
        return false;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) __fill_MEMap:(MEMap *)map withFeedMapEntry:(GDataEntryMap*) entry {
    
    map.GID = [GMapSyncWrapper extract_MapID_fromEntry:entry];
    map.name = [[entry title] stringValue];
    map.syncETag = [entry ETag];
    map.desc = [[entry summary] stringValue];
    map.ts_created = [[entry publishedDate] date];
    map.ts_updated = [[entry updatedDate] date];
    map.syncStatus = ST_Sync_OK;
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) __fill_MEPoint:(MEPoint *)point withFeedFeatureEntry:(GDataEntryMapFeature*) entry {
    
    point.GID = [GMapSyncWrapper extract_PointID_fromEntry:entry];
    point.name = [[entry title] stringValue];
    point.syncETag = [entry ETag];
    point.desc = [[entry summary] stringValue];
    point.ts_created = [[entry publishedDate] date];
    point.ts_updated = [[entry updatedDate] date];
    point.syncStatus = ST_Sync_OK;
    
    NSString *kml = [GMapSyncWrapper get_KML_fromEntry:entry];
    point.kmlBlob = kml;
}

//---------------------------------------------------------------------------------------------------------------------
+ (GDataEntryMap*) __create_FeedMapEntry_fromMEMap:(MEMap *)map {
    
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
+ (GDataEntryMapFeature*) __create_FeedFeatureEntry_fromMEPoint:(MEPoint *)point {
    
    GDataEntryMapFeature *newEntry = [GDataEntryMapFeature featureEntryWithTitle:point.name];
    
    NSError *error;
    NSString *kmlStr = point.kmlBlob;
    NSXMLElement *kmlElem = [[[NSXMLElement alloc] initWithXMLString:kmlStr error:&error] autorelease];
    if (kmlElem) {
        [newEntry addKMLValue:kmlElem];
        return newEntry;
    } else {
        NSLog(@"__create_FeedFeatureEntry_fromMEPoint - cannot make kml element, %@", error);
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------

@end
