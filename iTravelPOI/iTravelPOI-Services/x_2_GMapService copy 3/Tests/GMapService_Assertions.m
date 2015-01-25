//
// GMapService_AssertionsBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "GMapService_Assertions.h"
#import "GMComparer.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface Private Definition
// *********************************************************************************************************************
@interface GMapService_Assertions ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMapService_Assertions




// =====================================================================================================================
#pragma mark -
#pragma mark UTIL ITEM methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) assertInfoIsSyncForMap:(id<GMMap>)map gmapService:(GMRemoteService *)gmapService skipDeleteLocal:(BOOL)skipDeleteLocal {
    
    // Recupera el mapa a comparar
    NSError *error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
    id<GMMap> remoteMap = [gmapService retrieveMapByGID:map.gID errRef:&error];
    XCTAssertNil(error, @"Error from 'retrieveMapByGID' should be nil: %@", error);
    XCTAssertNotNil(remoteMap, @"Map from 'retrieveMapByGID' shouldn't be nil");
    
    // Recupera la lista de placemarks
    error = [NSError errorWithDomain:@"Test" reason:@"This error should be changed to NIL"];
    BOOL rc = [gmapService retrievePlacemarksForMap:remoteMap errRef:&error];
    XCTAssertNil(error, @"Error from 'retrievePlacemarksForMap' should be nil: %@", error);
    XCTAssertTrue(rc, @"RC from 'retrievePlacemarksForMap' shouldn't be FALSE");
    XCTAssertNotNil(remoteMap.placemarks, @"GMMap.placemarks shouldn't be nil: %@", remoteMap);

    // Compara ambos mapas
    NSArray *mapTuples = [GMComparer compareLocalItems:[NSArray arrayWithObject:map] toRemoteItems:[NSArray arrayWithObject:remoteMap]];
    XCTAssertNotNil(mapTuples, @"MapTuples shouldn't be nil: %@", mapTuples);
    XCTAssertTrue(mapTuples.count==1, @"MapTuples should have just 1 element");
    GMCompareTuple *mt = mapTuples[0];
    XCTAssertTrue(mt.compStatus==CS_Equals, @"MapTuple.compStatus should be 'CS_Equals': %@",mt);
    XCTAssertFalse(mt.conflicted, @"MapTuple.conflicted should be FALSE: %@",mt);
    
    // Compara los placemarks de ambos mapas
    NSArray *pmTuples = [GMComparer compareLocalItems:map.placemarks toRemoteItems:remoteMap.placemarks];
    XCTAssertNotNil(pmTuples, @"PlacemarkTuples shouldn't be nil: %@", pmTuples);
    for(GMCompareTuple *pt in pmTuples) {
        if(!skipDeleteLocal)
            XCTAssertTrue(pt.compStatus==CS_Equals, @"MapTuple.compStatus should be 'CS_Equals': %@",mt);
        else
            XCTAssertTrue(pt.compStatus==CS_Equals || pt.compStatus==CS_DeleteLocal, @"MapTuple.compStatus should be 'CS_Equals' or 'CS_DeleteLocal': %@",mt);
        XCTAssertFalse(pt.conflicted, @"MapTuple.conflicted should be FALSE: %@",mt);
    }
    
}


