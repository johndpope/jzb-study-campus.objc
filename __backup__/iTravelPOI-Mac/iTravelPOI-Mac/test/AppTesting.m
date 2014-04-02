//
// AppTesting.m
// iTravelPOI
//
// Created by Jose Zarzuela on 16/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//


#define __AppTesting__IMPL__
#import "AppTesting.h"

#import "DDLog.h"

#import "BaseCoreData.h"

#import "MMap.h"
#import "MPoint.h"
#import "MCategory.h"

#import "GMTMap.h"
#import "GMTPoint.h"
#import "GMapSyncService.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface AppTesting () <GMPSyncDelegate>

@property (nonatomic, strong) NSManagedObjectContext *moContext;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation AppTesting

@synthesize moContext = _moContext;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (AppTesting *) appTestingWithMOContext:(NSManagedObjectContext *)moContext {

    AppTesting *me = [[AppTesting alloc] init];
    me.moContext = moContext;
    return me;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) excuteTestWithMOContext:(NSManagedObjectContext *)moContext {

    DDLogVerbose(@"****** START: excuteTest ******");


    NSError *error;

    [moContext reset];


    AppTesting *me = [AppTesting appTestingWithMOContext:moContext];

    GMapSyncService *syncSrvc = [GMapSyncService serviceWithEmail:@"jzarzuela@gmail.com" password:@"#webweb1971" delegate:me error:&error];
    if(!syncSrvc) {
        DDLogError(@"Error en sincronizacion(login) %@", error);
    }

    if(![syncSrvc syncMaps:&error]) {
        DDLogError(@"Error en sincronizacion %@", error);
    }



    DDLogVerbose(@"****** END: excuteTest ******");

}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------



// =====================================================================================================================
#pragma mark -
#pragma mark <GMPSyncDelegate> PROTOCOL methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getAllLocalMapList:(NSError * __autoreleasing *)err {

    if(err != nil) *err = nil;

    NSArray *mapList = [MMap allMapsInContext:self.moContext includeMarkedAsDeleted:true];

    return mapList;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) gmMapFromLocalMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {

    if(err != nil) *err = nil;

    GMTMap *gmMap = [GMTMap emptyMap];

    gmMap.name = localMap.name;
    gmMap.gmID = localMap.gmID;
    gmMap.etag = localMap.etag;
    // gmMap.published_Date = localMap.published_Date; --> STR => DATE
    // gmMap.updated_Date = localMap.updated_Date; --> STR => DATE

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

    localMap.name = gmMap.name;
    localMap.gmID = gmMap.gmID;
    localMap.etag = gmMap.etag;
    [localMap updateDeleteMark:false];
    localMap.modifiedSinceLastSyncValue = false;
    // localMap.published_Date = gmMap.published_Date; --> STR => DATE
    // localMap.updated_Date = gmMap.updated_Date; --> STR => DATE

    localMap.summary = gmMap.summary;

    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalMap:(MMap *)localMap error:(NSError * __autoreleasing *)err {

    if(err != nil) *err = nil;

    [localMap updateDeleteMark:true];
    localMap.modifiedSinceLastSyncValue = true;

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
    // gmPoint.published_Date = localPoint.published_Date; --> STR => DATE
    // gmPoint.updated_Date = localPoint.updated_Date; --> STR => DATE

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

    localPoint.name = gmPoint.name;
    localPoint.gmID = gmPoint.gmID;
    localPoint.etag = gmPoint.etag;
    [localPoint updateDeleteMark:false];
    localPoint.modifiedSinceLastSyncValue = false;
    // localPoint.published_Date = gmMap.published_Date; --> STR => DATE
    // localPoint.updated_Date = gmMap.updated_Date; --> STR => DATE

    localPoint.descr = gmPoint.descr;
    [localPoint moveToCategory:[MCategory categoryForIconHREF:gmPoint.iconHREF inContext:localPoint.managedObjectContext]];
    [localPoint setLatitude:gmPoint.latitude longitude:gmPoint.longitude];

    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalPoint:(MPoint *)localPoint inLocalMap:(id)map error:(NSError * __autoreleasing *)err {

    if(err != nil) *err = nil;

    [localPoint updateDeleteMark:true];
    localPoint.map.modifiedSinceLastSyncValue = true;

    return true;
}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------



@end


