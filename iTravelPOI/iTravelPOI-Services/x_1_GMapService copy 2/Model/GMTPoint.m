//
// GMTPoint.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTPoint__IMPL__
#define __GMTItem__PROTECTED__
#define __GMTPlacemark__PROTECTED__

#import "GMTPoint.h"
#import "NSString+HTML.h" 
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTPoint ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTPoint


@synthesize descr = _descr;
@synthesize iconHREF = _iconHREF;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMTPoint *) emptyPoint {
    return [GMTPoint emptyPointWithName:@""];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMTPoint *) emptyPointWithName:(NSString *)name {

    GMTPoint *point = [[GMTPoint alloc] initWithName:name];
    return point;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMTPoint *) pointWithContentOfFeed:(NSDictionary *)feedDict error:(NSError * __autoreleasing *)err {
    return [[GMTPoint alloc] initWithContentOfFeed:feedDict error:err];
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
        self.iconHREF = GM_DEFAULT_POINT_ICON_HREF;
        self.latitude = 0.0;
        self.longitude = 0.0;
    }
    return self;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) copyValuesFromItem:(GMTItem *)item {
    
    if(![item isKindOfClass:GMTPoint.class]) {
        return;
    }
    
    [super copyValuesFromItem:item];
    
    self.iconHREF = ((GMTPoint *)item).iconHREF;
    self.latitude = ((GMTPoint *)item).latitude;
    self.longitude = ((GMTPoint *)item).longitude;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {
    
    NSMutableString *mutStr = [NSMutableString stringWithString:[super description]];
    [mutStr appendFormat:@"  iconHREF = '%@'\n", self.iconHREF];
    [mutStr appendFormat:@"  latitude = '%f'\n", self.latitude];
    [mutStr appendFormat:@"  longitude = '%f'\n", self.longitude];
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
    if(!self.iconHREF) [nilProperties addObject:@"iconHREF"];
    
    return nilProperties;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __parseInfoFromFeed:(NSDictionary *)feedDict {
    
    // Parsea la informacion base
    [super __parseInfoFromFeed:feedDict];
    
    // Parsea la informacion propia    
    self.iconHREF = [[[feedDict valueForKeyPath:@"atom:content.Placemark.Style.IconStyle.Icon.href.text"] gtm_stringByUnescapingFromHTML] trim];
    if(self.iconHREF == nil) self.iconHREF = GM_DEFAULT_POINT_ICON_HREF;
    
    //<!-- lon,lat[,alt] -->
    NSString *coordinates = [feedDict valueForKeyPath:@"atom:content.Placemark.Point.coordinates.text"];
    NSArray *splittedStr = [coordinates componentsSeparatedByString:@","];
    if(splittedStr.count >= 2) {
        self.longitude = [splittedStr[0] doubleValue];
        self.latitude = [splittedStr[1] doubleValue];
    } else {
        self.longitude = 0;
        self.latitude = 0;
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) __inner_atomEntryContentWithError:(NSError * __autoreleasing *)err {
    
    // Contador para los STYLE-IDs del icono
    static NSUInteger s_idCounter = 1;
    

    NSMutableString *atomStr = [NSMutableString string];

    
    // Genera la informacion propia de este tipo de Placemark
    s_idCounter++;
    NSString *styleID = [NSString stringWithFormat:@"Style-%ld-%lu", time(0L), (unsigned long)s_idCounter];
    [atomStr appendFormat:@"        <Style id='%@'><IconStyle><Icon><href><![CDATA[%@]]></href></Icon></IconStyle></Style>\n",
     styleID,
     (self.iconHREF?self.iconHREF:GM_DEFAULT_POINT_ICON_HREF)];
    
    //<!-- lon,lat[,alt] -->
    [atomStr appendString:@"        <Point>\n"];
    [atomStr appendFormat:@"          <coordinates>%0.6f,%0.6f,0.0</coordinates>\n", self.longitude, self.latitude];
    [atomStr appendString:@"        </Point>\n"];
    
    return atomStr;
}



// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
