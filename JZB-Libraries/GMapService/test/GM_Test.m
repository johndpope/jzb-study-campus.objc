//
// GMTItemBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//
#define __GM_Test_IMPL_
#import "GM_Test.h"

#import "DDLog.h"
#import "GMapService.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GM_Test ()

@property (nonatomic, strong) GMapService *service;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GM_Test

@synthesize exitOnError = _exitOnError;
@synthesize error = _error;
@synthesize service = _service;


#define GM_TEST_MAP_NAME_BASE @"@gm_test_map"
#define GM_TEST_MAP_DESC_BASE @"@gm_test_map description"


#define GM_TEST_POINT_NAME_BASE @"@gm_test_point"
#define GM_TEST_POINT_DESC_BASE @"@gm_test_point description"


#define GM_TEST_ICON_HREF_1 @"http://maps.gstatic.com/mapfiles/ms2/micons/red-dot.png"
#define GM_TEST_ICON_HREF_2 @"http://maps.gstatic.com/mapfiles/ms2/micons/green-dot.png"



#define _CHECK_TRUE_(is_true, msg) \
    if(!is_true) { \
        self.error = localError; \
        DDLogError(@"**** Error - GM_Test - %@: check was nil", msg); \
        if(self.exitOnError) exit(1); \
        return false; \
    }

#define _CHECK_ITEM_(item, msg) \
    _CHECK_TRUE_((item != nil), msg)

#define _CHECK_ERROR_(localError, msg) \
    if(localError != nil) { \
        self.error = localError; \
        DDLogError(@"**** Error - GM_Test - %@: %@", msg, [localError localizedDescription]); \
        DDLogError(@"Error info: %@", localError); \
        if(self.exitOnError) exit(1); \
        return false; \
    }

