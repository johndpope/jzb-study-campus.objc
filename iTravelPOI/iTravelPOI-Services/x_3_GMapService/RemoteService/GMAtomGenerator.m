//
// GMAtomGenerator.m
// GMAtomGenerator
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMAtomGenerator_IMPL__
#import "GMAtomGenerator.h"

#import "DDLog.h"
#import "NSString+HTML.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMAtomGenerator ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMAtomGenerator



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) fullAtomEntryFromItem:(id<GMItem>)item {
    
    NSString *atomItemStr = [self partialAtomEntryFromItem:item];
    if(!atomItemStr) return nil;
    
    NSMutableString *atomStr = [NSMutableString string];
    [atomStr appendString:@"<?xml version='1.0' encoding='UTF-8'?>\n"];
    [atomStr appendString:@"<atom:entry xmlns='http://www.opengis.net/kml/2.2'\n"];
    [atomStr appendString:@"            xmlns:atom='http://www.w3.org/2005/Atom'>\n"];
    [atomStr appendString:atomItemStr];
    [atomStr appendString:@"</atom:entry>\n"];
    
    return atomStr;

}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) partialAtomEntryFromItem:(id<GMItem>)item {

    if([item conformsToProtocol:@protocol(GMMap)]) {
        return [self _atomEntryFromMap:(id<GMMap>)item];
    } else {
        return [self _atomEntryFromPlacemark:(id<GMPoint>)item];
    }
}





// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSMutableString *) _atomEntryFromItem:(id<GMItem>)item {
    
    NSMutableString *atomStr = [NSMutableString string];
    
    // Genera el texto del ATOM para GMItem
    if(item.gID != nil && item.gID.length > 0 && item.wasSynchronized) {
        [atomStr appendFormat:@"  <atom:id>%@</atom:id>\n", item.gID];
        [atomStr appendFormat:@"  <atom:link rel='edit' type='application/atom+xml' href='%@'/>\n", [self _editLinkFor:item]];
    }
    
    [atomStr appendFormat:@"  <atom:published>%@</atom:published>\n", [self _stringFromDate:item.published_Date]];
    [atomStr appendFormat:@"  <atom:updated>%@</atom:updated>\n", [self _stringFromDate:item.updated_Date]];
    
    [atomStr appendFormat:@"  <atom:title type='text'>%@</atom:title>\n", [self __cleanXMLText:item.name]];
    
    // Retorna el resultado
    return atomStr;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSMutableString *) _atomEntryFromMap:(id<GMMap>)map {

    // Genera la informacion base GMItem
    NSMutableString *atomStr = [self _atomEntryFromItem:map];
    
    // Genera la informacion propia de GMMap
    // Por algun motivo, el "summary" no puede ir vacio, solo con espacios o con "<"
    // AUNQUE ESTE ENTRE UN "CDATA"
    // PORQUE EN ESE CASO EL MAPA NO SE CREA CORRECTAMENTE
    NSString *summary = [[map.summary trim] replaceStr:@"<" with:@"&lt;"];
    if(!summary || summary.length==0) summary = GM_MAP_EMPTY_SUMMARY;
    [atomStr appendFormat:@"  <atom:summary type='text'>%@</atom:summary>\n", [self __cleanXMLText:summary]];

    // Retorna el resultado
    return atomStr;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSMutableString *) _atomEntryFromPlacemark:(id<GMPlacemark>)placemark {
    
    // Genera la informacion base GMItem
    NSMutableString *atomStr = [self _atomEntryFromItem:placemark];
    
    // Genera la informacion propia de GMPlacemark
    [atomStr appendString:@"  <atom:content type='application/vnd.google-earth.kml+xml'>\n"];
    [atomStr appendString:@"      <Placemark>\n"];
    [atomStr appendFormat:@"        <name>%@</name>\n", [self __cleanXMLText:placemark.name]];
    [atomStr appendFormat:@"        <description type='html'>%@</description>\n", [self __cleanXMLText:placemark.descr]];
    
    // Añade la informacion especifica del tipo de Placemark que sea
    if([placemark conformsToProtocol:@protocol(GMPoint)]) {
        [self _inner_addAtomEntryFromPoint:(id<GMPoint>)placemark toAtomStr:atomStr];
    } else if([placemark conformsToProtocol:@protocol(GMPolyLine)]) {
        [self _inner_addAtomEntryFromPolyLine:(id<GMPolyLine>)placemark  toAtomStr:atomStr];
    } else {
        // No deberia llegar aqui
        @throw [NSException exceptionWithName:@"GMAtomGenerator" reason:[NSString stringWithFormat:@"Unknown placemark class: %@", placemark.class] userInfo:nil];
    }
    
    // Cierra la informacion
    [atomStr appendString:@"      </Placemark>\n"];
    [atomStr appendString:@"  </atom:content>\n"];

    // Retorna el resultado
    return atomStr;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _inner_addAtomEntryFromPoint:(id<GMPoint>)point toAtomStr:(NSMutableString *)atomStr {
    
    // Contador para los STYLE-IDs del icono
    static NSUInteger s_idCounter = 1;

    
    // Genera la informacion propia de GMPoint
    s_idCounter++;
    NSString *styleID = [NSString stringWithFormat:@"Style-%ld-%lu", time(0L), (unsigned long)s_idCounter];
    [atomStr appendFormat:@"        <Style id='%@'><IconStyle><Icon><href><![CDATA[%@]]></href></Icon></IconStyle></Style>\n",
     styleID,
     (point.iconHREF?point.iconHREF:GM_DEFAULT_POINT_ICON_HREF)];
    
    //<!-- lon,lat[,alt] -->
    [atomStr appendString:@"        <Point>\n"];
    [atomStr appendFormat:@"          <coordinates>%@</coordinates>\n", point.coordinates.stringValue];
    [atomStr appendString:@"        </Point>\n"];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSMutableString *) _inner_addAtomEntryFromPolyLine:(id<GMPolyLine>)polyLine toAtomStr:(NSMutableString *)atomStr {
    
    // Contador para los STYLE-IDs del icono
    static NSUInteger s_idCounter = 1;

    // Genera la informacion propia de GMPolyLine
    s_idCounter++;
    NSString *styleID = [NSString stringWithFormat:@"Style-%ld-%lu", time(0L), (unsigned long)s_idCounter];
    [atomStr appendFormat:@"        <Style  id='%@'><LineStyle><color>%@</color><width>%ld</width></LineStyle></Style>\n",
     styleID,
     [self _hexStrFromColor:polyLine.color],
     polyLine.width];
    
    //<!-- lon,lat[,alt] -->
    [atomStr appendString:@"        <LineString>\n"];
    [atomStr appendString:@"          <tessellate>0</tessellate>\n"];
    [atomStr appendString:@"          <coordinates>"];
    for(GMCoordinates *coord in polyLine.coordinatesList) {
        [atomStr appendFormat:@"%@ ", coord.stringValue];
    }
    [atomStr appendString:@"          </coordinates>\n"];
    [atomStr appendString:@"        </LineString>\n"];
    
    
    // Retorna el resultado
    return atomStr;
}


// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) __cleanXMLText:(NSString *)text {
    return [NSString stringWithFormat:@"<![CDATA[%@]]>", text];
    //return [text gtm_stringByEscapingForHTML];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _stringFromDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:GM_DATE_FORMAT];
    // The Z at the end of your string represents Zulu which is UTC
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _editLinkFor:(id<GMItem>)item {
    
    NSUInteger lastIndex = [item.gID lastIndexOf:@"/"];
    if(lastIndex != NSNotFound) {
        NSString *url = [NSString stringWithFormat:@"%@/full%@",
                         [item.gID substringToIndex:lastIndex],
                         [item.gID substringFromIndex:lastIndex]];
        return url;
    } else {
        return nil;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _hexStrFromColor:(GMColor *)color {
    
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
