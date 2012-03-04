//
//  MEMap.m
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEMap.h"
#import "MEBaseEntity_Protected.h"
#import "ModelService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEMap PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEMap () 


@property (nonatomic, retain) NSNumber * _i_wasDeleted;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEMap implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MEMap

@dynamic _i_wasDeleted;
@dynamic points;
@dynamic categories;
@dynamic extInfo;
@dynamic deletedPoints;
@dynamic deletedCategories;

@synthesize wasDeleted = _wasDeleted;



//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSEntityDescription *) mapEntity:(NSManagedObjectContext *)ctx {
    
    NSEntityDescription *_mapEntity = [NSEntityDescription entityForName:@"MEMap" inManagedObjectContext:ctx];
    return _mapEntity;
}



//---------------------------------------------------------------------------------------------------------------------
+ (MEMap *) insertNew:(NSManagedObjectContext *) ctx {
    
    if(ctx) 
    {
        MEMap *newMap = [[NSManagedObject alloc] initWithEntity:[MEMap mapEntity:ctx] insertIntoManagedObjectContext:ctx];
        [newMap resetEntity];
        [MEPoint insertEmptyExtInfoInMap:newMap];
        return newMap;
    }
    else {
        return nil;
    }
}


//---------------------------------------------------------------------------------------------------------------------
+ (MEMap *) insertTmpNew {
    
    MEMap *newMap = [[NSManagedObject alloc] initWithEntity:[MEMap mapEntity:nil] insertIntoManagedObjectContext:nil];
    [newMap resetEntity];
    [MEPoint insertTmpEmptyExtInfoInMap:newMap];
    return [newMap autorelease];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) wasDeleted {
    return [self._i_wasDeleted boolValue];
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted {
    
    [super markAsDeleted];
    
    // Lo marca como borrado
    self._i_wasDeleted = [NSNumber numberWithBool:YES];
    
    // "recuerda" sus elementos para eliminarlos luego
    NSSet *allPoints = [NSSet setWithSet:self.points];
    NSSet *allCategories = [NSSet setWithSet:self.categories];
    NSSet *allDeletedPoints = [NSSet setWithSet:self.deletedPoints];
    NSSet *allDeletedCategories = [NSSet setWithSet:self.deletedCategories];
    
    // Limpia las relaciones de sus elementos
    [self removeAllPoints];
    [self removeAllCategories];
    [self removeAllDeletedPoints];
    [self removeAllDeletedCategories];
    
    // --------------------------------------------------
    // BORRA DEFINITIVAMENTE LOS SUB-ELEMENTOS DEL MODELO
    for(MEBaseEntity *entity in allPoints) {
        [entity deleteFromModel];
    }
    for(MEBaseEntity *entity in allCategories) {
        [entity deleteFromModel];
    }
    for(MEBaseEntity *entity in allDeletedPoints) {
        [entity deleteFromModel];
    }
    for(MEBaseEntity *entity in allDeletedCategories) {
        [entity deleteFromModel];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) unmarkAsDeleted {
    [super unmarkAsDeleted];
    self._i_wasDeleted = [NSNumber numberWithBool:NO];
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
        [point deleteFromModel];
    }
    NSSet *allCategories = self.deletedCategories;
    for(MECategory* cat in allCategories) {
        [self removeCategory:cat];
        [cat deleteFromModel];
    }
    
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
- (void) resetEntity
{
    [super resetEntity];
    self._i_wasDeleted = [NSNumber numberWithBool:NO];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBody: (NSMutableString*) sbuf ident:(NSString *) ident {
    
    unsigned nextIdent = (unsigned)[ident length]+2;
    
    [super _xmlStringBody:sbuf ident:ident];
    
    [sbuf appendFormat:@"%@<wasDeleted>%d</wasDeleted>\n", ident, self.wasDeleted];
    
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
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] addObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    value.map=self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoint:(MEPoint *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] removeObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    [value removeAllCategories];
    value.map=nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addPoints:(NSSet *)value {    
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"points"] unionSet:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    for(MEPoint *entity in value) {
        entity.map = self;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoints:(NSSet *)value {
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"points"] minusSet:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    
    for(MEPoint *entity in value) {
        [entity removeAllCategories];
        entity.map = nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllPoints {
    
    NSSet *allPoints = [NSSet setWithSet:self.points];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allPoints];
    [[self primitiveValueForKey:@"points"] minusSet:allPoints];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allPoints];
    
    for(MEPoint *entity in allPoints) {
        [entity removeAllCategories];
        entity.map = nil;
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
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] addObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    value.map=self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategory:(MECategory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] removeObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    [value removeAllPoints];
    [value removeAllSubcategories];
    [value removeAllCategories];
    value.map=nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addCategories:(NSSet *)value {    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] unionSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    for(MECategory *entity in value) {
        entity.map = self;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategories:(NSSet *)value {
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] minusSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    
    for(MECategory *entity in value) {
        [entity removeAllPoints];
        [entity removeAllSubcategories];
        [entity removeAllCategories];
        entity.map = nil;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllCategories {
    
    NSSet *allCategories = [NSSet setWithSet:self.categories];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allCategories];
    [[self primitiveValueForKey:@"categories"] minusSet:allCategories];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allCategories];
    
    for(MECategory *entity in allCategories) {
        [entity removeAllPoints];
        [entity removeAllSubcategories];
        [entity removeAllCategories];
        entity.map = nil;
    }
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
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"deletedPoints" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"deletedPoints"] addObject:value];
    [self didChangeValueForKey:@"deletedPoints" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    value.map=self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeDeletedPoint:(MEPoint *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"deletedPoints" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"deletedPoints"] removeObject:value];
    [self didChangeValueForKey:@"deletedPoints" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    [value removeAllCategories];
    value.map=nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addDeletedPoints:(NSSet *)value {    
    [self willChangeValueForKey:@"deletedPoints" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"deletedPoints"] unionSet:value];
    [self didChangeValueForKey:@"deletedPoints" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    for(MEPoint *entity in value) {
        entity.map = self;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeDeletedPoints:(NSSet *)value {
    [self willChangeValueForKey:@"deletedPoints" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"deletedPoints"] minusSet:value];
    [self didChangeValueForKey:@"deletedPoints" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    
    for(MEPoint *entity in value) {
        [entity removeAllCategories];
        entity.map = nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllDeletedPoints {
    
    NSSet *allDeletedPoints = [NSSet setWithSet:self.deletedPoints];
    [self willChangeValueForKey:@"deletedPoints" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allDeletedPoints];
    [[self primitiveValueForKey:@"deletedPoints"] minusSet:allDeletedPoints];
    [self didChangeValueForKey:@"deletedPoints" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allDeletedPoints];
    
    for(MEPoint *entity in allDeletedPoints) {
        [entity removeAllCategories];
        entity.map = nil;
    }
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
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"deletedCategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"deletedCategories"] addObject:value];
    [self didChangeValueForKey:@"deletedCategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    value.map=self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeDeletedCategory:(MECategory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"deletedCategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"deletedCategories"] removeObject:value];
    [self didChangeValueForKey:@"deletedCategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    [value removeAllPoints];
    [value removeAllSubcategories];
    value.map=nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addDeletedCategories:(NSSet *)value {    
    [self willChangeValueForKey:@"deletedCategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"deletedCategories"] unionSet:value];
    [self didChangeValueForKey:@"deletedCategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    for(MECategory *entity in value) {
        entity.map = self;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeDeletedCategories:(NSSet *)value {
    [self willChangeValueForKey:@"deletedCategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"deletedCategories"] minusSet:value];
    [self didChangeValueForKey:@"deletedCategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    
    for(MECategory *entity in value) {
        [entity removeAllPoints];
        [entity removeAllSubcategories];
        entity.map = nil;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllDeletedCategories {
    
    NSSet *allDeletedCategories = [NSSet setWithSet:self.deletedCategories];
    [self willChangeValueForKey:@"deletedCategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allDeletedCategories];
    [[self primitiveValueForKey:@"deletedCategories"] minusSet:allDeletedCategories];
    [self didChangeValueForKey:@"deletedCategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allDeletedCategories];
    
    for(MECategory *entity in allDeletedCategories) {
        [entity removeAllPoints];
        [entity removeAllSubcategories];
        entity.map = nil;
    }
}


@end
