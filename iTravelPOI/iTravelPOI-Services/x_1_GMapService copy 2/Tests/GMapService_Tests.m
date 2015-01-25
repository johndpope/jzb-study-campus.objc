//
//  GMapService_Tests.m
//  iTravelPOI-MacTests
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Cypher.h"
#import "GMapService.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Tests private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------
#define UPDATE_POINT_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/yellow-dot.png"

static GMapService *gmapService = nil;


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


// ---------------------------------------------------------------------------------------------------------------------
- (void)setUp {
    
    [super setUp];
    DDLogVerbose(@"\n\n\n=== [Test start]  ==============================================================================");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)tearDown {
    
    DDLogVerbose(@"\n\n--- [Test end]  --------------------------------------------------------------------------------\n\n");
    [super tearDown];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_00_Login {
    
    [self __GMap_Login];

}



// =====================================================================================================================
#pragma mark -
#pragma mark MAP - TEST methods
// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_01_GetMapList {
    
    if(![self __GMap_Login]) return;
    DDLogVerbose(@"*** >> Retrieving map list\n\n");
    
    NSArray *mapList = [self __GMap_GetMapList];

    for(GMTMap *map in mapList) {
        [self __Assert_GMTMap_Remote_Instance:map];
        NSLog(@"map name = %@", map.name);
        NSLog(@"map editLink = %@\n", map.editLink);
    }
    
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_02__GetMapFromEditURL {
    
    if(![self __GMap_Login]) return;
    DDLogVerbose(@"*** >> Retrieving map from Edit URL\n\n");

    
    NSString *url=@"http://maps.google.com/maps/feeds/maps/212026791974164037226/full/0004fe0ed731b148b3ffd";
    
    NSError *error = nil;
    GMTMap *map = [gmapService getMapFromEditURL:url error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"getMapFromEditURL", error);

    [self __Assert_GMTMap_Remote_Instance:map];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_03__MapCRUD {
    
    if(![self __GMap_Login]) return;
    DDLogVerbose(@"*** >> CRUD MAP functionality \n\n");
    
    
    //----------- CREATE-ADD MAP ---------------------------------------------
    GMTMap *addedMap = [self __GMap_AddNewRemoteMapWithName:@"@crud-map create" summary:@"crud-map create"];
    
    
    //----------- UPDATE MAP -------------------------------------------------
    GMTMap *updatedMap = [self __GMap_UpdateRemoteMap:addedMap withName:@"@crud-map update" summay:@"crud-map update"];
    
    
    //----------- DELETE MAP -------------------------------------------------
    [self __GMap_DeleteRemoteMap:updatedMap];

}





// =====================================================================================================================
#pragma mark -
#pragma mark POINT - TEST methods
// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_04__PointCRUD {
    
    if(![self __GMap_Login]) return;
    DDLogVerbose(@"*** >> CRUD POINT functionality \n\n");
    
    

    
    //----------- CREATE-ADD MAP ---------------------------------------------
    GMTMap *ownerMap = [self __GMap_AddNewRemoteMapWithName:@"@crud-point-map create" summary:@"crud-point-map create"];

    
    
    
    
    //----------- CREATE-ADD POINT --------------------------------------------
    GMTPoint *addedPoint1 = [self __GMap_AddNewRemotePointWithName:@"@crud-point create 1" descr:@"crud-point create 1" inMap:ownerMap];
    GMTPoint *addedPoint2 = [self __GMap_AddNewRemotePointWithName:@"@crud-point create 2" descr:@"crud-point create 2" inMap:ownerMap];
    GMTPoint *addedPoint3 = [self __GMap_AddNewRemotePointWithName:@"@crud-point create 3" descr:@"crud-point create 3" inMap:ownerMap];
    
    
    //----------- UPDATE POINT ------------------------------------------------
    GMTPoint *updatedPoint1 = [self __GMap_UpdateRemotePoint:addedPoint1 withName:@"crud-point update 1" descr:@"crud-point update 1" inMap:ownerMap];
    GMTPoint *updatedPoint2 = [self __GMap_UpdateRemotePoint:addedPoint2 withName:@"crud-point update 2" descr:@"crud-point update 2" inMap:ownerMap];
    GMTPoint *updatedPoint3 = [self __GMap_UpdateRemotePoint:addedPoint3 withName:@"crud-point update 3" descr:@"crud-point update 3" inMap:ownerMap];
    
    
    //----------- LIST POINTS 3 -----------------------------------------------
    NSArray *pointList1 = [self __GMap_GetPointListFromMap:ownerMap];
    XCTAssertTrue(pointList1.count==3, @"\n\nShoud be 3 points in the map");
    
    
    //----------- DELETE POINT ------------------------------------------------
    [self __GMap_DeleteRemotePoint:updatedPoint1 inMap:ownerMap];
    [self __GMap_DeleteRemotePoint:updatedPoint2 inMap:ownerMap];
    [self __GMap_DeleteRemotePoint:updatedPoint3 inMap:ownerMap];

    
    //----------- LIST POINTS 0 -----------------------------------------------
    NSArray *pointList2 = [self __GMap_GetPointListFromMap:ownerMap];
    XCTAssertTrue(pointList2.count==0, @"\n\nShoud be 0 points in the map");
    
    
    
    
    //----------- DELETE MAP -------------------------------------------------
    [self __GMap_DeleteRemoteMap:ownerMap];
    
}






// =====================================================================================================================
#pragma mark -
#pragma mark POLYLINE - TEST methods
// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_05__PolyLineCRUD {
    
    if(![self __GMap_Login]) return;
    DDLogVerbose(@"*** >> CRUD POLYLINE functionality \n\n");
    
    
    
    
    //----------- CREATE-ADD MAP ---------------------------------------------
    GMTMap *ownerMap = [self __GMap_AddNewRemoteMapWithName:@"@crud-polyline-map create" summary:@"crud-polyline-map create"];
    
    
    
    
    
    //----------- CREATE-ADD POLYLINE -----------------------------------------
    GMTPolyLine *addedPolyLine1 = [self __GMap_AddNewRemotePolyLineWithName:@"@crud-polyline create 1" descr:@"crud-polyline create 1" inMap:ownerMap];
    GMTPolyLine *addedPolyLine2 = [self __GMap_AddNewRemotePolyLineWithName:@"@crud-polyline create 2" descr:@"crud-polyline create 2" inMap:ownerMap];
    GMTPolyLine *addedPolyLine3 = [self __GMap_AddNewRemotePolyLineWithName:@"@crud-polyline create 3" descr:@"crud-polyline create 3" inMap:ownerMap];
    
    
    //----------- UPDATE POLYLINE ---------------------------------------------
    GMTPolyLine *updatedPolyLine1 = [self __GMap_UpdateRemotePolyLine:addedPolyLine1 withName:@"crud-polyline update 1" descr:@"crud-polyline update 1" inMap:ownerMap];
    GMTPolyLine *updatedPolyLine2 = [self __GMap_UpdateRemotePolyLine:addedPolyLine2 withName:@"crud-polyline update 2" descr:@"crud-polyline update 2" inMap:ownerMap];
    GMTPolyLine *updatedPolyLine3 = [self __GMap_UpdateRemotePolyLine:addedPolyLine3 withName:@"crud-polyline update 3" descr:@"crud-polyline update 3" inMap:ownerMap];
    
    
    //----------- LIST POLYLINES 3 --------------------------------------------
    NSArray *polylineList1 = [self __GMap_GetPolyLineListFromMap:ownerMap];
    XCTAssertTrue(polylineList1.count==3, @"\n\nShoud be 3 polylines in the map");
    
    
    //----------- DELETE POLYLINE ----------------------------------------------
    [self __GMap_DeleteRemotePolyLine:updatedPolyLine1 inMap:ownerMap];
    [self __GMap_DeleteRemotePolyLine:updatedPolyLine2 inMap:ownerMap];
    [self __GMap_DeleteRemotePolyLine:updatedPolyLine3 inMap:ownerMap];
    
    
    //----------- LIST POLYLINES 0 ---------------------------------------------
    NSArray *polylineList2 = [self __GMap_GetPolyLineListFromMap:ownerMap];
    XCTAssertTrue(polylineList2.count==0, @"\n\nShoud be 0 polylines in the map");
    
    
    
    
    //----------- DELETE MAP -------------------------------------------------
    [self __GMap_DeleteRemoteMap:ownerMap];
    
}






