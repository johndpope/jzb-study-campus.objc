//
// GMTMap.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTMap__IMPL__
#define __GMTItem__PROTECTED__

#import "GMTMap.h"
#import "NSString+JavaStr.h"
#import "NSString+HTML.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE Enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------
#define EMPTY_SUMMARY @"[empty]"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTMap ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTMap


@synthesize summary = _summary;
@synthesize featuresURL = _featuresURL;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMTMap *) emptyMap {
    return [GMTMap emptyMapWithName:@""];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMTMap *) emptyMapWithName:(NSString *)name {

    GMTMap *map = [[GMTMap alloc] initWithName:name];
    return map;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (GMTMap *) mapWithContentOfFeed:(NSDictionary *)feedDict errRef:(NSErrorRef *)errRef {
    return [[GMTMap alloc] initWithContentOfFeed:feedDict errRef:errRef];
}


// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) featuresURL {

    NSUInteger lastIndex = [self.gID lastIndexOf:@"/maps/"];
    if(lastIndex != NSNotFound) {
        NSString *url = [NSString stringWithFormat:@"%@/features/%@/full",
                         [self.gID substringToIndex:lastIndex],
                         [self.gID substringFromIndex:lastIndex + 6]];
        return url;
    } else {
        return nil;
    }
}




// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithName:(NSString *)name {
    
    if ( self = [super initWithName:name] ) {
        self.summary = @"";
    }
    return self;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) copyValuesFromItem:(GMTItem *)item {

    if(![item isKindOfClass:GMTMap.class]) {
        return;
    }
        
    [super copyValuesFromItem:item];
    
    self.summary = ((GMTMap *)item).summary;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSMutableString *) atomEntryContentWithErrRef:(NSErrorRef *)errRef {

    // Informacion base
    NSMutableString *atomStr = [super atomEntryContentWithErrRef:errRef];
    if(!atomStr) return nil;
    
    // Genera la informacion propia
    // Por algun motivo, el "summary" no puede ir vacio, solo con espacios o con "<"
    // AUNQUE ESTE ENTRE UN "CDATA"
    // PORQUE EN ESE CASO EL MAPA NO SE CREA CORRECTAMENTE
    self.summary = [[self.summary trim] replaceStr:@"<" with:@"&lt;"];
    NSString *summary = self.summary!=nil && self.summary.length>0 ? self.summary : EMPTY_SUMMARY;
    [atomStr appendFormat:@"  <atom:summary type='text'>%@</atom:summary>\n", [self __cleanXMLText:summary]];

    return atomStr;
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {
    
    NSMutableString *mutStr = [NSMutableString stringWithString:[super description]];
    [mutStr appendFormat:@"  summary = '%@'\n", self.summary];
    [mutStr appendFormat:@"  featuresURL = '%@'\n", self.featuresURL];
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
    if(!self.summary) [nilProperties addObject:@"summary"];
    
    return nilProperties;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) __parseInfoFromFeed:(NSDictionary *)feedDict {
    
    // Parsea la informacion base
    [super __parseInfoFromFeed:feedDict];

    // Parsea la informacion propia
    self.summary = [[feedDict valueForKeyPath:@"summary.text"] trim];
    if(self.summary == nil) self.summary = @"";
    if([self.summary isEqualToString:EMPTY_SUMMARY]) self.summary = @"";
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------



@end
