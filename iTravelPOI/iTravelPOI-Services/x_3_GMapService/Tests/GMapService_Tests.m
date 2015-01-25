//
//  GMapService_Tests.m
//  iTravelPOI-MacTests
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GMRemoteService.h"
#import "GMSimpleItemFactory.h"

#import "Cypher.h"
#import "NSString+JavaStr.h"

#import "GMapService_Assertions.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Tests private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------
#define UPDATE_POINT_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/yellow-dot.png"





// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapService_Tests private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMapService_Tests : XCTestCase

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapService_Tests implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMapService_Tests


static GMSimpleItemFactory __strong *itemFactory;
static GMRemoteService __strong *gmapService;
static GMapService_Assertions __strong *modelUtil;



// ---------------------------------------------------------------------------------------------------------------------
- (void)setUp {
    
    [super setUp];
    DDLogVerbose(@"\n\n\n=== [Test start]  ==============================================================================");
    
    // Lo primero es crear una instancia del servicio logada
    if(![self __GMap_Login]) return;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)tearDown {
    
    DDLogVerbose(@"\n\n--- [Test end]  --------------------------------------------------------------------------------\n\n");
    [super tearDown];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_01_Login {
    
    [self __GMap_Login];

}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_01_RetrieveMapAndPlacemarksList {
    
    DDLogVerbose(@"*** >> TEST: RetrieveMapAndPlacemarksList\n\n");

    NSError *error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
    NSArray *mapList = [gmapService retrieveMapList:&error];
    XCTAssertNil(error, @"Error from 'retrieveMapList' should be nil: %@", error);
    XCTAssertNotNil(mapList, @"Map list shouldn't be nil");

    XCTAssertTrue(mapList.count>0, @"Map list shouldn't be empty");
    
    for(id<GMMap> map in mapList) {

        [modelUtil assert_RemoteItem:map skipDeleteLocal:FALSE];
        
        
        error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
        BOOL rc = [gmapService retrievePlacemarksForMap:map errRef:&error];
        XCTAssertNil(error, @"Error from 'retrievePlacemarksForMap' should be nil: %@", error);
        XCTAssertTrue(rc, @"RC from 'retrievePlacemarksForMap' shouldn't be FALSE");
        XCTAssertNotNil(map.placemarks, @"Remote GMMap.placemarks shouldn't be nil: %@", map);
        
        
        NSLog(@"\n\n");
        NSLog(@"map = %@",map.name);

        for(id<GMPlacemark> placemark in map.placemarks) {
            
            [modelUtil assert_RemoteItem:placemark skipDeleteLocal:FALSE];
            NSLog(@"    placemark = %@",placemark.name);
        }
        
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_02_Map_CRUD {
    
    
    NSError *error = nil;
    BOOL rc = FALSE;
    
    
    DDLogVerbose(@"*** >> TEST: Map_CRUD\n\n");

    
    // ==== CREATE MAP ================================================================================
    id<GMMap> map = [itemFactory newMapWithName:@"@map-crud-create" errRef:nil];
    [modelUtil assert_LocalItem:map];
    
    id<GMPoint> point1 = [itemFactory newPointWithName:@"point-crud-create-1" inMap:map errRef:nil];
    point1.descr = @"descr-point-crud-create-1";
    [modelUtil assert_LocalItem:point1];

    id<GMPoint> point2 = [itemFactory newPointWithName:@"point-crud-create-2" inMap:map errRef:nil];
    point2.descr = @"descr-point-crud-create-2";
    [modelUtil assert_LocalItem:point2];

    id<GMPoint> point3 = [itemFactory newPointWithName:@"point-crud-create-3" inMap:map errRef:nil];
    point3.descr = @"descr-point-crud-create-3";
    [modelUtil assert_LocalItem:point3];
    
    XCTAssertTrue(map.placemarks.count==3, @"Local map should have 3 placemarks");
    
    error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
    rc = [gmapService synchronizeMap:map errRef:&error];
    XCTAssertNil(error, @"Error from 'synchronizeMap' should be nil: %@", error);
    XCTAssertTrue(rc, @"RC from 'synchronizeMap' shouldn't be FALSE");
    
    [modelUtil assert_RemoteItem:map skipDeleteLocal:FALSE];
    for(id<GMPlacemark> placemark in map.placemarks) {
        [modelUtil assert_RemoteItem:placemark skipDeleteLocal:FALSE];
    }
    
    [modelUtil assertInfoIsSyncForMap:map gmapService:gmapService skipDeleteLocal:FALSE];
    

    
    
    // ==== UPDATE MAP ================================================================================
    id<GMPoint> point4 = [itemFactory newPointWithName:@"point-crud-update-4" inMap:map errRef:nil];
    point4.descr = @"descr-point-crud-create-4<>&;á∫";
    [modelUtil assert_LocalItem:point4];
    
    point1.markedAsDeleted = TRUE;
    
    point3.name = @"point-crud-create-3-updated";
    point3.iconHREF = @"http://maps.gstatic.com/mapfiles/ms2/micons/yellow-dot.png";
    point3.descr = @"descr-point-crud-create-3-updated";
    point3.coordinates = [GMCoordinates coordinatesWithLongitude:10.10 latitude:20.20];
    point3.markedForSync = TRUE;
    
    map.name = @"@map-crud-create-updated";
    map.summary = @"summary-map-crud-create-updated";
    map.markedForSync = TRUE;
    
    error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
    rc = [gmapService synchronizeMap:map errRef:&error];
    XCTAssertNil(error, @"Error from 'synchronizeMap' should be nil: %@", error);
    XCTAssertTrue(rc, @"RC from 'synchronizeMap' shouldn't be FALSE");
    
    [modelUtil assert_RemoteItem:map skipDeleteLocal:FALSE];
    for(id<GMPlacemark> placemark in map.placemarks) {
        [modelUtil assert_RemoteItem:placemark skipDeleteLocal:TRUE];
    }
    
    [modelUtil assertInfoIsSyncForMap:map gmapService:gmapService skipDeleteLocal:TRUE];

    
    

    // ==== DELETE MAP ================================================================================
    map.markedAsDeleted = TRUE;

    error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
    rc = [gmapService synchronizeMap:map errRef:&error];
    XCTAssertNil(error, @"Error from 'synchronizeMap' should be nil: %@", error);
    XCTAssertTrue(rc, @"RC from 'synchronizeMap' shouldn't be FALSE");
    
    [modelUtil assert_RemoteItem:map skipDeleteLocal:TRUE];
    for(id<GMPlacemark> placemark in map.placemarks) {
        [modelUtil assert_RemoteItem:placemark skipDeleteLocal:TRUE];
    }
    
    error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
    id<GMMap> remoteMap = [gmapService retrieveMapByGID:map.gID errRef:&error];
    XCTAssertNil(remoteMap, @"Map from 'retrieveMapByGID' should be nil: %@", remoteMap);
    XCTAssertNotNil(error, @"Error from 'retrieveMapByGID' shouldn't be nil");
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_03_Duplicate_Maps {

    NSError *error = nil;
    BOOL rc = FALSE;

    
    DDLogVerbose(@"*** >> TEST: Duplicate_Maps\n\n");
    
    
    
    error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
    NSArray *mapList = [gmapService retrieveMapList:&error];
    XCTAssertNil(error, @"Error from 'retrieveMapList' should be nil: %@", error);
    XCTAssertNotNil(mapList, @"Map list shouldn't be nil");
    
    XCTAssertTrue(mapList.count>0, @"Map list shouldn't be empty");
    
    
    int id_index = 0;
    
    for(id<GMMap> map in mapList) {
        
        [modelUtil assert_RemoteItem:map skipDeleteLocal:FALSE];
        
        error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
        rc = [gmapService retrievePlacemarksForMap:map errRef:&error];
        XCTAssertNil(error, @"Error from 'retrievePlacemarksForMap' should be nil: %@", error);
        XCTAssertTrue(rc, @"RC from 'retrievePlacemarksForMap' shouldn't be FALSE");
        XCTAssertNotNil(map.placemarks, @"Remote GMMap.placemarks shouldn't be nil: %@", map);
        
        for(id<GMPlacemark> placemark in map.placemarks) {
            [modelUtil assert_RemoteItem:placemark skipDeleteLocal:FALSE];

            // Lo combierte en local
            placemark.gID = [NSString stringWithFormat:@"%@-%04d", GM_LOCAL_NO_SYNC_ID, id_index];
            placemark.etag = [NSString stringWithFormat:@"%@-%04d", GM_LOCAL_NO_SYNC_ETAG, id_index];
            placemark.markedForSync = TRUE;
        }
        
        // Lo combierte en local
        map.gID = [NSString stringWithFormat:@"%@-%04d", GM_LOCAL_NO_SYNC_ID, id_index];
        map.etag = [NSString stringWithFormat:@"%@-%04d", GM_LOCAL_NO_SYNC_ETAG, id_index];
        map.name = [NSString stringWithFormat:@"@duplicate-%@", map.name];
        map.markedForSync = TRUE;
        
        // Lo crea como duplicado
        error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
        rc = [gmapService synchronizeMap:map errRef:&error];
        XCTAssertNil(error, @"Error from 'synchronizeMap' should be nil: %@", error);
        XCTAssertTrue(rc, @"RC from 'synchronizeMap' shouldn't be FALSE");
        
        // Lo comprueba
        [modelUtil assertInfoIsSyncForMap:map gmapService:gmapService skipDeleteLocal:TRUE];
        
        // Lo elimina
        map.markedAsDeleted = TRUE;
        
        error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
        rc = [gmapService synchronizeMap:map errRef:&error];
        XCTAssertNil(error, @"Error from 'synchronizeMap' should be nil: %@", error);
        XCTAssertTrue(rc, @"RC from 'synchronizeMap' shouldn't be FALSE");
        
        error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
        id<GMMap> remoteMap = [gmapService retrieveMapByGID:map.gID errRef:&error];
        XCTAssertNil(remoteMap, @"Map from 'retrieveMapByGID' should be nil: %@", remoteMap);
        XCTAssertNotNil(error, @"Error from 'retrieveMapByGID' shouldn't be nil");

    }

}





// =====================================================================================================================
#pragma mark -
#pragma mark GENERAL - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) __GMap_Login {
    
    if(gmapService==nil) {
        DDLogVerbose(@"*** >> Login in GMap Service\n\n");
        
        NSString *usr = [Cypher decryptString:@"anphcnp1ZWxhQGdtYWlsLmNvbQ=="];
        NSString *pwd = [Cypher decryptString:@"I3dlYndlYjE5NzE="];
        
        modelUtil = [[GMapService_Assertions alloc] init];
        itemFactory = [GMSimpleItemFactory factory];

        NSError *error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
        gmapService = [[GMRemoteService alloc] initWithEmail:usr password:pwd itemFactory:itemFactory errRef:&error];
        XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"serviceWithEmail", error);
        XCTAssertNotNil(gmapService, @"\n\nGMapService instance must not be nil\n\n");
        
        DDLogVerbose(@"\n\n");
    }
    
    return gmapService!=nil;
    
}



@end
