//
// GMItemValidator.m
// GMItemValidator
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMItemValidator_IMPL__
#import "GMItemValidator.h"

#import "DDLog.h"
#import "NSString+HTML.h"
#import "NSString+JavaStr.h"
#import "NSError+SimpleInit.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMItemValidator ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMItemValidator



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
// FALSE if any is NIL
+ (BOOL) validateFieldsAreNotNil:(id<GMItem>)item errRef:(NSErrorRef *)errRef {
    

    // Establece que no hay un error
    [NSError nilErrorRef:errRef];

    
    NSMutableArray *fieldNames = [NSMutableArray array];
    
    if([item conformsToProtocol:@protocol(GMMap)]) {
        [self _assertFieldsNotNilForMap:(id<GMMap>)item fieldNames:fieldNames];
    } else if([item conformsToProtocol:@protocol(GMPoint)]) {
        [self _assertFieldsNotNilForPoint:(id<GMPoint>)item fieldNames:fieldNames];
    } else if([item conformsToProtocol:@protocol(GMPolyLine)]) {
        [self _assertFieldsNotNilForPolyLine:(id<GMPolyLine>)item fieldNames:fieldNames];
    } else {
        // Aqui no deberia llegar
        [fieldNames addObject:@"Unknown GMItem type"];
    }
    
    // Avisa si hubo algun error
    if(fieldNames.count > 0) {
        [NSError setErrorRef:errRef domain:@"GMItemValidator"  reason:@"Some fields of %@ have a nil value: %@", [item.class className], [fieldNames componentsJoinedByString:@", "]];
        return FALSE;
    } else {
        return TRUE;
    }

}





// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
+ (void) _assertFieldsNotNilForItem:(id<GMItem>)item fieldNames:(NSMutableArray *)fieldNames {
    
    // Valida la informacion propia de GMItem
    if(!item.name) [fieldNames addObject:@"name"];
    if(!item.gID) [fieldNames addObject:@"gID"];
    if(!item.etag) [fieldNames addObject:@"etag"];
    if(!item.published_Date) [fieldNames addObject:@"published_Date"];
    if(!item.updated_Date) [fieldNames addObject:@"updated_Date"];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _assertFieldsNotNilForMap:(id<GMMap>)map fieldNames:(NSMutableArray *)fieldNames {

    // Valida la informacion base GMItem
    [self _assertFieldsNotNilForItem:map fieldNames:fieldNames];
    
    // Valida la informacion propia de GMMap
    if(!map.summary) [fieldNames addObject:@"summary"];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _assertFieldsNotNilForPlacemark:(id<GMPlacemark>)placemark fieldNames:(NSMutableArray *)fieldNames {
    
    // Valida la informacion base GMItem
    [self _assertFieldsNotNilForItem:placemark fieldNames:fieldNames];
    
    // Valida la informacion propia de GMPlacemark
    if(!placemark.descr) [fieldNames addObject:@"descr"];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _assertFieldsNotNilForPoint:(id<GMPoint>)point fieldNames:(NSMutableArray *)fieldNames {
    
    // Valida la informacion base GMPlacemark
    [self _assertFieldsNotNilForPlacemark:point fieldNames:fieldNames];

    // Valida la informacion propia de GMPoint
    if(!point.iconHREF) [fieldNames addObject:@"iconHREF"];
    if(!point.coordinates) [fieldNames addObject:@"coordinates"];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _assertFieldsNotNilForPolyLine:(id<GMPolyLine>)polyLine fieldNames:(NSMutableArray *)fieldNames {
    
    // Valida la informacion base GMPlacemark
    [self _assertFieldsNotNilForPlacemark:polyLine fieldNames:fieldNames];

    // Valida la informacion propia de GMPolyLine
    if(!polyLine.color) [fieldNames addObject:@"color"];
    if(polyLine.width<=0) [fieldNames addObject:@"width<=0"];
    if(!polyLine.coordinatesList) [fieldNames addObject:@"coordinatesList"];
    if(polyLine.coordinatesList.count<2) [fieldNames addObject:@"coordinatesList.count<2"];
}


@end
