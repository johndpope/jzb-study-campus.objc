//
// GMTPolyLine.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTPolyLine__IMPL__
#define __GMTItem__PROTECTED__
#define __GMTPlacemark__PROTECTED__

#import "GMTPolyLine.h"
#import "NSString+HTML.h"
#import "NSString+JavaStr.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTPolyLine ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTPolyLine



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMTPolyLine *) emptyPolyLine {
    return [GMTPolyLine emptyPolyLineWithName:@""];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMTPolyLine *) emptyPolyLineWithName:(NSString *)name {

    GMTPolyLine *polyLine = [[GMTPolyLine alloc] initWithName:name];
    return polyLine;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMTPolyLine *) polyLineWithContentOfFeed:(NSDictionary *)feedDict errRef:(NSErrorRef *)errRef {
    return [[GMTPolyLine alloc] initWithContentOfFeed:feedDict errRef:errRef];
}



// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------




// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithName:(NSString *)name {
    
    if ( self = [super initWithName:name] ) {
        self.coordinates = [NSMutableArray array];
        self.width = 1;
        self.color = [GMTColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    return self;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) copyValuesFromItem:(GMTItem *)item {
    
    if(![item isKindOfClass:GMTPolyLine.class]) {
        return;
    }
    
    [super copyValuesFromItem:item];
    
    self.width = ((GMTPolyLine *)item).width;
    self.color = ((GMTPolyLine *)item).color;
    self.coordinates = [NSMutableArray arrayWithArray:((GMTPolyLine *)item).coordinates];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) addCoordWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lng {
    
    CLLocation *coord = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    [self.coordinates addObject:coord];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {
    
    NSMutableString *mutStr = [NSMutableString stringWithString:[super description]];
    [mutStr appendFormat:@"  color = '%@'\n", self.color];
    [mutStr appendFormat:@"  width = '%ld'\n", (unsigned long)self.width];
    [mutStr appendFormat:@"  coordinates = '%@'\n", self.coordinates];
    
    
    
    return mutStr;
}





// =====================================================================================================================
#pragma mark -
#pragma mark PROTECTED methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSMutableArray *) __assertNotNilProperties {
    
    // Chequea las propiedades base
    NSMutableArray *nilProperties = [super __assertNotNilProperties];
    
    // Chequea las propias
    if(!self.descr) [nilProperties addObject:@"descr"];
    if(!self.color) [nilProperties addObject:@"color"];
    if(self.width<=0) [nilProperties addObject:@"width<=0"];
    if(!self.coordinates) [nilProperties addObject:@"coordinates"];
    if(self.coordinates.count<2) [nilProperties addObject:@"coordinates.count<2"];
    
    return nilProperties;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __parseInfoFromFeed:(NSDictionary *)feedDict {
    
    // Parsea la informacion base
    [super __parseInfoFromFeed:feedDict];
    
    //<!-- lon,lat[,alt] varias serapadas por un espacio -->
    NSString *coordinates = [feedDict valueForKeyPath:@"atom:content.Placemark.LineString.coordinates.text"];
    NSArray *splittedStr1 = [coordinates componentsSeparatedByString:@" "];
    for(NSString* singleCoordStr in splittedStr1) {
        
        NSArray *splittedStr2 = [singleCoordStr componentsSeparatedByString:@","];
        if(splittedStr2.count >= 2) {
            CLLocationDegrees longitude = [splittedStr2[0] doubleValue];
            CLLocationDegrees latitude = [splittedStr2[1] doubleValue];
            CLLocation *coord = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            [self.coordinates addObject:coord];
        }
        
    }
    
    // PolyLine color ------
    NSString *hexColorStr = [feedDict valueForKeyPath:@"atom:content.Placemark.Style.LineStyle.color.text"];
    self.color = [self _colorFromHexStr:hexColorStr];
    
    // PolyLine width ------
    NSString *widthStr = [feedDict valueForKeyPath:@"atom:content.Placemark.Style.LineStyle.width.text"];
    self.width = [widthStr integerValue];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) __inner_atomEntryContentWitherrRef:(NSErrorRef *)errRef {
    
    // Contador para los STYLE-IDs del icono
    static NSUInteger s_idCounter = 1;
    
    
    NSMutableString *atomStr = [NSMutableString string];
    
    // Genera la informacion propia de este tipo de Placemark
    s_idCounter++;
    NSString *styleID = [NSString stringWithFormat:@"Style-%ld-%lu", time(0L), (unsigned long)s_idCounter];
    [atomStr appendFormat:@"        <Style  id='%@'><LineStyle><color>%@</color><width>%ld</width></LineStyle></Style>\n",
     styleID,[self _hexStrFromColor:self.color],
     self.width];
    
    //<!-- lon,lat[,alt] -->
    [atomStr appendString:@"        <LineString>\n"];
    [atomStr appendString:@"          <tessellate>0</tessellate>\n"];
    [atomStr appendString:@"          <coordinates>"];
    for(CLLocation *coord in self.coordinates) {
        [atomStr appendFormat:@"%0.6f,%0.6f,0.0 ", coord.coordinate.longitude, coord.coordinate.latitude];
    }
    [atomStr appendString:@"          </coordinates>\n"];
    [atomStr appendString:@"        </LineString>\n"];
    
    return atomStr;
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (GMTColor *) _colorFromHexStr:(NSString *)hexColorStr {
    
    if(hexColorStr) {
        unsigned int hexValue;
        [[NSScanner scannerWithString:hexColorStr] scanHexInt:&hexValue];
        int a = (hexValue >> 24) & 0xFF;
        int b = (hexValue >> 16) & 0xFF;
        int g = (hexValue >>  8) & 0xFF;
        int r = (hexValue)       & 0xFF;
        GMTColor *color = [GMTColor colorWithRed:r/255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];        
        return color;
    } else {
        return nil;
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) _hexStrFromColor:(GMTColor *)color {
    
    if(color) {
        NSString *hexColorStr = [NSString stringWithFormat:@"%02X%02X%02X%02X",
                                 (unsigned)(255.0f*color.alphaComponent),
                                 (unsigned)(255.0f*color.blueComponent),
                                 (unsigned)(255.0f*color.greenComponent),
                                 (unsigned)(255.0f*color.redComponent)];
        return hexColorStr;
    } else {
        return @"00000000";
    }
    
}

@end
