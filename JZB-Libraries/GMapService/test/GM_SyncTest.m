//
// GMTItemBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//
#define __GM_SyncTest_IMPL_
#import "GM_SyncTest.h"

#import "DDLog.h"
#import "GMapSyncService.h"
#import "GMPComparable.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface FakeItem : NSObject <GMPComparableLocal>

@property (strong) NSString *name;
@property (strong) NSString *gmID;
@property (strong) NSString *etag;
@property (assign) BOOL markedAsDeletedValue;
@property (assign) BOOL wasSynchronizedValue;
@property (assign) BOOL modifiedSinceLastSyncValue;

@end

@implementation FakeItem

@synthesize name = _name;
@synthesize gmID = _gmID;
@synthesize etag = _etag;
@synthesize markedAsDeletedValue = _markedAsDeletedValue;
@synthesize wasSynchronizedValue = _wasSynchronizedValue;
@synthesize modifiedSinceLastSyncValue = _modifiedSinceLastSyncValue;

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GM_SyncTest () <GMPSyncDelegate>

@property (strong) GMapSyncService *service;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GM_SyncTest

@synthesize exitOnError = _exitOnError;
@synthesize error = _error;
@synthesize service = _service;


#define GM_SyncTest_MAP_NAME_BASE @"@GM_SyncTest_map"
#define GM_SyncTest_MAP_DESC_BASE @"@GM_SyncTest_map description"


#define GM_SyncTest_POINT_NAME_BASE @"@GM_SyncTest_point"
#define GM_SyncTest_POINT_DESC_BASE @"@GM_SyncTest_point description"


#define GM_SyncTest_ICON_HREF_1 @"http://maps.gstatic.com/mapfiles/ms2/micons/red-dot.png"
#define GM_SyncTest_ICON_HREF_2 @"http://maps.gstatic.com/mapfiles/ms2/micons/green-dot.png"



#define _CHECK_TRUE_(is_true, msg) \
    if(!is_true) { \
        self.error = localError; \
        DDLogError(@"**** Error - GM_SyncTest - %@: check was nil", msg); \
        if(self.exitOnError) exit(1); \
        return false; \
    }

#define _CHECK_ITEM_(item, msg) \
    _CHECK_TRUE_((item != nil), msg)

#define _CHECK_ERROR_(localError, msg) \
    if(localError != nil) { \
        self.error = localError; \
        DDLogError(@"**** Error - GM_SyncTest - %@: %@", msg, [localError localizedDescription]); \
        DDLogError(@"Error info: %@", localError); \
        if(self.exitOnError) exit(1); \
        return false; \
    }

#define _CHECK_ERROR_AND_ITEM_(localError, item, msg) \
    if(localError != nil || item == nil) { \
        self.error = localError; \
        DDLogError(@"**** Error - GM_SyncTest - %@: %@", msg, [localError localizedDescription]); \
        DDLogError(@"Error info: %@", localError); \
        if(self.exitOnError) exit(1); \
        return false; \
    }



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GM_SyncTest *) testWithEmail:(NSString *)email password:(NSString *)password exitOnError:(BOOL)exitOnError error:(NSError **)err {

    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;

    GM_SyncTest *me = [[GM_SyncTest alloc] init];

    GMapSyncService *srvc = [GMapSyncService serviceWithEmail:email password:password delegate:me error:err];
    if(srvc == nil) {
        DDLogError(@"**** Error - GM_SyncTest - testWithEmail - GMapService failed to initialize: %@", [*err localizedDescription]);
        DDLogError(@"Error info: %@", *err);
        if(exitOnError) exit(1);

        return nil;
    }

    me.service = srvc;
    me.exitOnError = exitOnError;
    return me;

}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) syncTestAll {


    // [self test_createUpdateDelete_map];
    // //[self test_readAllPoint];
    // [self test_createUpdateDelete_point];

    [self test_sync_maps];

    DDLogVerbose(@"***** GM_SyncTest - DONE! *****");
    if(self.exitOnError) exit(1);

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) asyncTestAll {

    dispatch_queue_t _serviceQueue = dispatch_queue_create([@"myqueue" UTF8String], NULL);
    dispatch_async(_serviceQueue, ^(void){

                       [self syncTestAll];

                   });

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) test_sync_maps {

    DDLogVerbose(@"-----------------------------------------------------------------------------");
    DDLogVerbose(@"+ GM_SyncTest - test_sync_maps\n");

    NSError *localError = nil;
    [self.service syncMaps:&localError];
    _CHECK_ERROR_(localError, @"test_sync_maps");

    return true;
}

