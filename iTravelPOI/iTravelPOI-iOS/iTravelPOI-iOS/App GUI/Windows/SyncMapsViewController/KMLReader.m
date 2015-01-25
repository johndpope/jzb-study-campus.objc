//
//  KMLReader.m
//  JZBTest
//
//  Created by Snow Leopard User on 15/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KMLReader.h"
#import "SimpleXMLReader.h"
#import "NSString+JavaStr.h"
#import "NSString+HTML.h"
#import "BaseCoreDataService.h"
#import "MMap.h"
#import "MIcon.h"
#import "MPoint.h"
#import "MPolyLine.h"



//----------------------------------------------------------------------------
// PRIVATE METHODS
//----------------------------------------------------------------------------
@interface KMLReader () 


@end




@implementation KMLReader



//---------------------------------------------------------------------------------------------------------------------
+ (void) importKmlFiles {

    NSError *err = nil;
    NSString *importPath = [KMLReader _importPath];
    
    NSArray *dirContents =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:importPath error:&err];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"];
    NSArray *onlyKMLs = [dirContents filteredArrayUsingPredicate:fltr];
    
    for(NSString *kmlFileName in onlyKMLs) {
        NSString *kmlFilePath = [NSString stringWithFormat:@"%@/%@",importPath,kmlFileName];
        [KMLReader _readKMLFileFromPath:kmlFilePath];
    }

}

//---------------------------------------------------------------------------------------------------------------------
+ (void) _readKMLFileFromPath: (NSString *)filePath {
    
    NSManagedObjectContext *moContext = BaseCoreDataService.moContext;
    NSError *err = nil;

    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm isReadableFileAtPath: filePath]) {
        return;
    }
  
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingFromURL:url error:&err];
    NSData *data = [fh readDataToEndOfFile];
    
    NSDictionary *dict = [SimpleXMLReader dictionaryForXMLData:data error:&err];

    NSDictionary *stylesDict = [KMLReader _parseStyles:dict];

    // MAPA
    MMap *map = [KMLReader _createMapFromDict:dict];


    // POINTS & POLYLINEs
    NSArray *placemarks = [dict valueForKeyPath:@"kml.Document.Placemark"];
    if([placemarks isKindOfClass:[NSDictionary class]]) {
        placemarks = [NSArray arrayWithObject:placemarks];
    }
    for(NSDictionary *placemark in placemarks) {

        if([placemark objectForKey:@"Point"]) {
            [KMLReader _createPointFromDict:placemark styles:stylesDict inMap:map];
        } else if([placemark objectForKey:@"LineString"]) {
            [KMLReader _createPolyLineFromDict:placemark styles:stylesDict inMap:map];
        } else {
            NSLog(@"Error: Unknown placemark type");
        }

    }
    
    [BaseCoreDataService saveChangesInContext:moContext];

}

