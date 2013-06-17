//
// SyncDataService.m
// iTravelPOI-FRWK
//
// Created by Jose Zarzuela on 29/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//
#define __MBaseEntity__SYNCHRONIZATION__PROTECTED__
#import "SyncDataService.h"

#import "NSManagedObjectContext+Utils.h"

#import "GMapSyncService.h"
#import "GMTItem.h"
#import "GMTMap.h"
#import "GMTPoint.h"
#import "GMTCompTuple.h"

#import "MMap.h"
#import "MPoint.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Service private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark SyncDataService Service private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface SyncDataService () <GMPSyncDataSource, GMPSyncDelegate>

@property (nonatomic, strong) NSManagedObjectContext *moChildContextAsync;
@property (nonatomic, assign) id<SyncDataDelegate> delegate;
@property (nonatomic, strong) GMapSyncService *syncSrvc;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark SyncDataService Service implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation SyncDataService



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (SyncDataService *) syncDataServiceWithChildContext:(NSManagedObjectContext *)moChildContext delegate:(id<SyncDataDelegate>)delegate {

    SyncDataService *me = [[SyncDataService alloc] init];
    me.moChildContextAsync = moChildContext;
    me.delegate = delegate;
    me.isRunning = NO;
    
    return me;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    [self cancelSync];
}




// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark public INSTANCE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) startMapsSync {
    
    
    __block BOOL allOK = true;
    
    [self.moChildContextAsync performBlock:^{
        
        NSError *error = nil;
        
        
        DDLogVerbose(@"****** Started: Async Data Synchronization ******");
        
        // Apunta que esta en ejecucion
        self.isRunning = YES;
        
        
        self.syncSrvc = [GMapSyncService serviceWithEmail:@"jzarzuela@gmail.com" password:@"#webweb1971" dataSource:self delegate:self error:&error];
        if(!self.syncSrvc) {
            allOK = false;
            DDLogError(@"Error en sincronizacion(login) %@", error);
        }
        
        if(![self.syncSrvc syncMaps:&error]) {
            allOK = false;
            if(error!=nil) {
                DDLogError(@"Error en sincronizacion: %@", error);
            } else if (self.syncSrvc.wasCanceled){
                DDLogError(@"Error en sincronizacion: Cancelada");
            } else {
                DDLogError(@"Error en sincronizacion: Error desconocido");
            }
        }
        
        if(allOK) {
            [self cleanDeletedMaps];
        }

        [self.moChildContextAsync saveChanges];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate syncFinished:allOK];
        });
        
        DDLogVerbose(@"****** Ended: Async Data Synchronization ******");
        
        self.syncSrvc = nil;
        
        // Apunta que ya NO esta en ejecucion
        self.isRunning = NO;
    }];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) cancelSync {
    [self.syncSrvc cancelSync];
}


