//
//  GMapService_Synchronizer.m
//  iTravelPOI-MacTests
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>


#import "FilteredRemoteService.h"
#import "Cypher.h"

#import "Mock_LocalStorage.h"

#import "GMSynchronizer.h"
#import "GMComparer.h"
#import "GMapService_Assertions.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Tests private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------
#define MockReject(MOCK_OBJ)  [[[MOCK_OBJ reject] ignoringNonObjectArgs] andForwardToRealObject]
#define MockExpect(MOCK_OBJ)  [[[MOCK_OBJ expect] ignoringNonObjectArgs] andForwardToRealObject]
#define TEST_MAP_PREFIX @"@sync-test-"


// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapService_Synchronizer private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMapService_Synchronizer : XCTestCase


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapService_Synchronizer implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMapService_Synchronizer


static GMRemoteService *gmapService = nil;
static GMapService_Assertions *modelUtil = nil;
static Mock_LocalStorage *localStorage = nil;
static GMSynchronizer *synchronizer = nil;



// ---------------------------------------------------------------------------------------------------------------------
- (void)setUp {
    
    [super setUp];
    DDLogVerbose(@"\n\n\n\n=== [Test start]  ==============================================================================\n\n\n\n");

    // Lo primero es crear una instancia del servicio logada
    [self _gmapLogin];
    
    // Prepara para los test
    [self _cleanMapsForTestExecution];

}

// ---------------------------------------------------------------------------------------------------------------------
- (void)tearDown {
    
    DDLogVerbose(@"\n\n\n\n--- [Test end]  --------------------------------------------------------------------------------\n\n\n\n");
    [super tearDown];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_00_Test {

    DDLogVerbose(@"*** >> TEST: Test\n\n");
    
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_01_Nothing_To_Sync {
    
    DDLogVerbose(@"*** >> TEST: Nothing_To_Sync\n\n");
    
    NSError *localError;
    BOOL rc;
    
    
    //GMSimpleMap *remoteMap = [localStorage createMapWithName:@"map1" numTestPoints:2];
    //rc = [gmapService synchronizeMap:remoteMap errRef:&localError];
    
    //GMSimpleMap *localMap = [localStorage createCopyFromMap:remoteMap];
    //[localStorage directAddMap:localMap];
    
    [synchronizer syncronizeStorages];
    [self _assertStoragesAreSynchronized];
}


// =====================================================================================================================
#pragma mark -
#pragma mark GENERAL - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) _assertStoragesAreSynchronized {
    
    NSError *localError;
    
    NSArray *localMaps = [localStorage retrieveMapList:&localError];
    NSArray *remoteMaps = [gmapService retrieveMapList:&localError];
    XCTAssertNil(localError, @"Error calling 'retrieveMapList': %@",localError);
    XCTAssertNotNil(remoteMaps, @"Error calling 'retrieveMapList' mapList is nil");

    
    NSArray *mapTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    for(GMCompareTuple *tuple1 in mapTuples) {
        
        XCTAssertTrue(tuple1.compStatus==CS_Equals, @"Map tuple.compStatus should be 'CS_Equals': %@", tuple1);
        
        id<GMMap> localMap = (id<GMMap>)tuple1.local;
        id<GMMap> remoteMap = (id<GMMap>)tuple1.remote;
        BOOL rc = [gmapService retrievePlacemarksForMap:remoteMap errRef:&localError];
        XCTAssertNil(localError, @"Error calling 'retrievePlacemarksForMap': %@",localError);
        XCTAssertTrue(rc, @"Error calling 'retrievePlacemarksForMap' RC should be FALSE");
        
        NSArray *placemarkTuples = [GMComparer compareLocalItems:localMap.placemarks toRemoteItems:remoteMap.placemarks];
        for(GMCompareTuple *tuple2 in placemarkTuples) {
            XCTAssertTrue(tuple2.compStatus==CS_Equals, @"Placemark tuple.compStatus should be 'CS_Equals': %@", tuple2);
        }
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _cleanMapsForTestExecution {
    
    NSError *error = nil;
    
    
    NSArray *mapList = [gmapService retrieveMapList:&error];
    XCTAssertNil(error, @"Error calling 'retrieveMapList': %@",error);
    XCTAssertNotNil(mapList, @"Error calling 'retrieveMapList' mapList is nil");
    
    for(GMSimpleMap *map in mapList) {
        map.markedAsDeleted = TRUE;
        //BOOL rc = [gmapService synchronizeMap:map errRef:&error];
        //XCTAssertNil(error, @"Error calling 'synchronizeMap' for deleting a map: %@",error);
        //XCTAssertTrue(rc, @"Error calling 'synchronizeMap' RC should be FALSE");
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _gmapLogin {
    
    if(!gmapService) {
        
        NSError *error = nil;
        NSString *usr = [Cypher decryptString:@"anphcnp1ZWxhQGdtYWlsLmNvbQ=="];
        NSString *pwd = [Cypher decryptString:@"I3dlYndlYjE5NzE="];
        
        
        modelUtil = [[GMapService_Assertions alloc] init];
        localStorage = [Mock_LocalStorage storageWithMapNamePrefix:TEST_MAP_PREFIX];
        gmapService = [[FilteredRemoteService alloc] initWithEmail:usr
                                                          password:pwd
                                                       itemFactory:localStorage.itemFactory
                                                     mapNamePrefix:TEST_MAP_PREFIX
                                                            errRef:&error];
        synchronizer = [GMSynchronizer synchronizerWithLocalStorage:localStorage remoteStorage:gmapService];
        
        XCTAssertNotNil(gmapService, @"gmapService instance must not be nil");
        XCTAssertNil(error, "Error calling gmapService.initWithEmail: %@", error);
    }
}


@end
