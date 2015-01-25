//
// GMTPlacemark.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTPlacemark__IMPL__
#define __GMTItem__PROTECTED__
#define __GMTPlacemark__PROTECTED__

#import "GMTPlacemark.h"
#import "NSString+HTML.h"
#import "NSString+JavaStr.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTPlacemark ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTPlacemark



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------



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
        self.descr = @"";
    }
    return self;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) copyValuesFromItem:(GMTItem *)item {
    
    if(![item isKindOfClass:GMTPlacemark.class]) {
        return;
    }
    
    [super copyValuesFromItem:item];
    
    self.descr = ((GMTPlacemark *)item).descr;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSMutableString *) atomEntryContentWithError:(NSError * __autoreleasing *)err {
    
    // Informacion base
    NSMutableString *atomStr = [super atomEntryContentWithError:err];
    if(err && *err) return nil;
    
    // Genera la informacion propia
    [atomStr appendString:@"  <atom:content type='application/vnd.google-earth.kml+xml'>\n"];
    [atomStr appendString:@"      <Placemark>\n"];
    [atomStr appendFormat:@"        <name>%@</name>\n", [self __cleanXMLText:self.name]];
    [atomStr appendFormat:@"        <description type='html'>%@</description>\n", [self __cleanXMLText:self.descr]];
    
    // Añade la informacion especifica del tipo de Placemark que sea (a sobreescribir)
    [atomStr appendString:[self __inner_atomEntryContentWithError:err]];
    
    // Cierra la informacion
    [atomStr appendString:@"      </Placemark>\n"];
    [atomStr appendString:@"  </atom:content>\n"];
    
    
    return atomStr;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {
    
    NSMutableString *mutStr = [NSMutableString stringWithString:[super description]];
    [mutStr appendFormat:@"  descr                 = '%@'\n", self.descr];
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
    
    return nilProperties;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __parseInfoFromFeed:(NSDictionary *)feedDict {
    
    // Parsea la informacion base
    [super __parseInfoFromFeed:feedDict];
    
    // Parsea de nuevo el nombre
    self.name = [[[feedDict valueForKeyPath:@"atom:content.Placemark.name.text"] gtm_stringByUnescapingFromHTML] trim];

    // Parsea la informacion propia
    self.descr = [[feedDict valueForKeyPath:@"atom:content.Placemark.description.text"] trim];
    if(self.descr == nil) self.descr = @"";
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) __inner_atomEntryContentWithError:(NSError * __autoreleasing *)err {
    return nil;
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------



@end
