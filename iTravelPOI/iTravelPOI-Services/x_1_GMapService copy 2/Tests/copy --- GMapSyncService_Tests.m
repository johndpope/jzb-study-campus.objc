//
//  GMapSyncService_Tests.m
//  iTravelPOI-MacTests
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "Cypher.h"
#import "GMapSyncService.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Tests private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------
#define UPDATE_POINT_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/yellow-dot.png"

static GMapSyncService *gmapSyncService = nil;



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncService_Tests private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMapSyncService_Tests : XCTestCase <GMPSyncDelegate>

@property (strong, nonatomic) NSDictionary *localMaps;
@property (strong, nonatomic) NSDictionary *localPlacemarks;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncService_Tests implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMapSyncService_Tests


// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) _createLocalMapWithName:(NSString *)name {
    
    GMTMap *map = [GMTMap emptyMapWithName:name];
    
    [self.localMaps setValue:map forKey:map.gID];
    return map;
}

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
- (id) __mock_createLocalMapFrom:(GMTMap *)remoteMap error:(NSError * __autoreleasing *)err {
    NSLog(@"remoteMap = %@", remoteMap);
    GMTMap *localMap = [[GMTMap alloc] initFromItem:remoteMap];
    localMap.modifiedSinceLastSyncValue = TRUE;
    localMap.gID = GM_LOCAL_ID;
    localMap.etag = GM_NO_SYNC_ETAG;
    return localMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMapSync_01__CreateLocal {
    
    DDLogVerbose(@"*** ] ]  SYNC CREATE LOCAL functionality \n\n");

    id<GMPSyncDataSource> mockDataSource = OCMStrictProtocolMock(@protocol(GMPSyncDataSource));

    OCMStub([mockDataSource getAllLocalMapList:[OCMArg setTo:nil]]).andReturn([NSArray array]);
    
    //OCMStub([mockDataSource createLocalMapFrom:[OCMArg any] error:[OCMArg setTo:nil]]).andCall(self, @selector(__mock_createLocalMapFrom:error:));

    
    OCMStub([mockDataSource createLocalMapFrom:[OCMArg any] error:[OCMArg setTo:nil]]).andDo(^(NSInvocation *invocation) {

        GMTMap __autoreleasing *remoteMap = nil;
        [invocation getArgument:&remoteMap atIndex:2];
        
        GMTMap __autoreleasing *localMap = [[GMTMap alloc] initFromItem:remoteMap];
        localMap.modifiedSinceLastSyncValue = TRUE;
        localMap.gID = GM_LOCAL_ID;
        localMap.etag = GM_NO_SYNC_ETAG;
        [invocation setReturnValue:&localMap];
    });
    
    OCMStub([mockDataSource createLocalPlacemarkFrom:[OCMArg any] inLocalMap:[OCMArg any] error:[OCMArg setTo:nil]]).andDo(^(NSInvocation *invocation) {
        
        GMTPlacemark __autoreleasing *remotePlacemark = nil;
        [invocation getArgument:&remotePlacemark atIndex:2];
        
        GMTPlacemark __autoreleasing *localPlacemark = [[GMTPlacemark alloc] initFromItem:remotePlacemark];
        localPlacemark.modifiedSinceLastSyncValue = TRUE;
        localPlacemark.gID = GM_LOCAL_ID;
        localPlacemark.etag = GM_NO_SYNC_ETAG;
        [invocation setReturnValue:&localPlacemark];

    });

    OCMStub([mockDataSource updateLocalMap:[OCMArg any] withRemoteMap:[OCMArg any] allPlacemarksOK:TRUE error:[OCMArg setTo:nil]]).andDo(^(NSInvocation *invocation) {
        
        GMTMap __autoreleasing *localMap = nil;
        [invocation getArgument:&localMap atIndex:2];

        GMTMap __autoreleasing *remoteMap = nil;
        [invocation getArgument:&remoteMap atIndex:3];

        BOOL allPlacemarksOK = NO;
        [invocation getArgument:&allPlacemarksOK atIndex:4];

        if(allPlacemarksOK) {
            localMap.etag = remoteMap.etag;
            localMap.updated_Date = remoteMap.updated_Date;
        }
        
        BOOL returnCode = NO;
        [invocation setReturnValue:&returnCode];
    }).ignoringNonObjectArgs;

    
    GMTMap *myMap = [GMTMap emptyMapWithName:@"pepe"];
    id partialMock = OCMPartialMock(myMap);
    //[partialMock setExpectationOrderMatters:YES];
    OCMStub([partialMock setSummary:[OCMArg any]]);

    
    GMTMap *mockedMap = (GMTMap *)partialMock;
    mockedMap.etag = @"pepe";
    //mockedMap.summary = @"juan";
    
    NSLog(@"myMap = %@", myMap);

    //OCMVerifyAll(partialMock);
    
    OCMVerify([partialMock setSummary:[OCMArg any]]);
    
    if(![self __GMap_LoginWithDataSource:mockDataSource]) return;

    
    [gmapSyncService syncMaps];
    
}



// =====================================================================================================================
#pragma mark -
#pragma mark POINT-BATCH - TEST methods
// ---------------------------------------------------------------------------------------------------------------------








// =====================================================================================================================
#pragma mark -
#pragma mark MAP - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------





// =====================================================================================================================
#pragma mark -
#pragma mark POINT - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------








// =====================================================================================================================
#pragma mark -
#pragma mark GENERAL - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) __GMap_LoginWithDataSource:(id<GMPSyncDataSource>) dataSource {
    
    if(gmapSyncService==nil) {
        DDLogVerbose(@"*** ] ]  Login in GMap Service\n\n");
        
        NSError *error = nil;
        NSString *usr = [Cypher decryptString:@"anphcnp1ZWxhQGdtYWlsLmNvbQ=="];
        NSString *pwd = [Cypher decryptString:@"I3dlYndlYjE5NzE="];
        
        gmapSyncService = [GMapSyncService serviceWithEmail2:usr password:pwd dataSource:dataSource delegate:self error:&error];
        XCTAssertNil(error, "\n\nError calling gmapSyncService[%@]: %@\n\n", @"serviceWithEmail", error);
        
        XCTAssertNotNil(gmapSyncService, @"\n\ngmapSyncService instance must not be nil\n\n");
        
        DDLogVerbose(@"\n\n");
    }
    
    return gmapSyncService!=nil;
    
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



// =====================================================================================================================
#pragma mark -
#pragma mark GMPSyncDataSource Protocol methods
// ---------------------------------------------------------------------------------------------------------------------
// Map methods
- (NSArray *) getAllLocalMapList:(NSError * __autoreleasing *)err {
    return [NSArray array];
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *)  createRemoteMapFrom:(GMTMap *)localMap error:(NSError * __autoreleasing *)err {
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateRemoteMap:(GMTMap *)remoteMap withLocalMap:(id)localMap error:(NSError * __autoreleasing *)err {
    return FALSE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalMapFrom:(GMTMap *)remoteMap error:(NSError * __autoreleasing *)err {
    
    GMTMap *localMap = [[GMTMap alloc] initFromItem:remoteMap];
    localMap.modifiedSinceLastSyncValue = TRUE;
    localMap.gID = GM_LOCAL_ID;
    localMap.etag = GM_NO_SYNC_ETAG;
    
    return localMap;

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalMap:(id)localMap withRemoteMap:(GMTMap *)remoteMap allPlacemarksOK:(BOOL)allPlacemarksOK error:(NSError * __autoreleasing *)err {
    return FALSE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalMap:(id)localMap error:(NSError * __autoreleasing *)err {
    return FALSE;
}


// ---------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------
// Placemark methods
- (NSArray *) getLocalPlacemarkListForMap:(id)localMap error:(NSError * __autoreleasing *)err {
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPlacemark *) createRemotePlacemarkFrom:(id)localPlacemark error:(NSError * __autoreleasing *)err {
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateRemotePlacemark:(GMTPlacemark *)remotePlacemark withLocalPlacemark:(id)localPlacemark error:(NSError * __autoreleasing *)err {
    return FALSE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalPlacemarkFrom:(GMTPlacemark *)remotePlacemark inLocalMap:(id)map error:(NSError * __autoreleasing *)err {
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalPlacemark:(id)localPlacemark withRemotePlacemark:(GMTPlacemark *)remotePlacemark error:(NSError * __autoreleasing *)err {
    return FALSE;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalPlacemark:(id)localPlacemark inLocalMap:(id)map error:(NSError * __autoreleasing *)err {
    return FALSE;
}




@end
