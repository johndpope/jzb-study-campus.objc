//
//  GMapService_Synchronizer.m
//  iTravelPOI-MacTests
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "Mock_Storage.h"

#import "GMSynchronizer.h"
#import "GMComparer.h"
#import "GMapService_Assertions.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Tests private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------
#define MockReject(MOCK_OBJ)  [[[MOCK_OBJ reject] ignoringNonObjectArgs] andForwardToRealObject]
#define MockExpect(MOCK_OBJ)  [[[MOCK_OBJ expect] ignoringNonObjectArgs] andForwardToRealObject]



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapService_Synchronizer private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMapService_Synchronizer : XCTestCase


@property (strong, nonatomic)  GMapService_Assertions *modelUtil;
@property (strong, nonatomic)  Mock_Storage *localStorage;
@property (strong, nonatomic)  Mock_Storage *remoteStorage;
@property (strong, nonatomic)  GMSynchronizer *synchronizer;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapService_Synchronizer implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMapService_Synchronizer



// ---------------------------------------------------------------------------------------------------------------------
- (void)setUp {
    
    [super setUp];
    DDLogVerbose(@"\n\n\n=== [Test start]  ==============================================================================");

    // Lo primero es crear una instancia del servicio logada
    self.modelUtil = [[GMapService_Assertions alloc] init];
    self.localStorage = [Mock_Storage storageWithType:MST_Local];
    self.remoteStorage = [Mock_Storage storageWithType:MST_Remote];
    self.synchronizer = [GMSynchronizer synchronizerWithLocalStorage:self.localStorage remoteStorage:self.remoteStorage];

}

// ---------------------------------------------------------------------------------------------------------------------
- (void)tearDown {
    
    DDLogVerbose(@"\n\n--- [Test end]  --------------------------------------------------------------------------------\n\n");
    [super tearDown];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_00_Test {

    DDLogVerbose(@"*** >> TEST: Test\n\n");
    
    id<GMMap> remoteMap = [self.remoteStorage createMapWithName:@"map1" numTestPoints:1];
    [self.remoteStorage addMap:remoteMap withPlacemarks:TRUE];
    id<GMMap> localMap = [self.localStorage createClonFromMap:remoteMap];
    [self.localStorage addMap:localMap withPlacemarks:TRUE];
    
    
    [self.synchronizer syncronizeStorages];
    
    NSArray *maps = [self.localStorage retrieveMapList:nil];
    NSLog(@"----- maps ------------------------------");
    for(id<GMMap> map in maps) {
        NSLog(@"map = %@\n\n", map);
    }
    
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_01_Sync_Nothing {
    
    DDLogVerbose(@"*** >> TEST: Sync_Nothing\n\n");
    
    // Crea el mismo mapa directamente en ambos almacenes
    id<GMMap> remoteMap = [self.remoteStorage createMapWithName:@"map1" numTestPoints:2];
    [self.remoteStorage addMap:remoteMap withPlacemarks:TRUE];

    id<GMMap> localMap = [self.localStorage createClonFromMap:remoteMap];
    [self.localStorage addMap:localMap withPlacemarks:TRUE];

    
    // Crea los mocks para controlar que se ejecuta
    id mockLocal = OCMPartialMock(self.localStorage);
    [MockReject(mockLocal) synchronizeMap:[OCMArg any] errRef:[OCMArg setTo:nil]];

    id mockRemote = OCMPartialMock(self.remoteStorage);
    [MockReject(mockRemote) synchronizeMap:[OCMArg any] errRef:[OCMArg setTo:nil]];

    
    // Ejecuta la sincronizacion
    [self.synchronizer syncronizeStorages];

    
    // Comprueba el resultado
    [self _assertStoragesAreSynchronized];
    OCMVerifyAll(mockLocal);
    OCMVerifyAll(mockRemote);
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_02_Sync_New_Remote {
    
    DDLogVerbose(@"*** >> TEST: Sync_New_Remote\n\n");
    
    // Crea y almacena directamente un mapa nuevo en el LocalStorage
    id<GMMap> localMap = [self.localStorage createMapWithName:@"map1" numTestPoints:3];
    [self.localStorage addMap:localMap withPlacemarks:TRUE];
    
    // Marca uno de los puntos como borrado
    ((id<GMPoint>)localMap.placemarks[1]).markedAsDeleted = TRUE;
    
    
    // Crea los mocks para controlar que se ejecuta
    id mockLocal = OCMPartialMock(self.localStorage);
    [MockReject(mockLocal) addMap:[OCMArg any] withPlacemarks:FALSE];
    [MockExpect(mockLocal) updateMap:[OCMArg any] withPlacemarks:FALSE];
    [MockReject(mockLocal) removeMap:[OCMArg any] withPlacemarks:FALSE];
    
    id mockRemote = OCMPartialMock(self.remoteStorage);
    [MockExpect(mockRemote) addMap:[OCMArg any] withPlacemarks:FALSE];
    [MockReject(mockRemote) updateMap:[OCMArg any] withPlacemarks:FALSE];
    [MockReject(mockRemote) removeMap:[OCMArg any] withPlacemarks:FALSE];
    
    
    // Ejecuta la sincronizacion
    [self.synchronizer syncronizeStorages];
    
    
    // Comprueba el resultado
    [self _assertStoragesAreSynchronized];
    OCMVerifyAll(mockLocal);
    OCMVerifyAll(mockRemote);
}



// =====================================================================================================================
#pragma mark -
#pragma mark GENERAL - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) _assertStoragesAreSynchronized {
    
    NSArray *localMaps = [self.localStorage retrieveMapList:nil];
    NSArray *remoteMaps = [self.remoteStorage retrieveMapList:nil];
    NSArray *mapTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    for(GMCompareTuple *tuple1 in mapTuples) {
        
        XCTAssertTrue(tuple1.compStatus==CS_Equals, @"Map tuple.compStatus should be 'CS_Equals': %@", tuple1);
        
        id<GMMap> localMap = (id<GMMap>)tuple1.local;
        id<GMMap> remoteMap = (id<GMMap>)tuple1.remote;
        NSArray *placemarkTuples = [GMComparer compareLocalItems:localMap.placemarks toRemoteItems:remoteMap.placemarks];
        for(GMCompareTuple *tuple2 in placemarkTuples) {
            XCTAssertTrue(tuple2.compStatus==CS_Equals, @"Placemark tuple.compStatus should be 'CS_Equals': %@", tuple2);
        }
    }
    
    
}


@end