// =====================================================================================================================
#pragma mark -
#pragma mark POINT-BATCH - TEST methods
// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_06__PointBatch {

    
    
    if(![self __GMap_Login]) return;
    DDLogVerbose(@"*** >> CRUD POINT functionality \n\n");
    
    
    
    
    //----------- CREATE-ADD MAP ---------------------------------------------
    GMTMap *ownerMap = [self __GMap_AddNewRemoteMapWithName:@"@crud-point-map create" summary:@"crud-point-map create"];
    
    
    //----------- PREPATE POINTS ---------------------------------------------
    GMTPoint *pointToUpdate1 = [self __GMap_AddNewRemotePointWithName:@"@batch-point update 1" descr:@"batch-point update 1" inMap:ownerMap];
    pointToUpdate1.name = @"@batch-point already updated 1";
    pointToUpdate1.latitude = -12.345;
    pointToUpdate1.longitude = 54.321;
    pointToUpdate1.iconHREF = UPDATE_POINT_ICON_HREF;
    
    GMTPoint *pointToUpdate2 = [self __GMap_AddNewRemotePointWithName:@"@batch-point update 2" descr:@"batch-point update 2" inMap:ownerMap];
    pointToUpdate1.name = @"@batch-point already updated 2";
    pointToUpdate2.latitude = -12.345;
    pointToUpdate2.longitude = 54.321;
    pointToUpdate2.iconHREF = UPDATE_POINT_ICON_HREF;
    
    GMTPoint *pointToDelete1 = [self __GMap_AddNewRemotePointWithName:@"@batch-point delete 1" descr:@"batch-point delete 1" inMap:ownerMap];
    GMTPoint *pointToDelete2 = [self __GMap_AddNewRemotePointWithName:@"@batch-point delete 2" descr:@"batch-point delete 2" inMap:ownerMap];
    GMTPoint *pointToInsert1 = [GMTPoint emptyPointWithName:@"@batch-point create 1"];
    GMTPoint *pointToInsert2 = [GMTPoint emptyPointWithName:@"@batch-point create 2"];

    GMTPoint *pointToBad1 = [self __GMap_AddNewRemotePointWithName:@"@batch-point delete bad 1" descr:@"batch-point delete bad 1" inMap:ownerMap];
    [self __GMap_DeleteRemotePoint:pointToBad1 inMap:ownerMap];

    GMTPoint *pointToBad2 = [self __GMap_AddNewRemotePointWithName:@"@batch-point update bad 2" descr:@"batch-point update bad 2" inMap:ownerMap];
    [self __GMap_DeleteRemotePoint:pointToBad2 inMap:ownerMap];
    
    
    //----------- PREPATE POLYLINES -------------------------------------------
    GMTPolyLine *polylineToUpdate1 = [self __GMap_AddNewRemotePolyLineWithName:@"@batch-polyline update 1" descr:@"batch-polyline update 1" inMap:ownerMap];
    polylineToUpdate1.name = @"@batch-polyline already updated 1";
    polylineToUpdate1.width = 2;
    [polylineToUpdate1 addCoordWithLatitude:28.28 andLongitude:56.56];

    GMTPolyLine *polylineToUpdate2 = [self __GMap_AddNewRemotePolyLineWithName:@"@batch-polyline update 2" descr:@"batch-polyline update 2" inMap:ownerMap];
    polylineToUpdate2.name = @"@batch-polyline already updated 2";
    polylineToUpdate2.width = 4;
    [polylineToUpdate2 addCoordWithLatitude:8.8 andLongitude:6.6];


    GMTPolyLine *polylineToDelete1 = [self __GMap_AddNewRemotePolyLineWithName:@"@batch-polyline delete 1" descr:@"batch-polyline delete 1" inMap:ownerMap];
    GMTPolyLine *polylineToDelete2 = [self __GMap_AddNewRemotePolyLineWithName:@"@batch-polyline delete 2" descr:@"batch-polyline delete 2" inMap:ownerMap];

    GMTPolyLine *polylineToInsert1 = [GMTPolyLine emptyPolyLineWithName:@"@batch-polyline create 1"];
    [polylineToInsert1 addCoordWithLatitude:18.18 andLongitude:16.16];
    [polylineToInsert1 addCoordWithLatitude:28.28 andLongitude:56.56];
    GMTPolyLine *polylineToInsert2 = [GMTPolyLine emptyPolyLineWithName:@"@batch-polyline create 2"];
    [polylineToInsert2 addCoordWithLatitude:38.38 andLongitude:26.26];
    [polylineToInsert2 addCoordWithLatitude:58.58 andLongitude:66.66];

    
    
    //----------- PREPATE CMDS ------------------------------------------------
    GMTBatchCmd *cmdupdatePlacemark1 = [GMTBatchCmd batchCmd:BATCH_CMD_UPDATE withPlacemark:pointToUpdate1];
    GMTBatchCmd *cmdupdatePlacemark2 = [GMTBatchCmd batchCmd:BATCH_CMD_UPDATE withPlacemark:pointToUpdate2];
    GMTBatchCmd *cmddeletePlacemark1 = [GMTBatchCmd batchCmd:BATCH_CMD_DELETE withPlacemark:pointToDelete1];
    GMTBatchCmd *cmddeletePlacemark2 = [GMTBatchCmd batchCmd:BATCH_CMD_DELETE withPlacemark:pointToDelete2];
    GMTBatchCmd *cmdInsertPoint1 = [GMTBatchCmd batchCmd:BATCH_CMD_ADD withPlacemark:pointToInsert1];
    GMTBatchCmd *cmdInsertPoint2 = [GMTBatchCmd batchCmd:BATCH_CMD_ADD withPlacemark:pointToInsert2];

    GMTBatchCmd *cmdUpdatePolyLine1 = [GMTBatchCmd batchCmd:BATCH_CMD_UPDATE withPlacemark:polylineToUpdate1];
    GMTBatchCmd *cmdUpdatePolyLine2 = [GMTBatchCmd batchCmd:BATCH_CMD_UPDATE withPlacemark:polylineToUpdate2];
    GMTBatchCmd *cmdDeletePolyLine1 = [GMTBatchCmd batchCmd:BATCH_CMD_DELETE withPlacemark:polylineToDelete1];
    GMTBatchCmd *cmdDeletePolyLine2 = [GMTBatchCmd batchCmd:BATCH_CMD_DELETE withPlacemark:polylineToDelete2];
    GMTBatchCmd *cmdInsertPolyLine1 = [GMTBatchCmd batchCmd:BATCH_CMD_ADD withPlacemark:polylineToInsert1];
    GMTBatchCmd *cmdInsertPolyLine2 = [GMTBatchCmd batchCmd:BATCH_CMD_ADD withPlacemark:polylineToInsert2];

    // Try to delete something that doesn't exist is not considered as an error
    GMTBatchCmd *cmdDeleteBad1 = [GMTBatchCmd batchCmd:BATCH_CMD_DELETE withPlacemark:pointToBad1];
    GMTBatchCmd *cmdUpdateBad2 = [GMTBatchCmd batchCmd:BATCH_CMD_UPDATE withPlacemark:pointToBad2];
    

    //----------- EXECUTE CMDS ------------------------------------------------
    NSArray *cmds = @[cmdupdatePlacemark1,cmdupdatePlacemark2,cmddeletePlacemark1,cmddeletePlacemark2,cmdInsertPoint1,cmdInsertPoint2,
                      cmdUpdatePolyLine1,cmdUpdatePolyLine2,cmdDeletePolyLine1,cmdDeletePolyLine2,cmdInsertPolyLine1,cmdInsertPolyLine2,
                      cmdDeleteBad1,cmdUpdateBad2];
    
    NSError *error = nil;
    BOOL rc = [gmapService processBatchCmds:cmds inMap:ownerMap error:&error checkCancelBlock:^BOOL{
        return NO;
    }];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"processBatchCmds", error);
    XCTAssertTrue(rc, "\n\nError calling GMapService[%@]\n\n", @"processBatchCmds");
    
    

    
    //----------- CHECK CMDS --------------------------------------------------
    XCTAssertTrue(cmdupdatePlacemark1.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    [self __Assert_UpdatedPoint:(GMTPoint *)cmdupdatePlacemark1.placemark withPoint:(GMTPoint *)cmdupdatePlacemark1.resultPlacemark];
    
    XCTAssertTrue(cmdupdatePlacemark2.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    [self __Assert_UpdatedPoint:(GMTPoint *)cmdupdatePlacemark2.placemark withPoint:(GMTPoint *)cmdupdatePlacemark2.resultPlacemark];

    XCTAssertTrue(cmddeletePlacemark1.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");

    XCTAssertTrue(cmddeletePlacemark2.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");

    XCTAssertTrue(cmdInsertPoint1.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    [self __Assert_AddedPoint:(GMTPoint *)cmdInsertPoint1.placemark withPoint:(GMTPoint *)cmdInsertPoint1.resultPlacemark];
    
    XCTAssertTrue(cmdInsertPoint2.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    [self __Assert_AddedPoint:(GMTPoint *)cmdInsertPoint2.placemark withPoint:(GMTPoint *)cmdInsertPoint2.resultPlacemark];

    
    
    XCTAssertTrue(cmdUpdatePolyLine1.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    [self __Assert_UpdatedPolyLine:(GMTPolyLine *)cmdUpdatePolyLine1.placemark withPolyLine:(GMTPolyLine *)cmdUpdatePolyLine1.resultPlacemark];
    
    XCTAssertTrue(cmdUpdatePolyLine2.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    [self __Assert_UpdatedPolyLine:(GMTPolyLine *)cmdUpdatePolyLine2.placemark withPolyLine:(GMTPolyLine *)cmdUpdatePolyLine2.resultPlacemark];
    
    XCTAssertTrue(cmdDeletePolyLine1.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    
    XCTAssertTrue(cmdDeletePolyLine2.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    
    XCTAssertTrue(cmdInsertPolyLine1.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    [self __Assert_AddedPolyLine:(GMTPolyLine *)cmdInsertPolyLine1.placemark withPolyLine:(GMTPolyLine *)cmdInsertPolyLine1.resultPlacemark];
    
    XCTAssertTrue(cmdInsertPoint2.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    [self __Assert_AddedPolyLine:(GMTPolyLine *)cmdInsertPolyLine2.placemark withPolyLine:(GMTPolyLine *)cmdInsertPolyLine2.resultPlacemark];

    
    
    XCTAssertTrue(cmdDeleteBad1.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC should be OK\n\n");
    XCTAssertFalse(cmdUpdateBad2.resultCode==BATCH_RC_OK, @"\n\nBatch Command RC shouldn't be OK\n\n");

    
    
    //----------- LIST POINTS 0 -----------------------------------------------
    NSArray *pointList2 = [self __GMap_GetPointListFromMap:ownerMap];
    XCTAssertTrue(pointList2.count==4, @"\n\nShoud be 4 points in the map");

    
    //----------- LIST POINTS 0 -----------------------------------------------
    NSArray *polylineList2 = [self __GMap_GetPolyLineListFromMap:ownerMap];
    XCTAssertTrue(polylineList2.count==4, @"\n\nShoud be 4 polylines in the map");

    
    
    
    //----------- DELETE MAP -------------------------------------------------
    [self __GMap_DeleteRemoteMap:ownerMap];

}




// =====================================================================================================================
#pragma mark -
#pragma mark DUPLICATE-CONTENT - TEST methods
// ---------------------------------------------------------------------------------------------------------------------
- (void)test_GMap_07__DuplicateContent {
    
    
    
    if(![self __GMap_Login]) return;
    DDLogVerbose(@"*** >> DUPLICATE CONTENT functionality \n\n");
    
/***
    NSString *mapURL = @"http://maps.google.com/maps/feeds/maps/212026791974164037226/full/0004fac2f4a9dbdfa65eb";
    NSError *error = nil;
    GMTMap *map1 = [gmapService getMapFromEditURL:mapURL error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"getMapFromEditURL", error);
    [self __Assert_GMTMap_Remote_Instance:map1];
    
    [self __GMap_DuplicateContentForMap:map1];
***/
    
    NSArray *mapList = [self __GMap_GetMapList];
    for(GMTMap *map in mapList) {
        [self __GMap_DuplicateContentForMap:map];
    }
/***/
    
}




// =====================================================================================================================
#pragma mark -
#pragma mark MAP - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_AddedMap:(GMTMap *)addedMap withMap:(GMTMap *)map {
    XCTAssertEqualObjects(map.name, addedMap.name, @"\n\nMap.name should remain unchanged after adding to GMap\n\n");
    XCTAssertEqualObjects(map.summary, addedMap.summary, @"\n\nMap.summary should remain unchanged after adding to GMap\n\n");
    XCTAssertNotEqualObjects(map.gID, addedMap.gID, @"\n\nMap.gID should remain unchanged after adding to GMap\n\n");
    XCTAssertNotEqualObjects(map.etag, addedMap.etag, @"\n\nMap.etag should be changed after adding to GMap\n\n");
    XCTAssertNotEqualObjects(map.updated_Date, addedMap.updated_Date, @"\n\nMap.etag should be changed after adding to GMap\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __GMap_DuplicateContentForMap:(GMTMap *)map {
    
    NSError *error;
    
    // ---------- Evita duplicar un mapa ya duplicado -----------------------------
    if([map.name hasPrefix:@"@TEST-"]) return;
    
    
    // ---------- Obtiene los puntos actuales del mapa ----------------------------
    NSArray *pointList =[self __GMap_GetPointListFromMap:map];
    
    
    // ---------- Duplica el mapa -------------------------------------------------
    [map setLocalNoSyncValues];
    map.name = [NSString stringWithFormat:@"@TEST-%@", map.name];
    
    error = nil;
    GMTMap *addedMap = [gmapService addMap:map error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"addMap", error);
    
    error = nil;
    GMTMap *retrievedMap = [gmapService getMapFromEditURL:addedMap.editLink error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"getMapFromEditURL", error);
    
    [self __Assert_GMTMap_Remote_Instance:retrievedMap];
    [self __Assert_AddedMap:retrievedMap withMap:map];
    
    
    
    // ---------- Duplica los puntos del mapa --------------------------------------
    NSMutableArray *batchCmds = [NSMutableArray array];
    
    for(GMTPoint *point in pointList) {
        
        // Evita duplicar los elementos de tipo PolyLine
        if([point isKindOfClass:GMTPolyLine.class])
            continue;
        
        [point setLocalNoSyncValues];
        
        GMTBatchCmd *cmd = [GMTBatchCmd batchCmd:BATCH_CMD_ADD withPlacemark:point];
        [batchCmds addObject:cmd];
    }
    
    error = nil;
    BOOL rc = [gmapService processBatchCmds:batchCmds inMap:retrievedMap error:&error checkCancelBlock:^BOOL{
        return NO;
    }];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"processBatchCmds", error);
    
    if(rc==YES && !error) {
        
        for(GMTBatchCmd *cmd in batchCmds) {
            [self __Assert_GMTPoint_Remote_Instance:(GMTPoint *)cmd.resultPlacemark];
            [self __Assert_AddedPoint:(GMTPoint *)cmd.resultPlacemark withPoint:(GMTPoint *)cmd.placemark];
        }
    }
    
    
    
    
    //----------- Borra el mapa duplicado ------------------------------------------
    [self __GMap_DeleteRemoteMap:retrievedMap];
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *)__GMap_AddNewRemoteMapWithName:(NSString *)name summary:(NSString *)summary {
    
    GMTMap *mapToAdd = [GMTMap emptyMapWithName:name];
    mapToAdd.summary = summary;
    [self __Assert_GMTMap_Local_Instance:mapToAdd];
    XCTAssertEqualObjects(mapToAdd.name, name, @"\n\nMap.name should be as setted\n\n");
    XCTAssertEqualObjects(mapToAdd.summary, summary, @"\n\nMap.summary should be as setted\n\n");
    
    NSError *error = nil;
    GMTMap *addedMap = [gmapService addMap:mapToAdd error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"addMap", error);
    
    [self __Assert_GMTMap_Remote_Instance:addedMap];
    [self __Assert_AddedMap:addedMap withMap:mapToAdd];
    
    GMTMap *mapInList = [self __GMap_findMapInMapList:addedMap.gID];
    XCTAssertNotNil(mapInList, @"\n\nMap should be present in GMap after adding it [getMapList]\n\n");
    [self __GMap_CompareRemoteMap:addedMap withMap:mapInList];

    return addedMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *)__GMap_UpdateRemoteMap:(GMTMap *)map withName:(NSString *)updName summay:(NSString *)updSummay {
    
    map.name = updName;
    map.summary = updSummay;
    XCTAssertEqualObjects(map.name, updName, "\n\nMap.name should be changed to the new one assigned\n\n");
    XCTAssertEqualObjects(map.summary, updSummay, "\n\nMap.name should be changed to the new one assigned\n\n");
    
    NSError *error = nil;
    GMTMap *updatedMap = [gmapService updateMap:map error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"updateMap", error);
    
    [self __Assert_GMTMap_Remote_Instance:updatedMap];
    XCTAssertEqualObjects(map.name, updatedMap.name, @"\n\nMap.name should be changed after updating to GMap\n\n");
    XCTAssertEqualObjects(map.summary, updatedMap.summary, @"\n\nMap.summary should changed after updating to GMap\n\n");
    XCTAssertEqualObjects(map.gID, updatedMap.gID, @"\n\nMap.gID should remain unchanged after updating to GMap\n\n");
    XCTAssertNotEqualObjects(map.etag, updatedMap.etag, @"\n\nMap.etag should changed after updating to GMap\n\n");
    XCTAssertNotEqualObjects(map.updated_Date, updatedMap.updated_Date, @"\n\nMap.etag should changed after updating to GMap\n\n");

    
    GMTMap *mapInList = [self __GMap_findMapInMapList:updatedMap.gID];
    XCTAssertNotNil(mapInList, @"\n\nMap should be present in GMap after updating it [getMapList]\n\n");
    [self __GMap_CompareRemoteMap:updatedMap withMap:mapInList];
    
    return updatedMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__GMap_DeleteRemoteMap:(GMTMap *)map {
    
    NSError *error = nil;

    NSString *prevEditLink = map.editLink;
    NSString *prevGID = map.gID;
    
    BOOL ok = [gmapService deleteMap:map error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"deleteMap", error);
    
    XCTAssertTrue(ok, @"\n\nMap was not successfuly deleted \n\n");
    
    GMTMap *deletedMap = [gmapService getMapFromEditURL:prevEditLink error:&error];
    XCTAssertNotNil(error, "\n\nThere should be and error calling GMapService[%@] for a deleted map\n\n", @"getMapFromEditURL");
    XCTAssertNil(deletedMap, "\n\nMap should not be present in GMap after deleting it [getMapFromEditURL]\n\n");
    
    GMTMap *mapInList = [self __GMap_findMapInMapList:prevGID];
    XCTAssertNil(mapInList, @"\n\nMap should not be present in GMap after deleting it [getMapList]\n\n");

}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) __GMap_findMapInMapList:(NSString *)mapGID {
    
    NSArray *mapList = [self __GMap_GetMapList];
    for(GMTMap *map in mapList) {
        if([map.gID isEqualToString:mapGID]) {
            return  map;
        }
    }
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *)__GMap_GetMapList {
    
    NSError *error = nil;
    NSArray *mapList = [gmapService getMapList:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"getMapList", error);
    
    XCTAssertTrue(mapList.count>0, @"\n\nMap List shouldn't be empty\n\n");
    
    return mapList;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_GMTMap_Local_Instance:(GMTMap *)map {
    
    XCTAssertNotNil(map, @"\n\nMap instance must not be nil\n\n");
    
    XCTAssertTrue(map.name.length>0, @"\n\nLocal Map.name shouldn't be nil or empty\n\n");
    XCTAssertTrue(map.hasNoSyncLocalGID, @"\n\nLocal Map.gID should be equal to LOCAL-ID\n\n");
    XCTAssertTrue(map.hasNoSyncLocalETag, @"\n\nLocal Map.etag should be equal to LOCAL-ETAG\n\n");
    XCTAssertNil(map.editLink, @"\n\nLocal Map.editLink should be nil\n\n");
    XCTAssertNil(map.featuresURL, @"\n\nLocal Map.featuresURL should be nil\n\n");
    XCTAssertNotNil(map.published_Date, @"\n\nLocal Map.published_Date shouldn't be nil\n\n");
    XCTAssertNotNil(map.updated_Date, @"\n\nLocal Map.updated_Date shouldn't be nil\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_GMTMap_Remote_Instance:(GMTMap *)map {
    
    XCTAssertNotNil(map, @"\n\nMap instance must not be nil\n\n");
    
    XCTAssertTrue(map.name.length>0, @"\n\nRemote Map.name shouldn't be nil or empty\n\n");
    XCTAssertFalse(map.hasNoSyncLocalGID, @"\n\nRemote Map.gID shouldn't be equal to LOCAL-ID\n\n");
    XCTAssertNotNil(map.gID, @"\n\nRemote Map.gID shouldn't be nil\n\n");
    XCTAssertFalse(map.hasNoSyncLocalETag, @"\n\nRemote Map.etag shouldn't be equal to LOCAL-ETAG\n\n");
    XCTAssertNotNil(map.etag, @"\n\nRemote Map.etag shouldn't be nil\n\n");
    XCTAssertNotNil(map.editLink, @"\n\nRemote Map.editLink shouldn't be nil\n\n");
    XCTAssertNotNil(map.featuresURL, @"\n\nRemote Map.featuresURL shouldn't be nil\n\n");
    XCTAssertNotNil(map.published_Date, @"\n\nRemote Map.published_Date shouldn't be nil\n\n");
    XCTAssertNotNil(map.updated_Date, @"\n\nRemote Map.updated_Date shouldn't be nil\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__GMap_CompareRemoteMap:(GMTMap *)mapSrc withMap:(GMTMap *)mapDst {
    
    XCTAssertEqualObjects(mapSrc.name, mapDst.name, @"\n\nMap.name should be the same in both maps\n\n");
    XCTAssertEqualObjects(mapSrc.summary, mapDst.summary, @"\n\nMap.summary should be the same in both maps\n\n");
    XCTAssertEqualObjects(mapSrc.gID, mapDst.gID, @"\n\nMap.gID should be the same in both maps\n\n");
    XCTAssertEqualObjects(mapSrc.etag, mapDst.etag, @"\n\nMap.etag should be the same in both maps\n\n");
    XCTAssertEqualObjects(mapSrc.editLink, mapDst.editLink, @"\n\nMap.editLink should be the same in both maps\n\n");
    XCTAssertEqualObjects(mapSrc.featuresURL, mapDst.featuresURL, @"\n\nMap.featuresURL should be the same in both maps\n\n");
    XCTAssertEqualObjects(mapSrc.published_Date, mapDst.published_Date, @"\n\nMap.summary should be the same in both maps\n\n");
    XCTAssertEqualObjects(mapSrc.updated_Date, mapDst.updated_Date, @"\n\nMap.summary should be the same in both maps\n\n");
}





// =====================================================================================================================
#pragma mark -
#pragma mark POINT - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *)__GMap_AddNewRemotePointWithName:(NSString *)name descr:(NSString *)descr inMap:(GMTMap *)ownerMap {
    
    GMTPoint *pointToAdd = [GMTPoint emptyPointWithName:name];
    pointToAdd.descr = descr;
    pointToAdd.latitude = -10.101;
    pointToAdd.longitude = 20.202;
    [self __Assert_GMTPoint_Local_Instance:pointToAdd];
    XCTAssertEqualObjects(pointToAdd.name, name, @"\n\nPoint.name should be as setted\n\n");
    XCTAssertEqualObjects(pointToAdd.descr, descr, @"\n\nPoint.descr should be as setted\n\n");
    XCTAssertEqual(pointToAdd.latitude, -10.101, @"\n\nPoint.latitude should be as setted\n\n");
    XCTAssertEqual(pointToAdd.longitude, 20.202, @"\n\nPoint.longitude should be as setted\n\n");
    
    NSError *error = nil;
    GMTPoint *addedPoint = (GMTPoint *)[gmapService addPlacemark:pointToAdd inMap:ownerMap error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"addPlacemark", error);
    
    [self __Assert_GMTPoint_Remote_Instance:addedPoint];
    [self __Assert_AddedPoint:addedPoint withPoint:pointToAdd];
    
    GMTPoint *pointInMap = [self __GMap_findPointWithGID:addedPoint.gID inMap:ownerMap];
    XCTAssertNotNil(pointInMap, @"\n\nPoint should be present in GMap after adding it [getPointListFromMap]\n\n");
    [self __GMap_CompareRemotePoint:addedPoint withPoint:pointInMap];
    
    return addedPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *)__GMap_UpdateRemotePoint:(GMTPoint *)point withName:(NSString *)updName descr:(NSString *)updDescr inMap:(GMTMap *)ownerMap{
    
    point.name = updName;
    point.descr = updDescr;
    point.latitude = -30.303;
    point.longitude = 40.404;
    point.iconHREF = UPDATE_POINT_ICON_HREF;
    XCTAssertEqualObjects(point.name, updName, "\n\nPoint.name should be as setted\n\n");
    XCTAssertEqualObjects(point.descr, updDescr, "\n\nPoint.descr should be as setted\n\n");
    XCTAssertEqual(point.latitude, -30.303, @"\n\nPoint.latitude should be as setted\n\n");
    XCTAssertEqual(point.longitude, 40.404, @"\n\nPoint.longitude should be as setted\n\n");
    XCTAssertEqualObjects(point.iconHREF, UPDATE_POINT_ICON_HREF, "\n\nPoint.iconHREF should be as setted\n\n");
    
    
    NSError *error = nil;
    GMTPoint *updatedPoint = (GMTPoint *)[gmapService updatePlacemark:point inMap:ownerMap error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"updatePlacemark", error);
    
    [self __Assert_GMTPoint_Remote_Instance:updatedPoint];
    [self __Assert_UpdatedPoint:updatedPoint withPoint:point];
    
    
    GMTPoint *pointInMap = [self __GMap_findPointWithGID:updatedPoint.gID inMap:ownerMap];
    XCTAssertNotNil(pointInMap, @"\n\nPoint should be present in GMap after updating it [getPointListFromMap]\n\n");
    [self __GMap_CompareRemotePoint:updatedPoint withPoint:pointInMap];

    
    return updatedPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__GMap_DeleteRemotePoint:(GMTPoint *)point inMap:(GMTMap *)ownerMap {
    
    NSError *error = nil;
    
    NSString *prevGID = point.gID;
    
    BOOL ok = [gmapService deletePlacemark:point inMap:ownerMap error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"deletePlacemark", error);
    
    XCTAssertTrue(ok, @"\n\nPoint was not successfuly deleted \n\n");
    
    GMTPoint *pointInMap = [self __GMap_findPointWithGID:prevGID inMap:ownerMap];
    XCTAssertNil(pointInMap, @"\n\nPoint should not be present in Map after deleting it [getPointListFromMap]\n\n");
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) __GMap_findPointWithGID:(NSString *)pointGID inMap:(GMTMap *)map {
    
    NSArray *placemarkList = [self __GMap_GetPointListFromMap:map];
    for(GMTPlacemark *placemark in placemarkList) {
        if([placemark.gID isEqualToString:pointGID]) {
            if([placemark isKindOfClass:GMTPoint.class]) {
                return (GMTPoint *)placemark;
            } else {
                XCTFail(@"Placemark found for gID should be a GMTPoint");
            }
        }
    }
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *)__GMap_GetPointListFromMap:(GMTMap *)map {
    
    NSError *error = nil;
    NSArray *placemarkList = [gmapService getPlacemarkListFromMap:map error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"getPointListFromMap", error);
    
    XCTAssertNotNil(placemarkList, @"\n\nPlacemark List shouldn't be nil\n\n");
    
    NSMutableArray *pointList = [NSMutableArray array];
    for(GMTPlacemark *placemark in placemarkList) {
        if([placemark isKindOfClass:GMTPoint.class]) {
            [pointList addObject:placemark];
        }
    }
    return pointList;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_GMTPoint_Local_Instance:(GMTPoint *)point {
    
    XCTAssertNotNil(point, @"\n\nPoint instance must not be nil\n\n");
    
    XCTAssertTrue(point.name.length>0, @"\n\nLocal Point.name shouldn't be nil or empty\n\n");
    XCTAssertTrue(point.hasNoSyncLocalGID, @"\n\nLocal Point.gID should be equal to LOCAL-ID\n\n");
    XCTAssertTrue(point.hasNoSyncLocalETag, @"\n\nLocal Point.etag should be equal to LOCAL-ETAG\n\n");
    XCTAssertNil(point.editLink, @"\n\nLocal Point.editLink should be nil\n\n");
    XCTAssertNotNil(point.published_Date, @"\n\nLocal Point.published_Date shouldn't be nil\n\n");
    XCTAssertNotNil(point.updated_Date, @"\n\nLocal Point.updated_Date shouldn't be nil\n\n");
    XCTAssertNotNil(point.iconHREF, @"\n\nLocal Point.iconHREF shouldn't be nil\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_GMTPoint_Remote_Instance:(GMTPoint *)point {
    
    XCTAssertNotNil(point, @"\n\nPoint instance must not be nil\n\n");
    
    XCTAssertTrue(point.name.length>0, @"\n\nRemote Point.name shouldn't be nil or empty\n\n");
    XCTAssertFalse(point.hasNoSyncLocalGID, @"\n\nRemote Point.gID shouldn't be equal to LOCAL-ID\n\n");
    XCTAssertNotNil(point.gID, @"\n\nRemote Point.gID shouldn't be nil\n\n");
    XCTAssertFalse(point.hasNoSyncLocalETag, @"\n\nRemote Point.etag shouldn't be equal to LOCAL-ETAG\n\n");
    XCTAssertNotNil(point.etag, @"\n\nRemote Point.etag shouldn't be nil\n\n");
    XCTAssertNotNil(point.editLink, @"\n\nRemote Point.editLink shouldn't be nil\n\n");
    XCTAssertNotNil(point.published_Date, @"\n\nRemote Point.published_Date shouldn't be nil\n\n");
    XCTAssertNotNil(point.updated_Date, @"\n\nRemote Point.updated_Date shouldn't be nil\n\n");
    XCTAssertNotNil(point.iconHREF, @"\n\nRemote Point.iconHREF shouldn't be nil\n\n");

}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_AddedPoint:(GMTPoint *)addedPoint withPoint:(GMTPoint *)point {
    XCTAssertEqualObjects(point.name, addedPoint.name, @"\n\nPoint.name should remain unchanged after adding to GMap\n\n");
    
    // Al añadir un punto cambia el contenido a html si ve que hay un enlace en el texto
    if([point.descr indexOf:@"http://"]==NSNotFound && [point.descr indexOf:@"https://"]==NSNotFound) {
        XCTAssertEqualObjects(point.descr, addedPoint.descr, @"\n\nPoint.descr should remain unchanged after adding to GMap\n\n");
    }
    
    XCTAssertNotEqualObjects(point.gID, addedPoint.gID, @"\n\nPoint.gID should remain unchanged after adding to GMap\n\n");
    XCTAssertNotEqualObjects(point.etag, addedPoint.etag, @"\n\nPoint.etag should be changed after adding to GMap\n\n");
    XCTAssertNotEqualObjects(point.updated_Date, addedPoint.updated_Date, @"\n\nPoint.etag should be changed after adding to GMap\n\n");
    XCTAssertEqualObjects(point.iconHREF, addedPoint.iconHREF, @"\n\nPoint.iconHREF should remain unchanged after adding to GMap\n\n");
    XCTAssertEqual(point.latitude, addedPoint.latitude, @"\n\nPoint.latitude should remain unchanged after adding to GMap\n\n");
    XCTAssertEqual(point.longitude, addedPoint.longitude, @"\n\nPoint.longitude should remain unchanged after adding to GMap\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_UpdatedPoint:(GMTPoint *)updatedPoint withPoint:(GMTPoint *)point {

    XCTAssertEqualObjects(point.name, updatedPoint.name, @"\n\nPoint.name should be changed after updating to GMap\n\n");
    XCTAssertEqualObjects(point.descr, updatedPoint.descr, @"\n\nPoint.summary should changed after updating to GMap\n\n");
    XCTAssertEqualObjects(point.gID, updatedPoint.gID, @"\n\nPoint.gID should remain unchanged after updating to GMap\n\n");
    XCTAssertNotEqualObjects(point.etag, updatedPoint.etag, @"\n\nPoint.etag should be changed after updating to GMap\n\n");
    XCTAssertNotEqualObjects(point.updated_Date, updatedPoint.updated_Date, @"\n\nPoint.etag should be changed after updating to GMap\n\n");
    
    XCTAssertEqualObjects(point.iconHREF, updatedPoint.iconHREF, @"\n\nPoint.iconHREF should be changed after adding to GMap\n\n");
    XCTAssertEqual(point.latitude, updatedPoint.latitude, @"\n\nPoint.latitude should be changed after adding to GMap\n\n");
    XCTAssertEqual(point.longitude, updatedPoint.longitude, @"\n\nPoint.longitude should be changed after adding to GMap\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__GMap_CompareRemotePoint:(GMTPoint *)pointSrc withPoint:(GMTPoint *)pointDst {
    
    XCTAssertEqualObjects(pointSrc.name, pointDst.name, @"\n\nPoint.name should be the same in both points\n\n");
    XCTAssertEqualObjects(pointSrc.descr, pointDst.descr, @"\n\nPoint.descr should be the same in both points\n\n");
    XCTAssertEqualObjects(pointSrc.gID, pointDst.gID, @"\n\nPoint.gID should be the same in both points\n\n");
    XCTAssertEqualObjects(pointSrc.etag, pointDst.etag, @"\n\nPoint.etag should be the same in both points\n\n");
    XCTAssertEqualObjects(pointSrc.editLink, pointDst.editLink, @"\n\nPoint.editLink should be the same in both points\n\n");
    XCTAssertEqualObjects(pointSrc.published_Date, pointDst.published_Date, @"\n\nPoint.summary should be the same in both points\n\n");
    XCTAssertEqualObjects(pointSrc.updated_Date, pointDst.updated_Date, @"\n\nPoint.summary should be the same in both points\n\n");
    XCTAssertEqualObjects(pointSrc.iconHREF, pointDst.iconHREF, @"\n\nPoint.iconHREF should be the same in both points\n\n");
}





// =====================================================================================================================
#pragma mark -
#pragma mark POLYLINE - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (GMTPolyLine *)__GMap_AddNewRemotePolyLineWithName:(NSString *)name descr:(NSString *)descr inMap:(GMTMap *)ownerMap {
    
    
    GMTPolyLine *polylineToAdd = [GMTPolyLine emptyPolyLineWithName:name];
    polylineToAdd.descr = descr;
    [polylineToAdd addCoordWithLatitude:-10.101 andLongitude:20.202];
    [polylineToAdd addCoordWithLatitude:20.202 andLongitude:-40.404];
    [polylineToAdd addCoordWithLatitude:-30.303 andLongitude:60.606];
    GMTColor *testColor = [GMTColor colorWithRed:128.0/255.0 green:64.0/255.0 blue:23.0/255.0 alpha:20.0/255.0];

    polylineToAdd.color = testColor;
    polylineToAdd.width = 10;
    
    [self __Assert_GMTPolyLine_Local_Instance:polylineToAdd];
    
    XCTAssertEqualObjects(polylineToAdd.name, name, @"\n\nPolyLine.name should be as setted\n\n");
    XCTAssertEqualObjects(polylineToAdd.descr, descr, @"\n\nPolyLine.descr should be as setted\n\n");
    XCTAssertEqual(polylineToAdd.coordinates.count, 3, @"\n\nPolyLine.coordinates should be as setted\n\n");
    CLLocation *coord = polylineToAdd.coordinates[1];
    XCTAssertEqual(coord.coordinate.latitude, 20.202, @"\n\nPolyLine.latitude[1] should be as setted\n\n");
    XCTAssertEqual(coord.coordinate.longitude, -40.404, @"\n\nPolyLine.longitude[1] should be as setted\n\n");
    XCTAssertEqualObjects(polylineToAdd.color, testColor, @"\n\nPolyLine.color should be as setted\n\n");
    XCTAssertEqual(polylineToAdd.width, 10, @"\n\nPolyLine.width should be as setted\n\n");
    
    
    NSError *error = nil;
    GMTPolyLine *addedPolyLine = (GMTPolyLine *)[gmapService addPlacemark:polylineToAdd inMap:ownerMap error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"addPlacemark", error);
    
    [self __Assert_GMTPolyLine_Remote_Instance:addedPolyLine];
    [self __Assert_AddedPolyLine:addedPolyLine withPolyLine:polylineToAdd];
    
    GMTPolyLine *polylineInMap = [self __GMap_findPolyLineWithGID:addedPolyLine.gID inMap:ownerMap];
    XCTAssertNotNil(polylineInMap, @"\n\nPolyLine should be present in GMap after adding it [getPointListFromMap]\n\n");
    [self __GMap_CompareRemotePolyLine:addedPolyLine withPolyLine:polylineInMap];
    
    return addedPolyLine;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPolyLine *)__GMap_UpdateRemotePolyLine:(GMTPolyLine *)polyline withName:(NSString *)updName descr:(NSString *)updDescr inMap:(GMTMap *)ownerMap{
    
    polyline.name = updName;
    polyline.descr = updDescr;
    [polyline.coordinates removeAllObjects];
    [polyline addCoordWithLatitude:-30.303 andLongitude:60.606];
    [polyline addCoordWithLatitude:40.404 andLongitude:-80.808];
    GMTColor *testColor = [GMTColor colorWithRed:28.0/255.0 green:164.0/255.0 blue:123.0/255.0 alpha:40.0/255.0];

    polyline.color = testColor;
    polyline.width = 5;
    
    XCTAssertEqualObjects(polyline.name, updName, @"\n\nPolyLine.name should be as setted\n\n");
    XCTAssertEqualObjects(polyline.descr, updDescr, @"\n\nPolyLine.descr should be as setted\n\n");
    XCTAssertEqual(polyline.coordinates.count, 2, @"\n\nPolyLine.coordinates should be as setted\n\n");
    CLLocation *coord = polyline.coordinates[1];
    XCTAssertEqual(coord.coordinate.latitude, 40.404, @"\n\nPolyLine.latitude[1] should be as setted\n\n");
    XCTAssertEqual(coord.coordinate.longitude, -80.808, @"\n\nPolyLine.longitude[1] should be as setted\n\n");
    XCTAssertEqualObjects(polyline.color, testColor, @"\n\nPolyLine.color should be as setted\n\n");
    XCTAssertEqual(polyline.width, 5, @"\n\nPolyLine.width should be as setted\n\n");

    
    NSError *error = nil;
    GMTPolyLine *updatedPolyLine = (GMTPolyLine *)[gmapService updatePlacemark:polyline inMap:ownerMap error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"updatePlacemark", error);
    
    [self __Assert_GMTPolyLine_Remote_Instance:updatedPolyLine];
    [self __Assert_UpdatedPolyLine:updatedPolyLine withPolyLine:polyline];
    
    
    GMTPolyLine *polyLineInMap = [self __GMap_findPolyLineWithGID:updatedPolyLine.gID inMap:ownerMap];
    XCTAssertNotNil(polyLineInMap, @"\n\nPoint should be present in GMap after updating it [getPointListFromMap]\n\n");
    [self __GMap_CompareRemotePolyLine:updatedPolyLine withPolyLine:polyLineInMap];
    
    return updatedPolyLine;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__GMap_DeleteRemotePolyLine:(GMTPolyLine *)polyline inMap:(GMTMap *)ownerMap {
    
    NSError *error = nil;
    
    NSString *prevGID = polyline.gID;
    
    BOOL ok = [gmapService deletePlacemark:polyline inMap:ownerMap error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"deletePlacemark", error);
    
    XCTAssertTrue(ok, @"\n\nPolyLine was not successfuly deleted \n\n");
    
    GMTPolyLine *polylineInMap = [self __GMap_findPolyLineWithGID:prevGID inMap:ownerMap];
    XCTAssertNil(polylineInMap, @"\n\nPolyLine should not be present in Map after deleting it [getPointListFromMap]\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPolyLine *) __GMap_findPolyLineWithGID:(NSString *)polylineGID inMap:(GMTMap *)map {
    
    NSArray *placemarkList = [self __GMap_GetPolyLineListFromMap:map];
    for(GMTPlacemark *placemark in placemarkList) {
        if([placemark.gID isEqualToString:polylineGID]) {
            if([placemark isKindOfClass:GMTPolyLine.class]) {
                return (GMTPolyLine *)placemark;
            } else {
                XCTFail(@"Placemark found for gID should be a GMTPolyLine");
            }
        }
    }
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *)__GMap_GetPolyLineListFromMap:(GMTMap *)map {
    
    NSError *error = nil;
    NSArray *placemarkList = [gmapService getPlacemarkListFromMap:map error:&error];
    XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"getPointListFromMap", error);
    
    XCTAssertNotNil(placemarkList, @"\n\nPlacemark List shouldn't be nil\n\n");
    
    NSMutableArray *polylines = [NSMutableArray array];
    for(GMTPlacemark *placemark in placemarkList) {
        if([placemark isKindOfClass:GMTPolyLine.class]) {
            [polylines addObject:placemark];
        }
    }
    return polylines;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_GMTPolyLine_Local_Instance:(GMTPolyLine *)polyline {
    
    XCTAssertNotNil(polyline, @"\n\nPolyLine instance must not be nil\n\n");
    
    XCTAssertTrue(polyline.name.length>0, @"\n\nLocal PolyLine.name shouldn't be nil or empty\n\n");
    XCTAssertTrue(polyline.hasNoSyncLocalGID, @"\n\nLocal PolyLine.gID should be equal to LOCAL-ID\n\n");
    XCTAssertTrue(polyline.hasNoSyncLocalETag, @"\n\nLocal PolyLine.etag should be equal to LOCAL-ETAG\n\n");
    XCTAssertNil(polyline.editLink, @"\n\nLocal PolyLine.editLink should be nil\n\n");
    XCTAssertNotNil(polyline.published_Date, @"\n\nLocal PolyLine.published_Date shouldn't be nil\n\n");
    XCTAssertNotNil(polyline.updated_Date, @"\n\nLocal PolyLine.updated_Date shouldn't be nil\n\n");
    XCTAssertNotNil(polyline.color, @"\n\nLocal PolyLine.color shouldn't be nil\n\n");
    XCTAssertTrue(polyline.width>0, @"\n\nLocal PolyLine.width shouldn't be zero\n\n");
    XCTAssertTrue(polyline.coordinates.count>0, @"\n\nLocal PolyLine.coordinates.count shouldn't be zero\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_GMTPolyLine_Remote_Instance:(GMTPolyLine *)polyline {
    
    XCTAssertNotNil(polyline, @"\n\nPolyLine instance must not be nil\n\n");
    
    XCTAssertTrue(polyline.name.length>0, @"\n\nRemote PolyLine.name shouldn't be nil or empty\n\n");
    XCTAssertFalse(polyline.hasNoSyncLocalGID, @"\n\nRemote PolyLine.gID shouldn't be equal to LOCAL-ID\n\n");
    XCTAssertNotNil(polyline.gID, @"\n\nRemote PolyLine.gID shouldn't be nil\n\n");
    XCTAssertFalse(polyline.hasNoSyncLocalETag, @"\n\nRemote PolyLine.etag shouldn't be equal to LOCAL-ETAG\n\n");
    XCTAssertNotNil(polyline.etag, @"\n\nRemote PolyLine.etag shouldn't be nil\n\n");
    XCTAssertNotNil(polyline.editLink, @"\n\nRemote PolyLine.editLink shouldn't be nil\n\n");
    XCTAssertNotNil(polyline.published_Date, @"\n\nRemote PolyLine.published_Date shouldn't be nil\n\n");
    XCTAssertNotNil(polyline.updated_Date, @"\n\nRemote PolyLine.updated_Date shouldn't be nil\n\n");
    XCTAssertNotNil(polyline.color, @"\n\nRemote PolyLine.color shouldn't be nil\n\n");
    XCTAssertTrue(polyline.width>0, @"\n\nRemote PolyLine.width shouldn't be zero\n\n");
    XCTAssertTrue(polyline.coordinates.count>0, @"\n\nRemote PolyLine.coordinates.count shouldn't be zero\n\n");
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_AddedPolyLine:(GMTPolyLine *)addedPolyLine withPolyLine:(GMTPolyLine *)polyline {
    
    
    XCTAssertEqualObjects(polyline.name, addedPolyLine.name, @"\n\nPolyLine.name should remain unchanged after adding to GMap\n\n");
    
    // Al añadir un punto cambia el contenido a html si ve que hay un enlace en el texto
    if([polyline.descr indexOf:@"http://"]==NSNotFound && [polyline.descr indexOf:@"https://"]==NSNotFound) {
        XCTAssertEqualObjects(polyline.descr, addedPolyLine.descr, @"\n\nPolyLine.descr should remain unchanged after adding to GMap\n\n");
    }
    
    XCTAssertNotEqualObjects(polyline.gID, addedPolyLine.gID, @"\n\nPolyLine.gID should remain unchanged after adding to GMap\n\n");
    XCTAssertNotEqualObjects(polyline.etag, addedPolyLine.etag, @"\n\nPolyLine.etag should be changed after adding to GMap\n\n");
    XCTAssertNotEqualObjects(polyline.updated_Date, addedPolyLine.updated_Date, @"\n\nPolyLine.etag should be changed after adding to GMap\n\n");

    XCTAssertEqualObjects(polyline.color, addedPolyLine.color, @"\n\nPolyLine.color should remain unchanged after adding to GMap\n\n");
    XCTAssertEqual(polyline.width, addedPolyLine.width, @"\n\nPolyLine.width should remain unchanged after adding to GMap\n\n");
    
    XCTAssertEqual(polyline.coordinates.count, addedPolyLine.coordinates.count, @"\n\nPolyLine.coordinates.count should remain unchanged after adding to GMap\n\n");
    for(int n=0;n<polyline.coordinates.count;n++) {
        
        CLLocation *coord1 = polyline.coordinates[n];
        CLLocation *coord2 = addedPolyLine.coordinates[n];
        
        XCTAssertEqual(coord1.coordinate.longitude, coord2.coordinate.longitude, @"\n\nPolyLine[n].longitude should remain unchanged after adding to GMap\n\n");
        XCTAssertEqual(coord1.coordinate.latitude, coord2.coordinate.latitude, @"\n\nPolyLine[n].latitude should remain unchanged after adding to GMap\n\n");
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__Assert_UpdatedPolyLine:(GMTPolyLine *)updatedPolyLine withPolyLine:(GMTPolyLine *)polyline {
    
    XCTAssertEqualObjects(polyline.name, updatedPolyLine.name, @"\n\nPolyLine.name should be changed after updating to GMap\n\n");
    XCTAssertEqualObjects(polyline.descr, updatedPolyLine.descr, @"\n\nPolyLine.summary should changed after updating to GMap\n\n");
    XCTAssertEqualObjects(polyline.gID, updatedPolyLine.gID, @"\n\nPolyLine.gID should remain unchanged after updating to GMap\n\n");
    XCTAssertNotEqualObjects(polyline.etag, updatedPolyLine.etag, @"\n\nPolyLine.etag should be changed after updating to GMap\n\n");
    XCTAssertNotEqualObjects(polyline.updated_Date, updatedPolyLine.updated_Date, @"\n\nPolyLine.etag should be changed after updating to GMap\n\n");
    
    XCTAssertEqualObjects(polyline.color, updatedPolyLine.color, @"\n\nPolyLine.color should remain unchanged after updating to GMap\n\n");
    XCTAssertEqual(polyline.width, updatedPolyLine.width, @"\n\nPolyLine.width should remain unchanged after updating to GMap\n\n");

    XCTAssertEqual(polyline.coordinates.count, updatedPolyLine.coordinates.count, @"\n\nPolyLine.coordinates.count should remain unchanged after updating to GMap\n\n");
    for(int n=0;n<polyline.coordinates.count;n++) {
        
        CLLocation *coord1 = polyline.coordinates[n];
        CLLocation *coord2 = updatedPolyLine.coordinates[n];
        
        XCTAssertEqual(coord1.coordinate.longitude, coord2.coordinate.longitude, @"\n\nPolyLine[n].longitude should remain unchanged after updating to GMap\n\n");
        XCTAssertEqual(coord1.coordinate.latitude, coord2.coordinate.latitude, @"\n\nPolyLine[n].latitude should remain unchanged after updating to GMap\n\n");
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)__GMap_CompareRemotePolyLine:(GMTPolyLine *)polylineSrc withPolyLine:(GMTPolyLine *)polylineDst {
    
    XCTAssertEqualObjects(polylineSrc.name, polylineDst.name, @"\n\nPolyLine.name should be the same in both PolyLines\n\n");
    XCTAssertEqualObjects(polylineSrc.descr, polylineDst.descr, @"\n\nPolyLine.descr should be the same in both PolyLines\n\n");
    XCTAssertEqualObjects(polylineSrc.gID, polylineDst.gID, @"\n\nPolyLine.gID should be the same in both PolyLines\n\n");
    XCTAssertEqualObjects(polylineSrc.etag, polylineDst.etag, @"\n\nPolyLine.etag should be the same in both PolyLines\n\n");
    XCTAssertEqualObjects(polylineSrc.editLink, polylineDst.editLink, @"\n\nPolyLine.editLink should be the same in both PolyLines\n\n");
    XCTAssertEqualObjects(polylineSrc.published_Date, polylineDst.published_Date, @"\n\nPolyLine.summary should be the same in both PolyLines\n\n");
    XCTAssertEqualObjects(polylineSrc.updated_Date, polylineDst.updated_Date, @"\n\nPolyLine.summary should be the same in both PolyLines\n\n");
    XCTAssertEqualObjects(polylineSrc.color, polylineDst.color, @"\n\nPolyLine.color should be the same in both PolyLines\n\n");
    XCTAssertEqual(polylineSrc.width, polylineDst.width, @"\n\nPolyLine.width should be the same in both PolyLines\n\n");

    XCTAssertEqual(polylineSrc.coordinates.count, polylineDst.coordinates.count, @"\n\nPolyLine.coordinates.count should be the same in both PolyLines\n\n");
    for(int n=0;n<polylineSrc.coordinates.count;n++) {
        
        CLLocation *coord1 = polylineSrc.coordinates[n];
        CLLocation *coord2 = polylineDst.coordinates[n];
        
        XCTAssertEqual(coord1.coordinate.longitude, coord2.coordinate.longitude, @"\n\nPolyLine[n].longitude should be the same in both PolyLines\n\n");
        XCTAssertEqual(coord1.coordinate.latitude, coord2.coordinate.latitude, @"\n\nPolyLine[n].latitude should be the same in both PolyLines\n\n");
    }
}




// =====================================================================================================================
#pragma mark -
#pragma mark GENERAL - PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) __GMap_Login {
    
    if(gmapService==nil) {
        DDLogVerbose(@"*** >> Login in GMap Service\n\n");
        
        NSError *error = nil;
        NSString *usr = [Cypher decryptString:@"anphcnp1ZWxhQGdtYWlsLmNvbQ=="];
        NSString *pwd = [Cypher decryptString:@"I3dlYndlYjE5NzE="];
        
        gmapService = [GMapService serviceWithEmail2:usr password:pwd error:&error];
        XCTAssertNil(error, "\n\nError calling GMapService[%@]: %@\n\n", @"serviceWithEmail", error);
        
        XCTAssertNotNil(gmapService, @"\n\nGMapService instance must not be nil\n\n");
        
        DDLogVerbose(@"\n\n");
    }
    
    return gmapService!=nil;
    
}





@end
