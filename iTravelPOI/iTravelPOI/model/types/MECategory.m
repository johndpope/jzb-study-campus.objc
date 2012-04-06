//
//  MECategory.m
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "MEMapElement_Protected.h"
#import "MECategory.h"
#import "MECategory.h"
#import "MEMap.h"
#import "MEPoint.h"
#import "MEBaseEntity_Protected.h"
#import "ModelService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MECategory PRIVATE CONSTANTS and C-Methods definitions
//---------------------------------------------------------------------------------------------------------------------
#define DEFAULT_CATEGORY_ICON_URL   @"http://maps.google.com/mapfiles/ms/micons/blue-dot.png"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MECategory PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MECategory () 

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MECategory implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MECategory


@synthesize points = _points;
@synthesize categories = _categories;
@synthesize subcategories = _subcategories;
@synthesize t_displayCount = _t_displayCount;



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
    [_points release];
    [_categories release];
    [_subcategories release];
    
    [super dealloc];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) calcRemoteCategotyETag {
    return [MEBaseEntity _calcRemoteCategoryETag];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) defaultIconURL {
    return DEFAULT_CATEGORY_ICON_URL;
}

//---------------------------------------------------------------------------------------------------------------------
+ (MECategory *) categoryInMap:(MEMap *)ownerMap {
    
    MECategory *newCat = [[MECategory alloc] init];
    [newCat resetEntity];
    [ownerMap addCategory:newCat];
    return [newCat autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
// Ordena la lista de categorias poniendo primero a quien es subcategoria de otro y deja al final a las "padre"
+ (NSArray *)sortCategorized:(NSSet *)categories {
    
    NSMutableArray *sortedList = [NSMutableArray array];
    NSMutableArray *originalList = [NSMutableArray arrayWithArray:[categories allObjects]];
    
    while([originalList count] > 0) {
        
        MECategory *cat1 = [originalList objectAtIndex:0];
        [originalList removeObjectAtIndex:0];
        
        BOOL addThisCat = true;
        for(MECategory *cat2 in originalList) {
            if([cat1 recursiveContainsSubCategory:cat2]) {
                addThisCat = false;
                break;
            }
        }
        
        if (addThisCat) {
            // La saca y la da por ordenada
            [sortedList addObject:cat1];
        } else {
            // La retorna para procesarla de nuevo contra el resto de categorias
            [originalList addObject:cat1];
        }
        
    }
    
    // Retorna la lista ordenada por categorizacion
    return [[sortedList copy] autorelease];
}




//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) points {
    if(!_points) {
        _points = [[NSMutableSet alloc] init];
    }
    return _points;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) categories {
    if(!_categories) {
        _categories = [[NSMutableSet alloc] init];
    }
    return _categories;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) subcategories {
    if(!_subcategories) {
        _subcategories = [[NSMutableSet alloc] init];
    }
    return _subcategories;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted {
    
    // Lo marca como borrado desde la clase base
    [super markAsDeleted];
    
    // Se borra como categoria activoa y se almacena como categoria borrada
    [self.map removeCategory:self];
    [self.map addDeletedCategory:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) unmarkAsDeleted {
    
    // Quita la marca de borrado desde la clase base
    [super unmarkAsDeleted];
    
    // Se borra como categoria eliminada y se almacena de nuevo como categoria activa
    [self.map removeDeletedCategory:self];
    [self.map addCategory:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateToRemoteETag {
    self.syncETag = [MEBaseEntity _calcRemoteCategoryETag];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) recursiveContainsSubCategory:(MECategory *)subCat {
    
    if([self.subcategories containsObject: subCat]) {
        return true;
    } else {
        for(MECategory *cat in self.subcategories) {
            if([cat recursiveContainsSubCategory:subCat]) {
                return true;
            }
        }
    }
    return false;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) recursiveContainsPoint:(MEPoint *)point {
    
    if([self.points containsObject: point]) {
        return true;
    } else {
        for(MECategory *cat in self.subcategories) {
            if([cat recursiveContainsPoint:point]) {
                return true;
            }
        }
    }
    return false;
}


//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) allRecursivePoints {
    
    NSMutableSet * set = [NSMutableSet setWithSet:self.points];
    for(MECategory *scat in self.subcategories) {
        [set unionSet:[scat allRecursivePoints]];
    }
    return  set;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) allParentCategories {
    
    NSMutableSet *set = [NSMutableSet set];
    [set unionSet:self.categories];
    for(MECategory *cat in self.categories) {
        [set unionSet:[cat allParentCategories]];
    }
    return set;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
- (void) resetEntity {
    
    [super resetEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBody: (NSMutableString*) sbuf ident:(NSString *) ident {
    
    [super _xmlStringBody:sbuf ident:ident];
    
    // --- Map name ---
    [sbuf appendFormat:@"%@<map>%@</map>\n",ident, self.map.name];
    
    //--- Points ---
    if([self.points count] == 0) {
        [sbuf appendFormat:@"%@<points/>\n",ident];
    }else {
        [sbuf appendFormat:@"%@<points>",ident];
        BOOL first = true;
        for(MEPoint *point in self.points) {
            if(!first) {
                [sbuf appendString:@", "];
            }
            [sbuf appendString:point.name];
            first = false;
        }
        [sbuf appendString:@"</points>\n"];
    }
    
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
    
    //--- Sucategories ---
    if([self.subcategories count] == 0) {
        [sbuf appendFormat:@"%@<subcategories/>\n",ident];
    }else {
        [sbuf appendFormat:@"%@<subcategories>",ident];
        BOOL first = true;
        for(MECategory* cat in self.subcategories) {
            if(!first) {
                [sbuf appendString:@", "];
            }
            [sbuf appendString:cat.name];
            first = false;
        }
        [sbuf appendString:@"</subcategories>\n"];
    }
    
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MECategory "points" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MEPoint *) pointByGID:(NSString *)gid {
    for(MEPoint *point in self.points) {
        if([gid isEqualToString: point.GID]) {
            return point;
        }
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addPoint:(MEPoint *)value {
    [(NSMutableSet *)self.points addObject:value];
    if(![value.categories containsObject:self]) [value addCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoint:(MEPoint *)value {
    [(NSMutableSet *)self.points removeObject:value];
    if([value.categories containsObject:self]) [value removeCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addPoints:(NSSet *)value {    
    for(MEPoint *entity in value) {
        [self addPoint:entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoints:(NSSet *)value {
    for(MEPoint *entity in value) {
        [self removePoint:entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllPoints {
    NSSet *allPoints = [[NSSet alloc] initWithSet:self.points];
    [self removePoints:allPoints];
    [allPoints release];
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MECategory "Subcategory" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MECategory *) subcategoryByGID:(NSString *)gid {
    for(MECategory *cat in self.subcategories) {
        if([gid isEqualToString: cat.GID]) {
            return cat;
        }
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addSubcategory:(MECategory *)value {    
    [(NSMutableSet *)self.subcategories addObject:value];
    if(![value.categories containsObject:self]) [value addCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeSubcategory:(MECategory *)value {
    [(NSMutableSet *)self.subcategories removeObject:value];
    if([value.categories containsObject:self]) [value removeCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addSubcategories:(NSSet *)value {    
    for(MECategory *entity in value) {
        [self addSubcategory:entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeSubcategories:(NSSet *)value {
    for(MECategory *entity in value) {
        [self removeSubcategory:entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllSubcategories {
    
    NSSet *allSubcategories = [[NSSet alloc] initWithSet:self.subcategories];
    for(MECategory *entity in allSubcategories) {
        [self removeSubcategory:entity];
    }
    [allSubcategories release];
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MECategory "Category" INSTANCE public methods
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
    if(![value.subcategories containsObject:self]) [value addSubcategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategory:(MECategory *)value {
    [(NSMutableSet *)self.categories removeObject:value];
    if([value.subcategories containsObject:self]) [value removeSubcategory: self];
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
    for(MECategory *entity in allCategories) {
        [self removeCategory:entity];
    }
    [allCategories release];
}


@end
