//
// GMFeedProcessor.m
// GMFeedProcessor
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMFeedProcessor_IMPL__
#import "GMFeedProcessor.h"

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
@interface GMFeedProcessor ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMFeedProcessor



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (id<GMPlacemark>) emptyPlacemarkFromFeed:(NSDictionary *)feedDict itemFactory:(id<GMItemFactory>)itemFactory inMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef {
    
    // Establece que no hay un error
    [NSError nilErrorRef:errRef];

    // Solo procesa las features tipo "Point" && "LineString"
    BOOL isPoint = [feedDict valueForKeyPath:@"atom:content.Placemark.Point"] != nil;
    BOOL isPolyLine = [feedDict valueForKeyPath:@"atom:content.Placemark.LineString"] != nil;
    
    // Responde segun la informacion del feed
    if(isPoint) {
        return [itemFactory newPointWithName:@"" inMap:map errRef:errRef];
    } else if(isPolyLine){
        return [itemFactory newPolyLineWithName:@"" inMap:map errRef:errRef];
    } else {
        [NSError setErrorRef:errRef domain:@"GMFeedProcessor"  reason:@"Neither Point nor PoliLyne data found in feed: %@", feedDict];
        return nil;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
// Clears markedAsModified and markedAsDeleted
+ (void) setItemValues:(id<GMItem>)item fromFeed:(NSDictionary *)feedDict {

    if([item conformsToProtocol:@protocol(GMMap)]) {
        [self _setValuesForMap:(id<GMMap>)item fromFeed:feedDict];
    } else if([item conformsToProtocol:@protocol(GMPoint)]) {
        [self _setValuesForPoint:(id<GMPoint>)item fromFeed:feedDict];
    } else if([item conformsToProtocol:@protocol(GMPolyLine)]) {
        [self _setValuesForPolyLine:(id<GMPolyLine>)item fromFeed:feedDict];
    }
}





// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
+ (void) _setValuesForItem:(id<GMItem>)item fromFeed:(NSDictionary *)feedDict {
    
    // Parsea la informacion propia de GMItem
    item.name = [[[feedDict valueForKeyPath:@"title.text"] gtm_stringByUnescapingFromHTML] trim];
    
    item.gID = [[feedDict valueForKeyPath:@"id.text"] trim];
    if(!item.gID) item.gID = [[feedDict valueForKeyPath:@"atom:id.text"] trim];
    
    item.etag = [[feedDict valueForKeyPath:@"gd:etag"] trim];
    
    item.published_Date = [self _dateFromString:[feedDict valueForKeyPath:@"published.text"]];
    if(!item.published_Date) item.published_Date = [self _dateFromString:[feedDict valueForKeyPath:@"atom:published.text"]];
    
    item.updated_Date = [self _dateFromString:[feedDict valueForKeyPath:@"updated.text"]];
    if(!item.updated_Date) item.updated_Date = [self _dateFromString:[feedDict valueForKeyPath:@"atom:updated.text"]];
    
    // Limpia las marcas de modificado y borrado
    item.markedForSync = NO;
    item.markedAsDeleted = NO;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _setValuesForMap:(id<GMMap>)map fromFeed:(NSDictionary *)feedDict {

    // Parsea la informacion base GMItem
    [self _setValuesForItem:map fromFeed:feedDict];
    
    // Parsea la informacion propia de GMMap
    map.summary = [[feedDict valueForKeyPath:@"summary.text"] trim];
    if(map.summary == nil) map.summary = @"";
    if([map.summary isEqualToString:GM_MAP_EMPTY_SUMMARY]) map.summary = @"";
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _setValuesForPlacemark:(id<GMPlacemark>)placemark fromFeed:(NSDictionary *)feedDict {
    
    // Parsea la informacion base GMItem
    [self _setValuesForItem:placemark fromFeed:feedDict];
    
    // Parsea la informacion propia de GMPlacemark
    placemark.name = [[[feedDict valueForKeyPath:@"atom:content.Placemark.name.text"] gtm_stringByUnescapingFromHTML] trim];

    placemark.descr = [[feedDict valueForKeyPath:@"atom:content.Placemark.description.text"] trim];
    if(placemark.descr == nil) placemark.descr = @"";
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _setValuesForPoint:(id<GMPoint>)point fromFeed:(NSDictionary *)feedDict {
    
    // Parsea la informacion base GMPlacemark
    [self _setValuesForPlacemark:point fromFeed:feedDict];

    // Parsea la informacion propia de GMPoint
    point.iconHREF = [[[feedDict valueForKeyPath:@"atom:content.Placemark.Style.IconStyle.Icon.href.text"] gtm_stringByUnescapingFromHTML] trim];
    if(point.iconHREF == nil) point.iconHREF = GM_DEFAULT_POINT_ICON_HREF;
    
    NSString *coordinates = [feedDict valueForKeyPath:@"atom:content.Placemark.Point.coordinates.text"];
    point.coordinates = [GMCoordinates coordinatesWithString:coordinates];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _setValuesForPolyLine:(id<GMPolyLine>)polyLine fromFeed:(NSDictionary *)feedDict {
    
    // Parsea la informacion base GMPlacemark
    [self _setValuesForPlacemark:polyLine fromFeed:feedDict];

    // Parsea la informacion propia de GMPolyLine
    NSString *hexColorStr = [feedDict valueForKeyPath:@"atom:content.Placemark.Style.LineStyle.color.text"];
    polyLine.color = [self _colorFromHexStr:hexColorStr];
    
    NSString *widthStr = [feedDict valueForKeyPath:@"atom:content.Placemark.Style.LineStyle.width.text"];
    polyLine.width = [widthStr integerValue];

    //<!-- lon,lat[,alt] varias serapadas por un espacio -->
    NSString *coordinates = [feedDict valueForKeyPath:@"atom:content.Placemark.LineString.coordinates.text"];
    NSArray *splittedStr = [coordinates componentsSeparatedByString:@" "];
    for(NSString *singleCoordStr in splittedStr) {
        GMCoordinates *coord = [GMCoordinates coordinatesWithString:singleCoordStr];
        [polyLine.coordinatesList addObject:coord];
    }
}


// ---------------------------------------------------------------------------------------------------------------------
+ (NSDate *) _dateFromString:(NSString *)str {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GM_DATE_FORMAT];
    // The Z at the end of your string represents Zulu which is UTC
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *dateFromString = [dateFormatter dateFromString:str];
    return dateFromString;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMColor *) _colorFromHexStr:(NSString *)hexColorStr {
    
    if(hexColorStr) {
        unsigned int hexValue;
        [[NSScanner scannerWithString:hexColorStr] scanHexInt:&hexValue];
        int a = (hexValue >> 24) & 0xFF;
        int b = (hexValue >> 16) & 0xFF;
        int g = (hexValue >>  8) & 0xFF;
        int r = (hexValue)       & 0xFF;
        GMColor *color = [GMColor colorWithRed:r/255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
        return color;
    } else {
        return nil;
    }
    
}


@end
