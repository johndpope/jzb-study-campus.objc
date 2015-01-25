//
//  GMapSyncService_Tests.m
//  iTravelPOI-MacTests
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GMapSyncService_Mocks.h"

#import "Cypher.h"
#import "GMapSyncService.h"
#import "GMapSyncComparator.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Tests private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------
#define UPDATE_POINT_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/yellow-dot.png"



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncService_Tests private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMapSyncService_Tests : XCTestCase <GMPSyncDelegate>

@property (strong, nonatomic) Mock_GMPSyncDataSource *mockDataSource;
@property (strong, nonatomic) GMapService *gmapService;
@property (strong, nonatomic) GMapSyncService *gmapSyncService;



@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncService_Tests implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMapSyncService_Tests


// ---------------------------------------------------------------------------------------------------------------------
- (void)setUp {
    
    [super setUp];
    DDLogVerbose(@"\n\n\n=== [Test start]  ==============================================================================");
    self.continueAfterFailure = NO;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)tearDown {
    
    DDLogVerbose(@"\n\n--- [Test end]  --------------------------------------------------------------------------------\n\n");
    [super tearDown];
}



// =====================================================================================================================
#pragma mark -
#pragma mark SYNC - CREATE - TEST methods
// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMapSync_01__WithoutRemote {
    
    
    NSError *localError = nil;

    
    DDLogVerbose(@"*** ] ]  SYNC WITHOUT REMOTE functionality \n\n");

    
    // Inicializa los servicios con mockups
    [self __GMap_createGMapSyncServiceForTest];
    
    
    // Crea mapas para la prueba
    [self __mock_tearDown_All];
    [self __mock_setUp_Test_Without_Remote];
    
    
    // Ejecuta la sincronizacion de la prueba
    [self.gmapSyncService syncMaps];

    
    localError = nil;
    NSArray *remoteMaps = [self.gmapService getMapList:&localError];
    localError = nil;
    NSArray *localMaps = [self.mockDataSource __mock_getAllLocalMapList];
    
    XCTAssertTrue(localMaps.count==2, @"After synchronization there should be 2 local items (1,2): %@",localMaps);
    XCTAssertTrue(remoteMaps.count==2, @"After synchronization there should be 2 remote items (1,2): %@",remoteMaps);
    
    NSArray *compTuples = [GMapSyncComparator compareLocalItems:localMaps withRemoteItems:remoteMaps];
    XCTAssertTrue(compTuples.count==0, @"After synchronization local and remote items should be equal: %@",compTuples);
    
    // Limpia los mapas de pruebas
    [self __mock_tearDown_All];
    
}