// =====================================================================================================================
#pragma mark -
#pragma mark REMOTE ITEM methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) assert_RemoteItem:(id<GMItem>)item skipDeleteLocal:(BOOL)skipDeleteLocal {
    
    // Comprueba los campos base
    XCTAssertNotNil(item.gID, "Remote GMItem.gID shouldn't be nil: %@", item);
    XCTAssertTrue(item.gID.length>0, "Remote GMItem.gID shouldn't be empty: %@", item);
    
    XCTAssertNotNil(item.etag, "Remote GMItem.etag shouldn't be nil: %@", item);
    XCTAssertTrue(item.etag.length>0, "Remote GMItem.etag shouldn't be empty: %@", item);
    
    XCTAssertTrue(item.wasSynchronized, "Remote GMItem should be synchronized: %@", item);
    
    XCTAssertNotNil(item.name, "Remote GMItem.name shouldn't be nil: %@", item);
    XCTAssertTrue(item.name.length>0, "Remote GMItem.names shouldn't be empty: %@", item);
    
    
    if(!skipDeleteLocal) {
        XCTAssertFalse(item.markedAsDeleted, "Remote GMItem.markedAsDeleted shouldn't be TRUE: %@", item);
        XCTAssertFalse(item.localModified, "Remote GMItem.localModified shouldn't be TRUE: %@", item);
    }
    
    
    // Comprueba los campos de las subclases
    if([item conformsToProtocol:@protocol(GMMap)]) {
        [self __assert_Remote_Map:(id<GMMap>)item];
    } else {
        [self __assert_Remote_Placemark:(id<GMPlacemark>)item];
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __assert_Remote_Map:(id<GMMap>)map {
    
    // No hay nada
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __assert_Remote_Placemark:(id<GMPlacemark>)placemark {
    
    // Comprueba los campos base
    XCTAssertNotNil(placemark.map, @"Remote GMPlacemark.map shouldn't be nil: %@", placemark);
    XCTAssertNotNil(placemark.descr, @"Remote GMPlacemark.descr shouldn't be nil: %@", placemark);
    
    // Comprueba los campos de las subclases
    if([placemark conformsToProtocol:@protocol(GMPoint)]) {
        [self __assert_Remote_Point:(id<GMPoint>)placemark];
    } else {
        [self __assert_Remote_PolyLine:(id<GMPolyLine>)placemark];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __assert_Remote_Point:(id<GMPoint>)point {
    
    XCTAssertNotNil(point.iconHREF, "Remote GMPoint.iconHREF shouldn't be nil: %@", point);
    XCTAssertTrue(point.iconHREF.length>0, "Remote GMPoint.iconHREF shouldn't be empty: %@", point);
    
    XCTAssertNotNil(point.coordinates, @"Remote GMPoint.coordinates shouldn't be nil: %@", point);
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __assert_Remote_PolyLine:(id<GMPolyLine>)polyLine {
    
    XCTAssertNotNil(polyLine.color, "Remote GMPolyLine.color shouldn't be nil: %@", polyLine);
    XCTAssertTrue(polyLine.width>0, "Remote GMPolyLine.width shouldn't be zero: %@", polyLine);
    
    XCTAssertNotNil(polyLine.coordinatesList, @"Remote GMPolyLine.coordinatesList shouldn't be nil: %@", polyLine);
    XCTAssertTrue(polyLine.coordinatesList.count>1, @"Remote GMPolyLine.coordinatesList.count shouldn have at least 2 points: %@", polyLine);
}





// =====================================================================================================================
#pragma mark -
#pragma mark LOCAL ITEM methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) assert_LocalItem:(id<GMItem>)item {
    
    // Comprueba los campos base
    XCTAssertNotNil(item.gID, "Local GMItem.gID shouldn't be nil: %@", item);
    XCTAssertTrue(item.gID.length>0, "Local GMItem.gID shouldn't be empty: %@", item);
    
    XCTAssertNotNil(item.etag, "Local GMItem.etag shouldn't be nil: %@", item);
    XCTAssertTrue(item.etag.length>0, "Local GMItem.etag shouldn't be empty: %@", item);
    
    XCTAssertFalse(item.wasSynchronized, "Local GMItem shouldn't be synchronized: %@", item);
    
    XCTAssertNotNil(item.name, "Local GMItem.name shouldn't be nil: %@", item);
    XCTAssertTrue(item.name.length>0, "Local GMItem.names shouldn't be empty: %@", item);
    
    XCTAssertFalse(item.markedAsDeleted, "Local GMItem.markedAsDeleted shouldn't be TRUE: %@", item);
    XCTAssertTrue(item.localModified, "Local GMItem.localModified should be TRUE: %@", item);
 
    // Comprueba los campos de las subclases
    if([item conformsToProtocol:@protocol(GMMap)]) {
        [self __assert_Local_Map:(id<GMMap>)item];
    } else {
        [self __assert_Local_Placemark:(id<GMPlacemark>)item];
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __assert_Local_Map:(id<GMMap>)map {
    
    // No hay nada
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __assert_Local_Placemark:(id<GMPlacemark>)placemark {
    
    // Comprueba los campos base
    XCTAssertNotNil(placemark.map, @"Local GMPlacemark.map shouldn't be nil: %@", placemark);
    XCTAssertNotNil(placemark.descr, @"Local GMPlacemark.descr shouldn't be nil: %@", placemark);
    
    // Comprueba los campos de las subclases
    if([placemark conformsToProtocol:@protocol(GMPoint)]) {
        [self __assert_Local_Point:(id<GMPoint>)placemark];
    } else {
        [self __assert_Local_PolyLine:(id<GMPolyLine>)placemark];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __assert_Local_Point:(id<GMPoint>)point {
    
    XCTAssertNotNil(point.iconHREF, "Local GMPoint.iconHREF shouldn't be nil: %@", point);
    XCTAssertTrue(point.iconHREF.length>0, "Local GMPoint.iconHREF shouldn't be empty: %@", point);
    
    XCTAssertNotNil(point.coordinates, @"Local GMPoint.coordinates shouldn't be nil: %@", point);
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __assert_Local_PolyLine:(id<GMPolyLine>)polyLine {
    
    XCTAssertNotNil(polyLine.color, "Local GMPolyLine.color shouldn't be nil: %@", polyLine);
    XCTAssertTrue(polyLine.width>0, "Local GMPolyLine.width shouldn't be zero: %@", polyLine);
    
    XCTAssertNotNil(polyLine.coordinatesList, @"Local GMPolyLine.coordinatesList shouldn't be nil: %@", polyLine);
    XCTAssertTrue(polyLine.coordinatesList.count>1, @"Local GMPolyLine.coordinatesList.count shouldn have at least 2 points: %@", polyLine);
}



@end