// =====================================================================================================================
#pragma mark -
#pragma mark Protocol GMPSyncDelegate methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getAllLocalMapList:(NSError **)err {

    DDLogVerbose(@"+ GM_SyncTest **** getAllLocalMapList ****");

    NSMutableArray *fakeMapList = [NSMutableArray array];

    FakeItem *fakeMap1 = [[FakeItem alloc] init];
    fakeMap1.name = @"@fakeMap1";
    fakeMap1.gmID = @"http://maps.google.com/maps/feeds/maps/212026791974164037226/0004d2e0687a695f7a032"; // GM_LOCAL_ID;
    fakeMap1.etag = @"W/\"C0QHQX0_eyp7I2A9WhNUF0s.\"";  // GM_NO_SYNC_ETAG;
    fakeMap1.markedAsDeletedValue = false;
    fakeMap1.wasSynchronizedValue = true;
    fakeMap1.modifiedSinceLastSyncValue = true;
    [fakeMapList addObject:fakeMap1];

    return fakeMapList;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) localPointListForMap:(id)localMap error:(NSError **)err {

    DDLogVerbose(@"+ GM_SyncTest **** localPointListForMap ****");

    NSMutableArray *fakePointList = [NSMutableArray array];

    FakeItem *fakePoint1 = [[FakeItem alloc] init];
    fakePoint1.name = @"@fakePoint1";
    fakePoint1.gmID = @"http://maps.google.com/maps/feeds/features/212026791974164037226/0004d2e0687a695f7a032/0004d2e06a3a38f3140ee"; // GM_LOCAL_ID;
    fakePoint1.etag = @"W/\"C0UEQns - eCp7I2A9WhNUF0s.\""; // GM_NO_SYNC_ETAG;
    fakePoint1.markedAsDeletedValue = false;
    fakePoint1.wasSynchronizedValue = true;
    fakePoint1.modifiedSinceLastSyncValue = true;
    [fakePointList addObject:fakePoint1];

    return fakePointList;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) gmMapFromLocalMap:(id)localMap error:(NSError **)err {


    FakeItem *fakeMap = (FakeItem *)localMap;
    DDLogVerbose(@"+ GM_SyncTest **** gmMapFromLocalMap [%@] ****", fakeMap.name);

    GMTMap *map = [GMTMap emptyMap];
    map.name = fakeMap.name;
    map.gmID = fakeMap.gmID;
    map.etag = fakeMap.etag;
    map.summary = @"nothing to say - updated 222";


    return map;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) gmPointFromLocalPoint:(id)localPoint error:(NSError **)err {

    FakeItem *fakePoint = (FakeItem *)localPoint;
    DDLogVerbose(@"+ GM_SyncTest **** gmPointFromLocalPoint [%@] ****", fakePoint.name);

    GMTPoint *point = [GMTPoint emptyPoint];
    point.name = fakePoint.name;
    point.gmID = fakePoint.gmID;
    point.etag = fakePoint.etag;
    point.descr = @"nothing to say - updated 444";
    point.iconHREF = GM_DEFAULT_POINT_ICON_HREF;
    point.latitude = 10.0;
    point.longitude = 10.0;

    return point;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalMapFrom:(GMTMap *)remoteMap error:(NSError **)err {

    DDLogVerbose(@"+ GM_SyncTest **** createLocalMapFrom [%@] ****", remoteMap.name);
    DDLogVerbose(@"Map mgID=%@", remoteMap.gmID);
    DDLogVerbose(@"Map etag=%@", remoteMap.etag);
    return @"localMap";
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalMap:(id)localMap error:(NSError **)err {

    DDLogVerbose(@"+ GM_SyncTest **** deleteLocalMap [%@] ****", ((FakeItem *)localMap).name);
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalPointFrom:(GMTPoint *)remotePoint inLocalMap:(id)map error:(NSError **)err {

    DDLogVerbose(@"+ GM_SyncTest **** createLocalPointFrom [%@] ****", remotePoint.name);
    DDLogVerbose(@"Point mgID=%@", remotePoint.gmID);
    DDLogVerbose(@"Point etag=%@", remotePoint.etag);
    return @"localPoint";
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalPoint:(id)localPoint inLocalMap:(id)map error:(NSError **)err {

    DDLogVerbose(@"+ GM_SyncTest **** deleteLocalPoint [%@] ****", ((FakeItem *)localPoint).name);
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalMap:(id)localMap withRemoteMap:(GMTMap *)remoteMap allPointsOK:(BOOL)allPointsOK error:(NSError **)err {

    DDLogVerbose(@"+ GM_SyncTest **** updateLocalMap [%@] ****", ((FakeItem *)localMap).name);
    DDLogVerbose(@"Map mgID=%@", remoteMap.gmID);
    DDLogVerbose(@"Map etag=%@", remoteMap.etag);
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalPoint:(id)localPoint withRemotePoint:(GMTPoint *)remotePoint error:(NSError **)err {

    DDLogVerbose(@"+ GM_SyncTest **** updateLocalPoint [%@] ****", ((FakeItem *)localPoint).name);
    DDLogVerbose(@"Point mgID=%@", remotePoint.gmID);
    DDLogVerbose(@"Point etag=%@", remotePoint.etag);
    return true;
}

@end