#define _CHECK_ERROR_AND_ITEM_(localError, item, msg) \
    if(localError != nil || item == nil) { \
        self.error = localError; \
        DDLogError(@"**** Error - GM_Test - %@: %@", msg, [localError localizedDescription]); \
        DDLogError(@"Error info: %@", localError); \
        if(self.exitOnError) exit(1); \
        return false; \
    }



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GM_Test *) testWithEmail:(NSString *)email password:(NSString *)password exitOnError:(BOOL)exitOnError error:(NSError * __autoreleasing *)err {

    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;

    GMapService *srvc = [GMapService serviceWithEmail:email password:password error:err];
    if(srvc == nil) {
        DDLogError(@"**** Error - GM_Test - testWithEmail - GMapService failed to initialize: %@", [*err localizedDescription]);
        DDLogError(@"Error info: %@", *err);
        if(exitOnError) exit(1); \

        return nil;
    }

    GM_Test *me = [[GM_Test alloc] init];
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

    [self test_batchCreateUpdateDelete_point];

    DDLogVerbose(@"***** GM_Test - DONE! *****");

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) asyncTestAll {

    dispatch_queue_t _serviceQueue = dispatch_queue_create([@"myqueue" UTF8String], NULL);
    dispatch_async(_serviceQueue, ^(void){

                       [self syncTestAll];

                   });

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) test_createUpdateDelete_map {

    DDLogVerbose(@"-----------------------------------------------------------------------------");
    DDLogVerbose(@"GM_Test - test_createUpdateDelete_map\n");
    NSError *localError = nil;
    NSString *NEW_MAP_NAME = [NSString stringWithFormat:@"%@-%ld", GM_TEST_MAP_NAME_BASE, time(0)];


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - create_map - %@\n", NEW_MAP_NAME);
    GMTMap *map = [GMTMap emptyMap];
    map.name = NEW_MAP_NAME;
    map.summary = GM_TEST_MAP_DESC_BASE;
    GMTMap *crtMap = [self.service addMap:map error:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, crtMap, @"test_createUpdateDelete_map#create");
    [self _existMapWithName:NEW_MAP_NAME];



    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - update_map - %@\n", NEW_MAP_NAME);
    NSString *updatedSummary = [NSString stringWithFormat:@"%@-updated", GM_TEST_MAP_DESC_BASE];
    crtMap.summary = updatedSummary;
    GMTMap *updMap = [self.service updateMap:crtMap error:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, updMap, @"test_createUpdateDelete_map#update");
    _CHECK_TRUE_([[self _existMapWithName:NEW_MAP_NAME].summary isEqualToString:updatedSummary], @"test_createUpdateDelete_map#update");


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - delete_map - %@\n", NEW_MAP_NAME);
    [self.service deleteMap:updMap error:&localError];
    _CHECK_ERROR_(localError, @"test_createUpdateDelete_map#delete");
    [self _isGoneMapWithName:NEW_MAP_NAME];


    // todo fue bien
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) test_readAllPoint {

    DDLogVerbose(@"-----------------------------------------------------------------------------");
    DDLogVerbose(@"GM_Test - test_readAllPoint\n");
    NSError *localError = nil;

    NSArray *mapList = [self.service getMapList:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, mapList, @"test_readAllPoint");


    int pointCount = 0;
    for(GMTMap *map in mapList) {

        GMTMap *mapRead = [self.service getMapFromEditURL:map.editLink error:&localError];
        _CHECK_ERROR_AND_ITEM_(localError, mapRead, @"getMapFromEditURL");

        NSArray *pointList = [self.service getPointListFromMap:map error:&localError];
        _CHECK_ERROR_AND_ITEM_(localError, pointList, @"getPointListFromMap");

        pointCount += pointList.count;
        DDLogVerbose(@"GM_Test - test_readAllPoint - count = %u", pointCount);
    }

    // todo fue bien
    return true;

}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) test_createUpdateDelete_point {

    DDLogVerbose(@"-----------------------------------------------------------------------------");
    DDLogVerbose(@"GM_Test - test_createUpdateDelete_point\n");
    NSError *localError = nil;
    NSString *NEW_MAP_NAME = [NSString stringWithFormat:@"%@-%ld", GM_TEST_MAP_NAME_BASE, time(0)];
    NSString *NEW_POINT_NAME = [NSString stringWithFormat:@"%@-%ld", GM_TEST_POINT_NAME_BASE, time(0)];


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - create_map - %@\n", NEW_MAP_NAME);
    GMTMap *map = [GMTMap emptyMap];
    map.name = NEW_MAP_NAME;
    map.summary = GM_TEST_MAP_DESC_BASE;
    GMTMap *crtMap = [self.service addMap:map error:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, crtMap, @"test_createUpdateDelete_point#create_MAP");
    [self _existMapWithName:NEW_MAP_NAME];


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - create_point - %@\n", NEW_POINT_NAME);
    GMTPoint *point = [GMTPoint emptyPoint];
    point.name = NEW_POINT_NAME;
    point.descr = GM_TEST_POINT_DESC_BASE;
    GMTPoint *crtPoint = [self.service addPoint:point inMap:crtMap error:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, crtPoint, @"test_createUpdateDelete_point#create");
    [self _existPointWithName:NEW_POINT_NAME inMap:crtMap];


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - update_point - %@\n", NEW_POINT_NAME);
    NSString *updatedDescr = [NSString stringWithFormat:@"%@-updated", GM_TEST_POINT_DESC_BASE];
    crtPoint.descr = updatedDescr;
    GMTPoint *updPoint = [self.service updatePoint:crtPoint inMap:crtMap error:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, updPoint, @"test_createUpdateDelete_point#update");
    _CHECK_TRUE_([[self _existPointWithName:NEW_POINT_NAME inMap:crtMap].descr isEqualToString:updatedDescr], @"test_createUpdateDelete_point#update");


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - delete_point - %@\n", NEW_POINT_NAME);
    [self.service deletePoint:updPoint inMap:crtMap error:&localError];
    _CHECK_ERROR_(localError, @"test_createUpdateDelete_point#delete");
    [self _isGonePointWithName:NEW_POINT_NAME inMap:crtMap];


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - delete_map - %@\n", NEW_MAP_NAME);
    [self.service deleteMap:crtMap error:&localError];
    _CHECK_ERROR_(localError, @"test_createUpdateDelete_point#delete_MAP");
    [self _isGoneMapWithName:NEW_MAP_NAME];


    // todo fue bien
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) test_batchCreateUpdateDelete_point {

    DDLogVerbose(@"-----------------------------------------------------------------------------");
    DDLogVerbose(@"GM_Test - test_batchCreateUpdateDelete_point\n");
    NSError *localError = nil;
    NSString *NEW_MAP_NAME = [NSString stringWithFormat:@"%@-%ld", GM_TEST_MAP_NAME_BASE, time(0)];
    NSString *NEW_POINT_NAME_X = [NSString stringWithFormat:@"%@-X-%ld", GM_TEST_POINT_NAME_BASE, time(0)];
    NSString *NEW_POINT_NAME_Y = [NSString stringWithFormat:@"%@-Y-%ld", GM_TEST_POINT_NAME_BASE, time(0)];
    NSString *NEW_POINT_NAME_Z = [NSString stringWithFormat:@"%@-Z-%ld", GM_TEST_POINT_NAME_BASE, time(0)];


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - create_map - %@\n", NEW_MAP_NAME);
    GMTMap *map = [GMTMap emptyMap];
    map.name = NEW_MAP_NAME;
    map.summary = GM_TEST_MAP_DESC_BASE;
    GMTMap *crtMap = [self.service addMap:map error:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, crtMap, @"test_batchCreateUpdateDelete_point#create_MAP");
    [self _existMapWithName:NEW_MAP_NAME];


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - create_point X - %@\n", NEW_POINT_NAME_X);
    GMTPoint *pointX = [GMTPoint emptyPoint];
    pointX.name = NEW_POINT_NAME_X;
    pointX.descr = GM_TEST_POINT_DESC_BASE;
    GMTPoint *crtPointX = [self.service addPoint:pointX inMap:crtMap error:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, crtPointX, @"test_batchCreateUpdateDelete_point#create");
    [self _existPointWithName:NEW_POINT_NAME_X inMap:crtMap];


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - create_point Y - %@\n", NEW_POINT_NAME_Y);
    GMTPoint *pointY = [GMTPoint emptyPoint];
    pointY.name = NEW_POINT_NAME_Y;
    pointY.descr = GM_TEST_POINT_DESC_BASE;
    GMTPoint *crtPointY = [self.service addPoint:pointY inMap:crtMap error:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, crtPointY, @"test_batchCreateUpdateDelete_point#create");
    [self _existPointWithName:NEW_POINT_NAME_Y inMap:crtMap];


    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - batch call - %@\n", NEW_POINT_NAME_Y);
    GMTPoint *pointZ = [GMTPoint emptyPoint];
    pointZ.name = NEW_POINT_NAME_Z;
    pointZ.descr = GM_TEST_POINT_DESC_BASE;
    NSString *updatedDescr = [NSString stringWithFormat:@"%@-updated", GM_TEST_POINT_DESC_BASE];
    crtPointY.descr = updatedDescr;

    NSArray *batchCmds = [NSArray arrayWithObjects:
                          [GMTBatchCmd batchCmd:BATCH_CMD_DELETE withItem:crtPointX],
                          [GMTBatchCmd batchCmd:BATCH_CMD_UPDATE withItem:crtPointY],
                          [GMTBatchCmd batchCmd:BATCH_CMD_INSERT withItem:pointZ],
                          nil];

    NSMutableArray *allErrors = [NSMutableArray array];
    BOOL rc = [self.service processBatchCmds:batchCmds inMap:crtMap allErrors:allErrors checkCancelBlock:nil];
    _CHECK_TRUE_(rc, @"test_batchCreateUpdateDelete_point#processBatchCmds");

    [self _isGonePointWithName:NEW_POINT_NAME_X inMap:crtMap];
    _CHECK_TRUE_([[self _existPointWithName:NEW_POINT_NAME_Y inMap:crtMap].descr isEqualToString:updatedDescr], @"test_batchCreateUpdateDelete_point#update");
    [self _existPointWithName:NEW_POINT_NAME_Z inMap:crtMap];



    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------");
    DDLogVerbose(@"** GM_Test - delete_map - %@\n", NEW_MAP_NAME);
    [self.service deleteMap:crtMap error:&localError];
    _CHECK_ERROR_(localError, @"test_batchCreateUpdateDelete_point#delete_MAP");
    [self _isGoneMapWithName:NEW_MAP_NAME];


    // todo fue bien
    return true;
}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) _existMapWithName:(NSString *)name {

    NSError *localError = nil;
    NSArray *mapList = [self.service getMapList:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, mapList, @"test_existMapWithName");

    GMTMap *foundMap = nil;
    for(GMTMap *map in mapList) {
        if([map.name isEqualToString:name]) {
            foundMap = map;
            break;
        }
    }
    _CHECK_ITEM_(foundMap, @"test_existMapWithName");

    return foundMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) _isGoneMapWithName:(NSString *)name {

    NSError *localError = nil;
    NSArray *mapList = [self.service getMapList:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, mapList, @"test_isGoneMapWithName");

    GMTMap *foundMap = nil;
    for(GMTMap *map in mapList) {
        if([map.name isEqualToString:name]) {
            foundMap = map;
            break;
        }
    }
    _CHECK_TRUE_((foundMap == nil), @"test_isGoneMapWithName");

    return foundMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) _existPointWithName:(NSString *)name inMap:(GMTMap *)map {

    NSError *localError = nil;

    NSArray *pointList = [self.service getPointListFromMap:map error:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, pointList, @"_existPointWithName");

    GMTPoint *foundPoint = nil;
    for(GMTPoint *point in pointList) {
        if([point.name isEqualToString:name]) {
            foundPoint = point;
            break;
        }
    }
    _CHECK_ITEM_(foundPoint, @"test_existPointWithName");

    return foundPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) _isGonePointWithName:(NSString *)name inMap:(GMTMap *)map {

    NSError *localError = nil;

    NSArray *pointList = [self.service getPointListFromMap:map error:&localError];
    _CHECK_ERROR_AND_ITEM_(localError, pointList, @"_existPointWithName");

    GMTPoint *foundPoint = nil;
    for(GMTPoint *point in pointList) {
        if([point.name isEqualToString:name]) {
            foundPoint = point;
            break;
        }
    }

    _CHECK_TRUE_((foundPoint == nil), @"test_isGoneMapWithName");

    return foundPoint;
}

@end