// =====================================================================================================================
#pragma mark -
#pragma mark MAP - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) __mock_tearDown_All {
    
    NSError *localError = nil;
    NSArray *mapList = [self.gmapService getMapList:&localError];
    for(GMTMap *map in mapList) {
        localError = nil;
        [self.gmapService deleteMap:map error:&localError];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __mock_setUp_Test_Without_Remote {
    
    /*
    GMTMap *testMap1 = [GMTMap emptyMapWithName:[NSString stringWithFormat:@"%@%@",MOCK_MAP_NAME_PREFIX,@"Create_Test_Map-1"]];
    testMap1 = [self.gmapService addMap:testMap1 error:&localError];
    
    NSMutableArray *bCmds = [NSMutableArray array];
    for(int n=0;n<4;n++) {
        GMTPoint *point = [GMTPoint emptyPointWithName:[NSString stringWithFormat:@"point-%d",n]];
        [bCmds addObject:[GMTBatchCmd batchCmd:BATCH_CMD_ADD withPlacemark:point]];
    }
    
    localError = nil;
    [self.gmapService processBatchCmds:bCmds inMap:testMap1 error:&localError checkCancelBlock:^BOOL{
        return NO;
    }];
     */
    

    // Mapa local, NO sincronizado, NO borrado, SI modificado ==> CREATE_REMOTE
    GMTMap *localMap1 = [self.mockDataSource __mock_newLocalMapWithName:@"Local-1-NoSync-NoDeleted-Modified" fakeSynced:NO];
    localMap1.markedAsDeletedValue = NO;
    localMap1.modifiedSinceLastSyncValue = YES;

    // Mapa local, SI sincronizado, No borrado, SI Modificado ==> CREATE_REMOTE (CONFLICTO)
    GMTMap *localMap2 = [self.mockDataSource __mock_newLocalMapWithName:@"Local-2-Synced-NoDeleted-Modified"  fakeSynced:YES];
    localMap2.markedAsDeletedValue = NO;
    localMap2.modifiedSinceLastSyncValue = YES;
    
    // Mapa local, SI sincronizado, No borrado, NO Modificado ==> DELETE_LOCAL
    GMTMap *localMap3 = [self.mockDataSource __mock_newLocalMapWithName:@"Local-3-Synced-NoDeleted-NoModified"  fakeSynced:YES];
    localMap3.markedAsDeletedValue = NO;
    localMap3.modifiedSinceLastSyncValue = NO;
    
    // Mapa local, SI sincronizado, SI borrado, SI Modificado ==> DELETE_LOCAL
    GMTMap *localMap4 = [self.mockDataSource __mock_newLocalMapWithName:@"Local-4-Synced-Deleted-Modified"  fakeSynced:YES];
    localMap4.markedAsDeletedValue = YES;
    localMap4.modifiedSinceLastSyncValue = YES;

    // Mapa local, NO sincronizado, SI borrado, NO Modificado ==> DELETE_LOCAL
    GMTMap *localMap5 = [self.mockDataSource __mock_newLocalMapWithName:@"Local-5-NoSync-Deleted-NoModified"  fakeSynced:NO];
    localMap5.markedAsDeletedValue = YES;
    localMap5.modifiedSinceLastSyncValue = NO;

}




// =====================================================================================================================
#pragma mark -
#pragma mark GENERAL - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) __GMap_createGMapSyncServiceForTest  {
    
    DDLogVerbose(@"*** [ [  __GMap_GMapSyncServiceWith\n\n");

    
    NSString *usr = [Cypher decryptString:@"anphcnp1ZWxhQGdtYWlsLmNvbQ=="];
    NSString *pwd = [Cypher decryptString:@"I3dlYndlYjE5NzE="];
    
    NSError *localError = nil;
    self.gmapService = [Mock_GMapService serviceWithEmail2:usr password:pwd error:&localError];
    XCTAssertNil(localError, "\n\nError calling GMapService[%@]: %@\n\n", @"serviceWithEmail", localError);
    XCTAssertNotNil(self.gmapService, @"\n\\nGMapService instance must not be nil\n\n");
    
    
    self.mockDataSource = [Mock_GMPSyncDataSource newInstance];
    
    self.gmapSyncService = [GMapSyncService serviceWithGMapService:self.gmapService dataSource:self.mockDataSource delegate:self];
    XCTAssertNotNil(self.gmapSyncService, @"\n\nGMapSyncService instance must not be nil\n\n");
    
    
    DDLogVerbose(@"*** ] ]  __GMap_GMapSyncServiceWith\n\n");
}


// =====================================================================================================================
#pragma mark -
#pragma mark GMPSyncDelegate Protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) syncStarted {
    DDLogVerbose(@"\n\n******> GMPSyncDelegate: syncStarted\n");
}


// ---------------------------------------------------------------------------------------------------------------------
- (void) syncFinished:(BOOL)wasAllOK {
    DDLogVerbose(@"\n\n******> GMPSyncDelegate: syncFinished[OK=%d]\n",wasAllOK);
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) errorNotification:(NSError *)error {
    DDLogVerbose(@"\n\n******> GMPSyncDelegate: errorNotification:\n\n%@\n\n",error);
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willGetRemoteMapList {
    DDLogVerbose(@"\n\n\n[ [ ******> GMPSyncDelegate: willGetRemoteMapList\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) didGetRemoteMapList {
    DDLogVerbose(@"\n\n] ] ******> GMPSyncDelegate: didGetRemoteMapList\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willCompareLocalAndRemoteMaps {
    DDLogVerbose(@"\n\n[ [ ******> GMPSyncDelegate: willCompareLocalAndRemoteMaps\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) didCompareLocalAndRemoteMaps:(NSArray *)compTuples {
    DDLogVerbose(@"\n\n] ] ******> GMPSyncDelegate: didCompareLocalAndRemoteMaps:\n\n%@\n\n",compTuples);
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) shouldProcessMapTuple:(GMTCompTuple *)tuple error:(NSError * __autoreleasing *)err {
    DDLogVerbose(@"\n\n******> GMPSyncDelegate: shouldProcessMapTuple:\n\n%@\n\n",tuple);
    return TRUE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willSyncMapTuple:(GMTCompTuple *)tuple {
    DDLogVerbose(@"\n\n[ [ ******> GMPSyncDelegate: willSyncMapTuple:\n\n%@\n\n",tuple);
}
// ---------------------------------------------------------------------------------------------------------------------
- (void) didSyncMapTuple:(GMTCompTuple *)tuple {
    DDLogVerbose(@"\n\n] ] ******> GMPSyncDelegate: didSyncMapTuple:\n\n%@\n\n",tuple);
}


@end