// =====================================================================================================================
#pragma mark -
#pragma mark <GMPSyncDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getAllLocalMapList:(NSError **)err {
    
    if(err != nil) *err = nil;
    NSArray *allMaps = [MMap allMapsInContext:self.moChildContextAsync includeMarkedAsDeleted:true];
    return allMaps;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) gmMapFromLocalMap:(MMap *)localMap error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    GMTMap *gmMap = [GMTMap emptyMap];
    
    gmMap.name = localMap.name;
    gmMap.gID = localMap.gID;
    gmMap.etag = localMap.etag;
    gmMap.published_Date = localMap.creationTime;
    gmMap.updated_Date = localMap.updateTime;
    gmMap.summary = localMap.summary;
    
    return gmMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalMapFrom:(GMTMap *)gmMap error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    MMap *localMap = [MMap emptyMapWithName:gmMap.name inContext:self.moChildContextAsync];
    [self updateLocalMap:localMap withRemoteMap:gmMap allPointsOK:true error:err];
    
    return localMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalMap:(MMap *)localMap withRemoteMap:(GMTMap *)gmMap allPointsOK:(BOOL)allPointsOK error:(NSError **)err {
    
    if(err != nil) *err = nil;
    if(!gmMap) {
        return false;
    }
    
    [localMap _updateBasicInfoWithGID:gmMap.gID etag:gmMap.etag creationTime:gmMap.published_Date updateTime:gmMap.updated_Date];
    localMap.name = gmMap.name;
    localMap.summary = gmMap.summary;
    [localMap markAsDeleted:FALSE];
    [localMap _cleanMarkAsModified];
    
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalMap:(MMap *)localMap error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    [localMap markAsDeleted:true];
    [localMap _cleanMarkAsModified];
    
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) localPointListForMap:(MMap *)localMap error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    NSArray *pointList = localMap.points.allObjects;
    return pointList;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) gmPointFromLocalPoint:(MPoint *)localPoint error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    GMTPoint *gmPoint = [GMTPoint emptyPoint];
    
    gmPoint.name = localPoint.name;
    gmPoint.gID = localPoint.gID;
    gmPoint.etag = localPoint.etag;
    gmPoint.published_Date = localPoint.creationTime;
    gmPoint.updated_Date = localPoint.updateTime;
    
    gmPoint.descr = localPoint.descr;
    gmPoint.iconHREF = localPoint.iconHREF;
    gmPoint.latitude = localPoint.latitudeValue;
    gmPoint.longitude = localPoint.longitudeValue;
    
    
    /**************************************************************************************************/
    //@TODO: Hay que conseguir la informacion de las categorias de algun que extraer la informacion de las categorias" userInfo:nil];
    DDLogVerbose(@"******> FALTA PROCESAR LA INFORMACION DE LAS CATEGORIAS");
    /**************************************************************************************************/

    return gmPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalPointFrom:(GMTPoint *)gmPoint inLocalMap:(MMap *)map error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    MPoint *localPoint = [MPoint emptyPointWithName:gmPoint.name inMap:map];
    [self updateLocalPoint:localPoint withRemotePoint:gmPoint error:err];
    
    return localPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalPoint:(MPoint *)localPoint withRemotePoint:(GMTPoint *)gmPoint error:(NSError **)err {
    
    if(err != nil) *err = nil;
    if(!gmPoint) {
        return false;
    }
    
    [localPoint _updateBasicInfoWithGID:gmPoint.gID etag:gmPoint.etag creationTime:gmPoint.published_Date updateTime:gmPoint.updated_Date];
    localPoint.name = gmPoint.name;
    localPoint.descr = gmPoint.descr;
    localPoint.iconHREF = gmPoint.iconHREF;
    [localPoint setLatitude:gmPoint.latitude longitude:gmPoint.longitude];
    
    
    /**************************************************************************************************/
    //@TODO: Hay que conseguir la informacion de las categorias de algun sitio del punto
    DDLogVerbose(@"******> FALTA PROCESAR LA INFORMACION DE LAS CATEGORIAS");
    /**************************************************************************************************/

    
    [localPoint markAsDeleted:FALSE];
    [localPoint _cleanMarkAsModified];
    
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalPoint:(MPoint *)localPoint inLocalMap:(id)map error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    [localPoint markAsDeleted:TRUE];
    [localPoint _cleanMarkAsModified];
    
    return true;
}


// =====================================================================================================================
#pragma mark -
#pragma mark OPTIONAL <GMPSyncDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) willGetRemoteMapList {
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.delegate willGetRemoteMapList];
    });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) didGetRemoteMapList {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.delegate didGetRemoteMapList];
    });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willCompareLocalAndRemoteMaps {

    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.delegate willCompareLocalAndRemoteMaps];
    });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) didCompareLocalAndRemoteMaps:(NSArray *)compTuples {

    __block NSArray *_compTuples = compTuples;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.delegate didCompareLocalAndRemoteMaps:_compTuples];
    });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willSyncMapTuple:(GMTCompTuple *)t_tuple withIndex:(int) t_index {

    __block GMTCompTuple *tuple = t_tuple;
    __block int index = t_index;
    
    if(index>=0) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate willSyncMapTuple:tuple withIndex:index];
        });
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) didSyncMapTuple:(GMTCompTuple *)t_tuple withIndex:(int) t_index syncOK:(BOOL)t_syncOK {
    
    __block GMTCompTuple *tuple = t_tuple;
    __block int index = t_index;
    __block BOOL syncOK = t_syncOK;
    
    if(index>=0) {
        // Vamos salvando mapa a mapa el resultado de la sincronizacion
        [self.moChildContextAsync saveChanges];
        
        // Avisa al delegate
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate didSyncMapTuple:tuple withIndex:index syncOK:syncOK];
        });
    }
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Getter & Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) cleanDeletedMaps {
    
    NSArray *allMaps = [MMap allMapsInContext:self.moChildContextAsync includeMarkedAsDeleted:true];
    for(MMap *map in allMaps) {
        if(map.markedAsDeletedValue) {
            [map.managedObjectContext deleteObject:map];
        }
    }
}

@end

