//
// SyncDataService.m
// iTravelPOI-FRWK
//
// Created by Jose Zarzuela on 29/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "SyncDataService.h"
#import "GMapSyncService.h"
#import "GMTItem.h"
#import "GMTMap.h"
#import "GMTPoint.h"
#import "MMap.h"
#import "MPoint.h"
#import "GMTCompTuple.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Service private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark SyncDataService Service private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface SyncDataService () <GMPSyncDelegate>

@property (nonatomic, strong) NSManagedObjectContext *moContext;
@property (nonatomic, assign) id<PSyncDataDelegate> delegate;
@property (nonatomic, strong) GMapSyncService *syncSrvc;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

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
+ (SyncDataService *) syncDataServiceWithMOContext:(NSManagedObjectContext *)moContext delegate:(id<PSyncDataDelegate>)delegate {

    SyncDataService *me = [[SyncDataService alloc] init];
    me.moContext = moContext;
    me.delegate = delegate;
    me.delegateQueue = dispatch_get_current_queue();
    
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
    
    [self.moContext performBlock:^{
        
        DDLogVerbose(@"****** START: excuteTest ******");
        
        
        NSError *error;
        
        self.syncSrvc = [GMapSyncService serviceWithEmail:@"jzarzuela@gmail.com" password:@"#webweb1971" delegate:self error:&error];
        if(!self.syncSrvc) {
            allOK = false;
            DDLogError(@"Error en sincronizacion(login) %@", error);
        }
        
        if(![self.syncSrvc syncMaps:&error]) {
            allOK = false;
            DDLogError(@"Error en sincronizacion %@", error);
        }
        
        DDLogVerbose(@"****** END: excuteTest ******");
        dispatch_async(dispatch_get_main_queue(), ^{
            if(allOK) {
                [self cleanDeletedMaps];
            }
            [self.delegate syncFinished:allOK];
        });
    }];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) cancelSync {
    [self.syncSrvc cancelSync];
    self.syncSrvc = nil;
}


