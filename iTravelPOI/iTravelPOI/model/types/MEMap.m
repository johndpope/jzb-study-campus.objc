//
//  MEMap.m
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEMap.h"
#import "MEBaseEntity_Protected.h"
#import "MEMapElement_Protected.h"
#import "ModelService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEMap PRIVATE CONSTANTS and C-Methods definitions
//---------------------------------------------------------------------------------------------------------------------
#define DEFAULT_MAP_ICON_URL   @"http://maps.google.com/mapfiles/ms/micons/blue-dot.png"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEMap PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEMap () 

@property (nonatomic, assign) NSUInteger i_cachedPointCount;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEMap implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MEMap


@synthesize points = _points;
@synthesize categories = _categories;
@synthesize extInfo = _extInfo;
@synthesize deletedPoints = _deletedPoints;
@synthesize deletedCategories = _deletedCategories;

@synthesize i_cachedPointCount = _i_cachedPointCount;



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
    [_extInfo release];
    [_deletedPoints release];
    [_deletedCategories release];
    
    [super dealloc];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) defaultIconURL {
    return DEFAULT_MAP_ICON_URL;
}

//---------------------------------------------------------------------------------------------------------------------
+ (MEMap *) map {
    
    MEMap *newMap = [[MEMap alloc] init];
    [newMap resetEntity];
    [MEPoint extInfoInMap:newMap];
    return [newMap autorelease];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark GETTER y SETTER methods
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
- (NSSet *) deletedPoints {
    if(!_deletedPoints) {
        _deletedPoints = [[NSMutableSet alloc] init];
    }
    return _deletedPoints;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) deletedCategories {
    if(!_deletedCategories) {
        _deletedCategories = [[NSMutableSet alloc] init];
    }
    return _deletedCategories;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted {
    
    // Lo marca como borrado desde la clase base
    [super markAsDeleted];
    
    // Limpia las relaciones de sus elementos
    [self removeAllPoints];
    [self removeAllCategories];
    [self removeAllDeletedPoints];
    [self removeAllDeletedCategories];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) unmarkAsDeleted {
    
    // Quita la marca de borrado desde la clase base
    [super unmarkAsDeleted];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSError *) commitChanges {
    //kkkk    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) removeAllPointsAndCategories {
    [self removeAllPoints];
    [self removeAllCategories];
    [self removeAllDeletedPoints];
    [self removeAllDeletedCategories];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsSynchronized {
    
    // Limpia el estado despues de sincronizar
    self.changed = false;
    self.syncStatus = ST_Sync_OK;
    
    self.extInfo.changed = false;
    self.extInfo.syncStatus = ST_Sync_OK;
    
    for(MEPoint* point in self.points) {
        point.changed = false;
        point.syncStatus = ST_Sync_OK;
    }
    
    for(MECategory* cat in self.categories) {
        cat.changed = false;
        cat.syncStatus = ST_Sync_OK;
    }
    
    // Borra definitivamente los elementos marcados para borrar
    NSSet *allDeletedPoints = self.deletedPoints;
    for(MEPoint* point in allDeletedPoints) {
        [self removeDeletedPoint:point];
    }
    NSSet *allCategories = self.deletedCategories;
    for(MECategory* cat in allCategories) {
        [self removeCategory:cat];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (NSUInteger) cachedPointsCount {
    
    if(self.points) {
        return [self.points count];
    } else {
        return self.i_cachedPointCount;
    }
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
- (void) resetEntity
{
    [super resetEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBody: (NSMutableString*) sbuf ident:(NSString *) ident {
    
    unsigned nextIdent = (unsigned)[ident length]+2;
    
    [super _xmlStringBody:sbuf ident:ident];
        
    //--- Categories ---
    if([self.categories count] == 0) {
        [sbuf appendFormat:@"%@<categories/>\n",ident];
    }else {
        [sbuf appendFormat:@"%@<categories>\n",ident];
        for(MECategory* cat in self.categories) {
            [sbuf appendFormat:@"%@\n",[cat toXmlString:nextIdent]];
        }
        [sbuf appendFormat:@"%@</categories>\n",ident];
    }
    
    //--- Points ---
    if([self.points count] == 0) {
        [sbuf appendFormat:@"%@<points/>\n",ident];
    }else {
        [sbuf appendFormat:@"%@<points>\n",ident];
        for(MEPoint* point in self.points) {
            [sbuf appendFormat:@"%@\n", [point toXmlString:nextIdent]];
        }
        [sbuf appendFormat:@"%@</points>\n",ident];
    }
    
    //--- ExtInfoPoint ---
    [sbuf appendFormat:@"%@<ext_info_point/>\n",ident];
    [sbuf appendFormat:@"%@%@\n",ident, [self.extInfo toXmlString:nextIdent]];
    [sbuf appendFormat:@"%@<ext_info_point/>\n",ident];
    
    
    //--- Deleted Categories ---
    if([self.deletedCategories count] == 0) {
        [sbuf appendFormat:@"%@<deleted_categories/>\n",ident];
    }else {
        [sbuf appendFormat:@"%@<deleted_categories>\n",ident];
        for(MECategory* cat in self.deletedCategories) {
            [sbuf appendFormat:@"%@\n",[cat toXmlString:nextIdent]];
        }
        [sbuf appendFormat:@"%@</deleted_categories>\n",ident];
    }
    
    //--- Deleted Points ---
    if([self.deletedPoints count] == 0) {
        [sbuf appendFormat:@"%@<deleted_points/>\n",ident];
    }else {
        [sbuf appendFormat:@"%@<deleted_points>\n",ident];
        for(MEPoint* point in self.deletedPoints) {
            [sbuf appendFormat:@"%@\n", [point toXmlString:nextIdent]];
        }
        [sbuf appendFormat:@"%@</deleted_points>\n",ident];
    }
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "points" INSTANCE public methods
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
    [value setMapOwner:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoint:(MEPoint *)value {

    [(NSMutableSet *)self.points removeObject:value];
    [value removeAllCategories];
    [value setMapOwner:nil];
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
    
    for(MEPoint *entity in self.points) {
        [entity removeAllCategories];
        [entity setMapOwner:nil];
    }
    [(NSMutableSet *)self.points removeAllObjects];
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
    [value setMapOwner:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategory:(MECategory *)value {
    [(NSMutableSet *)self.categories removeObject:value];
    [value removeAllPoints];
    [value removeAllSubcategories];
    [value removeAllCategories];
    [value setMapOwner:nil];
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
    
    for(MECategory *entity in self.categories) {
        [entity removeAllPoints];
        [entity removeAllSubcategories];
        [entity removeAllCategories];
        [entity setMapOwner:nil];
    }
    [(NSMutableSet *)self.categories removeAllObjects];
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "deletedPoints" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MEPoint *) deletedPointByGID:(NSString *)gid {
    for(MEPoint *point in self.deletedPoints) {
        if([gid isEqualToString: point.GID]) {
            return point;
        }
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addDeletedPoint:(MEPoint *)value {    
    [(NSMutableSet *)self.deletedPoints addObject:value];
    [value setMapOwner:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeDeletedPoint:(MEPoint *)value {
    [(NSMutableSet *)self.deletedPoints removeObject:value];
    [value removeAllCategories];
    [value setMapOwner:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addDeletedPoints:(NSSet *)value {    
    for(MEPoint *entity in value) {
        [self addDeletedPoint:entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeDeletedPoints:(NSSet *)value {
    for(MEPoint *entity in value) {
        [self removeDeletedPoint:entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllDeletedPoints {
    
    for(MEPoint *entity in self.deletedPoints) {
        [entity removeAllCategories];
        [entity setMapOwner:nil];
    }
    [(NSMutableSet *)self.deletedPoints removeAllObjects];
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "deletedCategories" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MECategory *) deletedCategoryByGID:(NSString *)gid {
    for(MECategory *cat in self.deletedCategories) {
        if([gid isEqualToString: cat.GID]) {
            return cat;
        }
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addDeletedCategory:(MECategory *)value {    
    [(NSMutableSet *)self.deletedCategories addObject:value];
    [value setMapOwner:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeDeletedCategory:(MECategory *)value {
    [(NSMutableSet *)self.deletedCategories removeObject:value];
    [value removeAllPoints];
    [value removeAllSubcategories];
    [value setMapOwner:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addDeletedCategories:(NSSet *)value {    
    for(MECategory *entity in value) {
        [self addDeletedCategory:entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeDeletedCategories:(NSSet *)value {
    for(MECategory *entity in value) {
        [self removeDeletedCategory:entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllDeletedCategories {
    
    for(MECategory *entity in self.deletedCategories) {
        [entity removeAllPoints];
        [entity removeAllSubcategories];
        [entity setMapOwner:nil];
    }
    [(NSMutableSet *)self.deletedCategories removeAllObjects];
}


@end
