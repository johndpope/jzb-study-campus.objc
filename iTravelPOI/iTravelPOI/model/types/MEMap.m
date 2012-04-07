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
#define BODY_ALREADY_READ     -1


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
@synthesize persistentID = _persistentID;



//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        _points = [[NSMutableSet alloc] init];
        _categories = [[NSMutableSet alloc] init];
        _deletedPoints = [[NSMutableSet alloc] init];
        _deletedCategories = [[NSMutableSet alloc] init];
        _i_cachedPointCount = BODY_ALREADY_READ;
        _persistentID = nil;
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
    [_persistentID release];
    
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
    
    if(self.cachedPointsCount == BODY_ALREADY_READ) {
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
- (void) writeHeader:(NSMutableDictionary *)dict {
    [self writeToDictionary:dict];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) readHeader:(NSDictionary *)dict {
    [self readFromDictionary:dict];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) writeData:(NSMutableDictionary *)dict {
    
    // Graba los puntos del mapa (SOLO los datos, SIN sus relaciones)
    NSMutableArray *pointList = [NSMutableArray array];
    for(MEPoint *point in self.points) {
        NSMutableDictionary *pointDict = [NSMutableDictionary dictionary];
        [point writeToDictionary:pointDict];
        [pointList addObject:pointDict];
    }
    [dict setValue:pointList forKey:@"PointList"];
    
    
    // Graba las categorias del mapa (SOLO los datos, SIN sus relaciones)
    NSMutableArray *catList = [NSMutableArray array];
    for(MECategory *cat in self.categories) {
        NSMutableDictionary *catDict = [NSMutableDictionary dictionary];
        [cat writeToDictionary:catDict];
        [catList addObject:catDict];
    }
    [dict setValue:catList forKey:@"CategoryList"];
    
    
    // Graba los puntos borrados del mapa (SOLO los datos, SIN sus relaciones)
    NSMutableArray *delPointList = [NSMutableArray array];
    for(MEPoint *point in self.deletedPoints) {
        NSMutableDictionary *pointDict = [NSMutableDictionary dictionary];
        [point writeToDictionary:pointDict];
        [pointList addObject:pointDict];
    }
    [dict setValue:delPointList forKey:@"DeletedPointList"];
    
    
    // Graba las categorias borradas del mapa (SOLO los datos, SIN sus relaciones)
    NSMutableArray *delCatList = [NSMutableArray array];
    for(MECategory *cat in self.deletedCategories) {
        NSMutableDictionary *catDict = [NSMutableDictionary dictionary];
        [cat writeToDictionary:catDict];
        [catList addObject:catDict];
    }
    [dict setValue:delCatList forKey:@"DeletedCategoryList"];
    
    
    // Graba la informacion extendida
    NSMutableDictionary *extPointDict = [NSMutableDictionary dictionary];
    [self.extInfo writeToDictionary:extPointDict];
    [dict setValue:extPointDict forKey:@"ExtPointInfo"];
    
    
    // Graba las relaciones de las categorias con los puntos y sus subcategorias
    NSMutableArray *catRelList = [NSMutableArray array];
    for(MECategory *cat in self.categories) {
        
        NSMutableArray *pointRelList = [NSMutableArray array];
        for(MEPoint *point in cat.points) {
            [pointRelList addObject:point.GID];
        }
        
        NSMutableArray *subcatRelList = [NSMutableArray array];
        for(MECategory *subcat in cat.subcategories) {
            [subcatRelList addObject:subcat.GID];
        }
        
        NSMutableDictionary *catRelInfoDict = [NSMutableDictionary dictionary];
        [catRelInfoDict setValue:cat.GID       forKey:@"GID"];
        [catRelInfoDict setValue:pointRelList  forKey:@"points"];
        [catRelInfoDict setValue:subcatRelList forKey:@"categories"];
        
        [catRelList addObject:catRelInfoDict];
    }
    [dict setValue:catRelList forKey:@"CategoryRelationships"];

}

//---------------------------------------------------------------------------------------------------------------------
- (void) readData:(NSDictionary *)dict {
    
    _i_cachedPointCount = BODY_ALREADY_READ;
    
    [self removeAllPoints];
    [self removeAllCategories];
    [self removeAllDeletedPoints];
    [self removeAllDeletedCategories];
    
    
    // Lee los puntos del mapa (SOLO los datos, SIN sus relaciones)
    NSArray *pointList = [dict valueForKey:@"PointList"];
    for(NSDictionary *pointDict in pointList) {
        MEPoint *point = [MEPoint pointInMap:self];
        [point readFromDictionary:pointDict];
    }
    
    
    // Lee las categorias del mapa (SOLO los datos, SIN sus relaciones)
    NSArray *catList = [dict valueForKey:@"CategoryList"];
    for(NSDictionary *catDict in catList) {
        MECategory *cat = [MECategory categoryInMap:self];
        [cat readFromDictionary:catDict];
    }
    
    
    // Lee los puntos borrados del mapa (SOLO los datos, SIN sus relaciones)
    NSArray *delPointList = [dict valueForKey:@"DeletedPointList"];
    for(NSDictionary *delPointDict in delPointList) {
        MEPoint *point = [MEPoint pointInMap:nil];
        [point readFromDictionary:delPointDict];
        [self addDeletedPoint:point];
    }
    
    
    // Lee las categorias borradas del mapa (SOLO los datos, SIN sus relaciones)
    NSArray *delCatList = [dict valueForKey:@"DeletedCategoryList"];
    for(NSDictionary *delCatDict in delCatList) {
        MECategory *cat = [MECategory categoryInMap:nil];
        [cat readFromDictionary:delCatDict];
        [self addDeletedCategory:cat];
    }
    
    
    // Lee la informacion extendida
    MEPoint *extPoint = [MEPoint pointInMap:nil];
    NSDictionary *extPointDict = [dict valueForKey:@"ExtPointInfo"];
    [extPoint readFromDictionary:extPointDict];
    self.extInfo = extPoint;
    
    
    // Lee las relaciones de las categorias con los puntos y sus subcategorias
    NSArray *catRelList = [dict valueForKey:@"CategoryRelationships"];
    for(NSDictionary *catRelInfoDict in catRelList) {
        
        NSString *catGID = [catRelInfoDict valueForKey:@"GID"];
        MECategory *cat = [self categoryByGID:catGID];
        
        NSArray *pointRelList = [catRelInfoDict valueForKey:@"points"];
        for(NSString *pointGID in pointRelList) {
            MEPoint *point = [self pointByGID:pointGID];
            [cat addPoint:point];
        }
        
        NSArray *subcatRelList = [catRelInfoDict valueForKey:@"categories"];
        for(NSString *subcatGID in subcatRelList) {
            MECategory *subCat = [self categoryByGID:subcatGID];
            [cat addSubcategory:subCat];
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) readFromDictionary:(NSDictionary *)dic {
    
    [super readFromDictionary:dic];
    
    
    NSNumber *tCachedPointsCount = [dic valueForKey:@"CachedPointsCount"];
    self.i_cachedPointCount = [tCachedPointsCount unsignedIntValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) writeToDictionary:(NSMutableDictionary *)dic {
    
    // Datos de cabecera
    [super writeToDictionary:dic];
    
    NSNumber *tCachedPointsCount = [NSNumber numberWithUnsignedInt:self.i_cachedPointCount];
    [dic setValue:tCachedPointsCount forKey:@"CachedPointsCount"];
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