// =====================================================================================================================
#pragma mark -
#pragma mark <GMPSyncDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getAllLocalMapList:(NSError * __autoreleasing *)err {
    
    if(err != nil) *err = nil;
    NSArray *allMaps = [MMap allMapsInContext:self.moContext includeMarkedAsDeleted:true];
    return allMaps;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) gmMapFromLocalMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {
    
    if(err != nil) *err = nil;
    
    GMTMap *gmMap = [GMTMap emptyMap];
    
    gmMap.name = localMap.name;
    gmMap.gmID = localMap.gmID;
    gmMap.etag = localMap.etag;
    gmMap.published_Date = localMap.published_date;
    gmMap.updated_Date = localMap.updated_date;
    gmMap.summary = localMap.summary;
    
    return gmMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalMapFrom:(GMTMap *)gmMap error:(NSError * __autoreleasing *)err {
    
    if(err != nil) *err = nil;
    
    MMap *localMap = [MMap emptyMapWithName:gmMap.name inContext:self.moContext];
    [self updateLocalMap:localMap withRemoteMap:gmMap allPointsOK:true error:err];
    
    return localMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalMap:(MMap *)localMap withRemoteMap:(GMTMap *)gmMap allPointsOK:(BOOL)allPointsOK error:(NSError * __autoreleasing *)err {
    
    if(err != nil) *err = nil;
    if(!gmMap) {
        return false;
    }
    
    localMap.name = gmMap.name;
    localMap.gmID = gmMap.gmID;
    localMap.etag = gmMap.etag;
    localMap.published_date = gmMap.published_Date;
    localMap.updated_date = gmMap.updated_Date;
    
    localMap.summary = gmMap.summary;
    
    [localMap updateDeleteMark:false];
    localMap.modifiedSinceLastSyncValue = false;
    
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {
    
    if(err != nil) *err = nil;
    
    [localMap updateDeleteMark:true];
    localMap.modifiedSinceLastSyncValue = false;
    
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) localPointListForMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {
    
    if(err != nil) *err = nil;
    
    NSArray *pointList = localMap.points.allObjects;
    return pointList;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) gmPointFromLocalPoint:(MPoint *)localPoint error:(NSError * __autoreleasing *)err {
    
    if(err != nil) *err = nil;
    
    GMTPoint *gmPoint = [GMTPoint emptyPoint];
    
    gmPoint.name = localPoint.name;
    gmPoint.gmID = localPoint.gmID;
    gmPoint.etag = localPoint.etag;
    gmPoint.published_Date = localPoint.published_date;
    gmPoint.updated_Date = localPoint.updated_date;
    
    gmPoint.descr = localPoint.descr;
    gmPoint.iconHREF = localPoint.category.iconHREF;
    gmPoint.latitude = localPoint.latitudeValue;
    gmPoint.longitude = localPoint.longitudeValue;
    
    return gmPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalPointFrom:(GMTPoint *)gmPoint inLocalMap:(MMap *)map error:(NSError * __autoreleasing *)err {
    
    if(err != nil) *err = nil;
    
    MCategory *cat = [MCategory categoryForIconHREF:gmPoint.iconHREF inContext:map.managedObjectContext];
    MPoint *localPoint = [MPoint emptyPointWithName:gmPoint.name inMap:map withCategory:cat];
    [self updateLocalPoint:localPoint withRemotePoint:gmPoint error:err];
    
    return localPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalPoint:(MPoint *)localPoint withRemotePoint:(GMTPoint *)gmPoint error:(NSError * __autoreleasing *)err {
    
    if(err != nil) *err = nil;
    if(!gmPoint) {
        return false;
    }
    
    localPoint.name = gmPoint.name;
    localPoint.gmID = gmPoint.gmID;
    localPoint.etag = gmPoint.etag;
    localPoint.published_date = gmPoint.published_Date;
    localPoint.updated_date = gmPoint.updated_Date;
    
    localPoint.descr = gmPoint.descr;
    [localPoint moveToCategory:[MCategory categoryForIconHREF:gmPoint.iconHREF inContext:localPoint.managedObjectContext]];
    [localPoint setLatitude:gmPoint.latitude longitude:gmPoint.longitude];
    
    [localPoint updateDeleteMark:false];
    localPoint.modifiedSinceLastSyncValue = false;
    
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalPoint:(MPoint *)localPoint inLocalMap:(id)map error:(NSError * __autoreleasing *)err {
    
    if(err != nil) *err = nil;
    
    [localPoint updateDeleteMark:true];
    localPoint.map.modifiedSinceLastSyncValue = false;
    
    return true;
}


// =====================================================================================================================
#pragma mark -
#pragma mark OPTIONAL <GMPSyncDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) willGetRemoteMapList {
    dispatch_async(self.delegateQueue, ^{
        [self.delegate willGetRemoteMapList];
    });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) didGetRemoteMapList {
    dispatch_async(self.delegateQueue, ^{
        [self.delegate didGetRemoteMapList];
    });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willSyncMapTupleList:(NSArray *)_compTuples {
    
    __block NSArray *compTuples = _compTuples;
    dispatch_async(self.delegateQueue, ^{
        [self.delegate willSyncMapTupleList:compTuples];
    });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willSyncMapTuple:(GMTCompTuple *)t_tuple withIndex:(int) t_index {

    __block GMTCompTuple *tuple = t_tuple;
    __block int index = t_index;
    
    if(index>=0) {
        dispatch_async(self.delegateQueue, ^{
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
        dispatch_async(self.delegateQueue, ^{
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
    
    NSArray *allMaps = [MMap allMapsInContext:self.moContext includeMarkedAsDeleted:true];
    for(MMap *map in allMaps) {
        if(map.markedAsDeletedValue) {
            [map.managedObjectContext deleteObject:map];
        }
    }
}

@end