//---------------------------------------------------------------------------------------------------------------------
+ (MMap *) _createMapFromDict:(NSDictionary *)dict {

    NSManagedObjectContext *moContext = BaseCoreDataService.moContext;

    NSString *mapName = [KMLReader _valueFromNode:@"kml.Document.name.text" dict:dict];
    NSString *mapSummary = [KMLReader _valueFromNode:@"kml.Document.description.text" dict:dict];
    
    NSArray *maps = [MMap mapsWithName:mapName inContext:moContext];
    [maps enumerateObjectsUsingBlock:^(MMap *map, NSUInteger idx, BOOL *stop) {
        [moContext deleteObject:map];
    }];
    
    MMap *map = [MMap emptyMapWithName:mapName inContext:moContext];
    [map updateSummary:mapSummary];

    return map;
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) _createPointFromDict:(NSDictionary *)placemark styles:(NSDictionary *)stylesDict inMap:(MMap *)map {
    
    NSManagedObjectContext *moContext = BaseCoreDataService.moContext;
    
    NSString *poiName = [KMLReader _valueFromNode:@"name.text" dict:placemark];
    NSString *poiDesc = [KMLReader _valueFromNode:@"description.text" dict:placemark];
    NSString *poiStyleUrl = [KMLReader _valueFromNode:@"styleUrl.text" dict:placemark];
    NSString *iconHREF = [stylesDict objectForKey:poiStyleUrl];
    NSString *poiCoord = [KMLReader _valueFromNode:@"Point.coordinates.text" dict:placemark];
    
    MPoint *point = [MPoint emptyPointWithName:poiName inMap:map];
    [point updateFromCombinedDescAndTagsInfo:poiDesc];
    [point updateIcon:[MIcon iconForHref:iconHREF inContext:moContext]];
    
    //<!-- lon,lat[,alt] -->
    double lat = 0,lng = 0;
    NSArray *splittedStr = [poiCoord componentsSeparatedByString:@","];
    if(splittedStr.count == 3) {
        lng = [splittedStr[0] doubleValue];
        lat = [splittedStr[1] doubleValue];
    }
    [point updateLatitude:lat longitude:lng];
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) _createPolyLineFromDict:(NSDictionary *)placemark styles:(NSDictionary *)stylesDict inMap:(MMap *)map {
    
    NSManagedObjectContext *moContext = BaseCoreDataService.moContext;
    
    NSString *poiName = [KMLReader _valueFromNode:@"name.text" dict:placemark];
    NSString *poiDesc = [KMLReader _valueFromNode:@"description.text" dict:placemark];
    NSString *poiStyleUrl = [KMLReader _valueFromNode:@"styleUrl.text" dict:placemark];
    NSString *hexColorStr = [stylesDict objectForKey:poiStyleUrl];
    NSString *poiCoords = [KMLReader _valueFromNode:@"LineString.coordinates.text" dict:placemark];
    

    MPolyLine *polyLine = [MPolyLine emptyPolyLineWithName:poiName inMap:map];
    [polyLine updateFromCombinedDescAndTagsInfo:poiDesc];
    
    //<!-- lon,lat[,alt] -->
    NSMutableArray *locations = [NSMutableArray array];
    NSArray *splittedStr1 = [poiCoords componentsSeparatedByString:@" "];
    for(NSString* singleCoordStr in splittedStr1) {
        NSArray *splittedStr2 = [singleCoordStr componentsSeparatedByString:@","];
        if(splittedStr2.count == 3) {
            CLLocationDegrees longitude = [splittedStr2[0] doubleValue];
            CLLocationDegrees latitude = [splittedStr2[1] doubleValue];
            CLLocation *coord = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            [locations addObject:coord];
        }
    }
    [polyLine setCoordinatesFromLocations:locations];

    
    
    // PolyLine color ------
    if(hexColorStr) {
        unsigned int hexValue;
        [[NSScanner scannerWithString:hexColorStr] scanHexInt:&hexValue];
        int a = (hexValue >> 24) & 0xFF;
        int b = (hexValue >> 16) & 0xFF;
        int g = (hexValue >>  8) & 0xFF;
        int r = (hexValue)       & 0xFF;
        UIColor *color = [UIColor colorWithRed:r/255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
        polyLine.color = color;
    } else {
        polyLine.color = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.6f];
    }


}

//---------------------------------------------------------------------------------------------------------------------
+ (NSMutableDictionary *) _parseStyles:(NSDictionary *)dict {

    NSMutableDictionary *stylesDict = [NSMutableDictionary dictionary];
    
    NSArray *styles = [dict valueForKeyPath:@"kml.Document.Style"];
    if([styles isKindOfClass:[NSDictionary class]]) {
        styles = [NSArray arrayWithObject:styles];
    }
    
    for(NSDictionary *style in styles) {
        
        NSString *styleValue;
        NSString *styleID = [KMLReader _valueFromNode:@"id" dict:style];
        
        if([style objectForKey:@"IconStyle"]) {
            styleValue = [KMLReader _valueFromNode:@"IconStyle.Icon.href.text" dict:style];
        } else if([style objectForKey:@"LineStyle"]) {
            styleValue = [KMLReader _valueFromNode:@"LineStyle.color.text" dict:style];
        } else {
            NSLog(@"Error: Unknown placemark style type");
        }
        
        if(styleID && styleValue) {
            [stylesDict setObject:styleValue forKey:[NSString stringWithFormat:@"#%@", styleID]];
        } else {
            NSLog(@"Error: There should be style ID and Value");
        }
    }

    return stylesDict;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _valueFromNode:(NSString *)name dict:(NSDictionary *)dict {
    
    NSString *value = [dict valueForKeyPath:name];
    value = [value gtm_stringByUnescapingFromHTML];
    NSString *trimmed = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmed;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _importPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullImportPath = [documentsDirectory stringByAppendingPathComponent:@"/import/"];
    
    NSError *error = nil;
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:fullImportPath withIntermediateDirectories:YES attributes:nil error:&error];
    if(!result && error==nil) {
        [KMLReader _showError:@"Error creating 'importKml' folder"];
        return nil;
    }
    
    // Retorna el resultado
    return fullImportPath;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) _showError:(NSString *)msg {
    
    UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"KMLReader"
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: @"Ok"
                                              otherButtonTitles: nil];
    [someError show];
}






@end
