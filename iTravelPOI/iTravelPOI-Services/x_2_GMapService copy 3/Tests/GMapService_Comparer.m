//
//  GMapService_Comparer.m
//  iTravelPOI-MacTests
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GMComparer.h"
#import "GMSimpleItemFactory.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Tests private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------


// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapService_Comparer private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMapService_Comparer : XCTestCase

@property (strong, nonatomic) GMSimpleItemFactory *itemFactory;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapService_Comparer implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMapService_Comparer


// ---------------------------------------------------------------------------------------------------------------------
- (void)setUp {
    
    [super setUp];
    DDLogVerbose(@"\n\n\n=== [Test start]  ==============================================================================");
    self.itemFactory = [GMSimpleItemFactory factory];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)tearDown {
    
    DDLogVerbose(@"\n\n--- [Test end]  --------------------------------------------------------------------------------\n\n");
    [super tearDown];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_01_NilData {
    
    DDLogVerbose(@"*** >> TEST: NilData\n\n");
    
    NSArray *compTuples = [GMComparer compareLocalItems:nil toRemoteItems:nil];
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==0, @"\n\nGMComparer must return an empty array of tuples\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_02_EmptyData {
    
    DDLogVerbose(@"*** >> TEST: EmptyData\n\n");
    
    NSArray *localMaps = [NSMutableArray array];
    NSArray *remoteMaps = [NSMutableArray array];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==0, @"\n\nGMComparer must return an empty array of tuples\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_03_NO_Remote_Create_Remote_1 {
    
    
    DDLogVerbose(@"*** >> TEST: NO_Remote_Create_Remote_1\n\n");

    id<GMMap> localMap = [self __createLocalMapWithName:@"@test_map"];
    localMap.localModified = TRUE;

    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray array];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");

    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_CreateRemote, @"\n\nGMComparer must return a tuple with status = CS_CreateRemote\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertNil(theTuple.remote, @"\n\nGMComparer must returna tuple with remote = nil\n\n");
    XCTAssertFalse(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = FALSE\n\n");

}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_04_NO_Remote_Create_Remote_2 {
    
    
    DDLogVerbose(@"*** >> TEST: NO_Remote_Create_Remote_2\n\n");
    
    id<GMMap> localMap = [self __createSyncMapWithName:@"@test_map"];
    localMap.localModified = TRUE;
    
    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray array];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_CreateRemote, @"\n\nGMComparer must return a tuple with status = CS_CreateRemote\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertNil(theTuple.remote, @"\n\nGMComparer must returna tuple with remote = nil\n\n");
    XCTAssertTrue(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = TRUE\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_05_NO_Remote_Delete_Remote_1 {
    
    
    DDLogVerbose(@"*** >> TEST: NO_Remote_Delete_Remote_1\n\n");
    
    id<GMMap> localMap = [self __createSyncMapWithName:@"@test_map"];
    
    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray array];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_DeleteLocal, @"\n\nGMComparer must return a tuple with status = CS_DeleteLocal\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertNil(theTuple.remote, @"\n\nGMComparer must returna tuple with remote = nil\n\n");
    XCTAssertFalse(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = FALSE\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_06_NO_Remote_Delete_Remote_2 {
    
    
    DDLogVerbose(@"*** >> TEST: NO_Remote_Delete_Remote_2\n\n");
    
    id<GMMap> localMap = [self __createLocalMapWithName:@"@test_map"];
    localMap.markedAsDeleted = TRUE;
    localMap.localModified = TRUE;
 
    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray array];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_DeleteLocal, @"\n\nGMComparer must return a tuple with status = CS_DeleteLocal\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertNil(theTuple.remote, @"\n\nGMComparer must returna tuple with remote = nil\n\n");
    XCTAssertFalse(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = FALSE\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_07_NO_Remote_Delete_Remote_3 {
    
    
    DDLogVerbose(@"*** >> TEST: NO_Remote_Delete_Remote_3\n\n");
    
    id<GMMap> localMap = [self __createSyncMapWithName:@"@test_map"];
    localMap.markedAsDeleted = TRUE;
    localMap.localModified = TRUE;
    
    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray array];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_DeleteLocal, @"\n\nGMComparer must return a tuple with status = CS_DeleteLocal\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertNil(theTuple.remote, @"\n\nGMComparer must returna tuple with remote = nil\n\n");
    XCTAssertFalse(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = FALSE\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_08_WITH_Remote_Create_Local {
    
    
    DDLogVerbose(@"*** >> TEST: WITH_Remote_Create_Local\n\n");
    
    id<GMMap> remoteMap = [self __createSyncMapWithName:@"@test_map"];
    
    NSArray *localMaps = [NSMutableArray array];
    NSArray *remoteMaps = [NSMutableArray arrayWithObject:remoteMap];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_CreateLocal, @"\n\nGMComparer must return a tuple with status = CS_CreateLocal\n\n");
    XCTAssertNil(theTuple.local, @"\n\nGMComparer must returna tuple with local = nil\n\n");
    XCTAssertEqual(theTuple.remote, remoteMap, @"\n\nGMComparer must returna tuple with remote = passed one\n\n");
    XCTAssertFalse(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = FALSE\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_09_WITH_BOTH_Nothing {
    
    
    DDLogVerbose(@"*** >> TEST: WITH_BOTH_Nothing\n\n");
    
    id<GMMap> localMap = [self __createSyncMapWithName:@"@test_map"];
    id<GMMap> remoteMap = [self __createSyncMapWithName:@"@test_map"];
    remoteMap.gID = localMap.gID;
    
    
    remoteMap.etag = localMap.etag;
    
    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray arrayWithObject:remoteMap];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_Equals, @"\n\nGMComparer must return a tuple with status = CS_Equals\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertEqual(theTuple.remote, remoteMap, @"\n\nGMComparer must returna tuple with remote = passed one\n\n");
    XCTAssertFalse(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = FALSE\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_10_WITH_BOTH_Update_Remote {
    
    
    DDLogVerbose(@"*** >> TEST: WITH_BOTH_Update_Remote\n\n");
    
    id<GMMap> localMap = [self __createSyncMapWithName:@"@test_map"];
    id<GMMap> remoteMap = [self __createSyncMapWithName:@"@test_map"];
    remoteMap.gID = localMap.gID;
    
    
    remoteMap.etag = localMap.etag;
    localMap.localModified = TRUE;
    
    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray arrayWithObject:remoteMap];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_UpdateRemote, @"\n\nGMComparer must return a tuple with status = CS_UpdateRemote\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertEqual(theTuple.remote, remoteMap, @"\n\nGMComparer must returna tuple with remote = passed one\n\n");
    XCTAssertFalse(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = FALSE\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_11_WITH_BOTH_Delete_Remote {
    
    
    DDLogVerbose(@"*** >> TEST: WITH_BOTH_Delete_Remote\n\n");
    
    id<GMMap> localMap = [self __createSyncMapWithName:@"@test_map"];
    id<GMMap> remoteMap = [self __createSyncMapWithName:@"@test_map"];
    remoteMap.gID = localMap.gID;
    
    
    remoteMap.etag = localMap.etag;
    localMap.markedAsDeleted = TRUE;
    localMap.localModified = TRUE;
    
    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray arrayWithObject:remoteMap];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_DeleteRemote, @"\n\nGMComparer must return a tuple with status = CS_DeleteRemote\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertEqual(theTuple.remote, remoteMap, @"\n\nGMComparer must returna tuple with remote = passed one\n\n");
    XCTAssertFalse(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = FALSE\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_12_WITH_BOTH_Update_Local_1 {
    
    
    DDLogVerbose(@"*** >> TEST: WITH_BOTH_Update_Local_1\n\n");
    
    id<GMMap> localMap = [self __createSyncMapWithName:@"@test_map"];
    id<GMMap> remoteMap = [self __createSyncMapWithName:@"@test_map"];
    remoteMap.gID = localMap.gID;
    
    
    //remoteMap.etag = localMap.etag;

    
    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray arrayWithObject:remoteMap];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_UpdateLocal, @"\n\nGMComparer must return a tuple with status = CS_UpdateLocal\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertEqual(theTuple.remote, remoteMap, @"\n\nGMComparer must returna tuple with remote = passed one\n\n");
    XCTAssertFalse(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = FALSE\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_12_WITH_BOTH_Update_Local_2 {
    
    
    DDLogVerbose(@"*** >> TEST: WITH_BOTH_Update_Local_2\n\n");
    
    id<GMMap> localMap = [self __createSyncMapWithName:@"@test_map"];
    id<GMMap> remoteMap = [self __createSyncMapWithName:@"@test_map"];
    remoteMap.gID = localMap.gID;
    
    
    //remoteMap.etag = localMap.etag;
    localMap.markedAsDeleted = TRUE;
    
    
    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray arrayWithObject:remoteMap];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_UpdateLocal, @"\n\nGMComparer must return a tuple with status = CS_UpdateLocal\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertEqual(theTuple.remote, remoteMap, @"\n\nGMComparer must returna tuple with remote = passed one\n\n");
    XCTAssertTrue(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = TRUE\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMComp_13_WITH_BOTH_Update_Local_3 {
    
    
    DDLogVerbose(@"*** >> TEST: WITH_BOTH_Update_Local_3\n\n");
    
    id<GMMap> localMap = [self __createSyncMapWithName:@"@test_map"];
    id<GMMap> remoteMap = [self __createSyncMapWithName:@"@test_map"];
    remoteMap.gID = localMap.gID;
    
    
    //remoteMap.etag = localMap.etag;
    localMap.localModified = TRUE;
    
    
    NSArray *localMaps = [NSMutableArray arrayWithObject:localMap];
    NSArray *remoteMaps = [NSMutableArray arrayWithObject:remoteMap];
    
    NSArray *compTuples = [GMComparer compareLocalItems:localMaps toRemoteItems:remoteMaps];
    
    XCTAssertNotNil(compTuples, @"\n\nGMComparer must return a not nil array of tuples\n\n");
    XCTAssertTrue(compTuples.count==1, @"\n\nGMComparer must return an array of tuples with just one element\n\n");
    
    GMCompareTuple *theTuple = compTuples[0];
    XCTAssertTrue(theTuple.compStatus == CS_UpdateLocal, @"\n\nGMComparer must return a tuple with status = CS_UpdateLocal\n\n");
    XCTAssertEqual(theTuple.local, localMap, @"\n\nGMComparer must returna tuple with local = passed one\n\n");
    XCTAssertEqual(theTuple.remote, remoteMap, @"\n\nGMComparer must returna tuple with remote = passed one\n\n");
    XCTAssertTrue(theTuple.conflicted, @"\n\nGMComparer must returna tuple with conflicted = TRUE\n\n");
    
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (id<GMMap>) __createLocalMapWithName:(NSString *)name {
    
    // Contador para los IDs y ETags iniciales
    static NSUInteger s_idCounter = 1;
    
    id<GMMap> localMap = [self.itemFactory newMapWithName:name errRef:nil];
    localMap.markedAsDeleted = FALSE;
    localMap.localModified = FALSE;
    localMap.gID = [NSString stringWithFormat:@"%@-%04ld", GM_LOCAL_NO_SYNC_ID, s_idCounter++];
    localMap.etag = [NSString stringWithFormat:@"%@-%04ld", GM_LOCAL_NO_SYNC_ETAG, s_idCounter++];
    return localMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id<GMMap>) __createSyncMapWithName:(NSString *)name {
    
    // Contador para los IDs y ETags iniciales
    static NSUInteger s_idCounter = 1;
    
    id<GMMap> localMap = [self.itemFactory newMapWithName:name errRef:nil];
    localMap.markedAsDeleted = FALSE;
    localMap.localModified = FALSE;
    localMap.gID = [NSString stringWithFormat:@"REMOTE-GID-%04ld", s_idCounter++];
    localMap.etag = [NSString stringWithFormat:@"REMOTE-ETAG-%04ld", s_idCounter++];
    return localMap;
}





@end
