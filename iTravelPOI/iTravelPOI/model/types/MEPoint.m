//
//  MEPoint.m
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEMapElement_Protected.h"
#import "MEPoint.h"
#import "MECategory.h"
#import "MEMap.h"
#import "MEBaseEntity_Protected.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEPoint PRIVATE CONSTANTS and C-Methods definitions
//---------------------------------------------------------------------------------------------------------------------
#define EXT_INFO_POINT_NAME     @"@EXT_INFO"
#define EXT_INFO_POINT_ICON_URL @"http://maps.gstatic.com/mapfiles/ms2/micons/earthquake.png"
#define EXT_INFO_POINT_LNG      -101.804811
#define EXT_INFO_POINT_LAT      40.736959

#define DEFAULT_POINT_ICON_URL  @"http://maps.google.com/mapfiles/ms/micons/blue-dot.png"


//*********************************************************************************************************************
#pragma mark -
#pragma mark MEPoint PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEPoint () 


- (void) resetExtInfo;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEPoint implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MEPoint

@synthesize lng = _lng;
@synthesize lat = _lat;

@synthesize categories = _categories;

@synthesize isExtInfo = _isExtInfo;



//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc 
{
    [_categories release];
    
    [super dealloc];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) defaultIconURL {
    return DEFAULT_POINT_ICON_URL;
}

//---------------------------------------------------------------------------------------------------------------------
+ (MEPoint *) pointInMap:(MEMap *)ownerMap {
    
    MEPoint *newPoint = [[MEPoint alloc] init];
    [newPoint resetEntity];
    [ownerMap addPoint:newPoint];
    return [newPoint autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
+ (MEPoint *) extInfoInMap:(MEMap *)ownerMap {
    
    MEPoint *extInfo = [[MEPoint alloc] init];
    [extInfo resetEntity];
    [extInfo resetExtInfo];
    ownerMap.extInfo = extInfo;
    [extInfo setMapOwner:ownerMap];
    return [extInfo autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) isExtInfoName:(NSString *) aName {
    return [aName isEqualToString:EXT_INFO_POINT_NAME];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isExtInfo {
    return [self.name isEqualToString:EXT_INFO_POINT_NAME];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) categories {
    if(!_categories) {
        _categories = [[NSMutableSet alloc] init];
    }
    return _categories;
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted {
    
    // Lo marca como borrado desde la clase base
    [super markAsDeleted];
    
    // Se borra como punto activo y se almacena como punto borrado
    [self.map removePoint:self];
    [self.map addDeletedPoint:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) unmarkAsDeleted {
    
    // Quita la marca de borrado desde la clase base
    [super unmarkAsDeleted];
    
    // Se borra como punto eliminado y se almacena de nuevo como punto activo
    [self.map removeDeletedPoint:self];
    [self.map addPoint:self];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
- (void) resetEntity {
    
    [super resetEntity];
    self.icon = [GMapIcon iconForURL:DEFAULT_POINT_ICON_URL];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) resetExtInfo {
    
    [super resetEntity];
    self.name = EXT_INFO_POINT_NAME;
    self.icon = [GMapIcon iconForURL:EXT_INFO_POINT_ICON_URL];
    self.lng = EXT_INFO_POINT_LNG;
    self.lat = EXT_INFO_POINT_LAT;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBody: (NSMutableString*) sbuf ident:(NSString *) ident {
    
    [super _xmlStringBody:sbuf ident:ident];
    
    // --- Map name ---
    [sbuf appendFormat:@"%@<map>%@</map>\n",ident, self.map.name];
    
    // --- Coordinates ---
    [sbuf appendFormat:@"%@<coordinates>%lf, %lf, 0</coordinates>\n",ident, self.lng, self.lat];
    
    //--- Categories ---
    if([self.categories count] == 0) {
        [sbuf appendFormat:@"%@<categories/>\n",ident];
    }else {
        [sbuf appendFormat:@"%@<categories>",ident];
        BOOL first = true;
        for(MECategory* cat in self.categories) {
            if(!first) {
                [sbuf appendString:@", "];
            }
            [sbuf appendString:cat.name];
            first = false;
        }
        [sbuf appendString:@"</categories>\n"];
    }
    
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "categories" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MECategory *) categoryByGID:(NSString *)gid {
    for(MECategory *cat in self.categories) {
        if([gid isEqualToString: cat.GID]) {
            return cat;
        }
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addCategory:(MECategory *)value {
    
    [(NSMutableSet *)self.categories addObject:value];
    if(![value.points containsObject:self]) [value addPoint: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategory:(MECategory *)value {
    [(NSMutableSet *)self.categories removeObject:value];
    if([value.points containsObject:self]) [value removePoint: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addCategories:(NSSet *)value {    
    for(MECategory *entity in value) {
        [self addCategory:entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategories:(NSSet *)value {
    for(MECategory *entity in value) {
        [self removeCategory:entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllCategories {
    
    NSSet *allCategories = [[NSSet alloc] initWithSet:self.categories];
    [self removeCategories:allCategories];
    [allCategories release];
}


@end
