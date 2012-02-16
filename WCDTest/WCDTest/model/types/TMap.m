//
//  TMap.m
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ModelService.h"
#import "TMap.h"
#import "TCategory.h"
#import "TPoint.h"
#import "TBaseEntity_Protected.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TMap() {
}

@property (nonatomic, assign) BOOL isTemp;

- (void) resetEntity;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation TMap

@dynamic points;
@dynamic extInfo;
@dynamic categories;

@synthesize isTemp;



//---------------------------------------------------------------------------------------------------------------------
+ (NSEntityDescription *) entity {
    static NSEntityDescription *entity = nil;
    
    if(!entity) {
        NSManagedObjectContext * ctx = [ModelService sharedInstance].moContext;
        entity = [NSEntityDescription entityForName:@"TMap" inManagedObjectContext:ctx];
    }
    return entity;
}



//---------------------------------------------------------------------------------------------------------------------
+ (TMap *) insertNew {
    
    NSManagedObjectContext * ctx = [ModelService sharedInstance].moContext;
    if(ctx) 
    {
        TMap *newMap = [[NSManagedObject alloc] initWithEntity:[TMap entity] insertIntoManagedObjectContext:ctx];
        newMap.isTemp = false;
        [newMap resetEntity];
        [TPoint insertEmptyExtInfoInMap:newMap];
        return newMap;
    }
    else {
        return nil;
    }
}


//---------------------------------------------------------------------------------------------------------------------
+ (TMap *) insertTmpNew {
    
    TMap *newMap = [[NSManagedObject alloc] initWithEntity:[TMap entity] insertIntoManagedObjectContext:nil];
    newMap.isTemp = true;
    [newMap resetEntity];
    [TPoint insertTmpEmptyExtInfoInMap:newMap];
    return [newMap autorelease];
}


//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) resetEntity
{
    [super resetEntity];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) clearAllData {
    [self removeAllPoints];
    [self removeAllCategories];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsSynchronized {
    
    self.changed = false;
    self.syncStatus = ST_Sync_OK;
    
    self.extInfo.changed = false;
    self.extInfo.syncStatus = ST_Sync_OK;
    
    for(TPoint* point in self.points) {
        point.changed = false;
        point.syncStatus = ST_Sync_OK;
    }
    
    for(TCategory* cat in self.categories) {
        cat.changed = false;
        cat.syncStatus = ST_Sync_OK;
    }
    
    // borrado definitivo de elementos previamente marcados para borrar
    
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
        for(TCategory* cat in self.categories) {
            [sbuf appendFormat:@"%@\n",[cat toXmlString:nextIdent]];
        }
        [sbuf appendFormat:@"%@</categories>\n",ident];
    }
    
    //--- Points ---
    if([self.points count] == 0) {
        [sbuf appendFormat:@"%@<points/>\n",ident];
    }else {
        [sbuf appendFormat:@"%@<points>\n",ident];
        for(TPoint* point in self.points) {
            [sbuf appendFormat:@"%@\n", [point toXmlString:nextIdent]];
        }
        [sbuf appendFormat:@"%@</points>\n",ident];
    }
    
    //--- ExtInfoPoint ---
    [sbuf appendFormat:@"%@<ext_info_point/>\n",ident];
    [sbuf appendFormat:@"%@%@\n",ident, [self.extInfo toXmlString:nextIdent]];
    [sbuf appendFormat:@"%@<ext_info_point/>\n",ident];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addPoint:(TPoint *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] addObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    if(self.isTemp) value.map=self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoint:(TPoint *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] removeObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    [value removeAllCategories];
    if(self.isTemp) value.map=nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addPoints:(NSSet *)value {    
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"points"] unionSet:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    if(self.isTemp) {
        for(TPoint *entity in value) {
            entity.map = self;
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoints:(NSSet *)value {
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"points"] minusSet:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    
    for(TPoint *entity in value) {
        [entity removeAllCategories];
        if(self.isTemp) {
            entity.map = nil;
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllPoints {
    
    NSSet *allPoints = [[NSSet alloc] initWithSet:self.points];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allPoints];
    [[self primitiveValueForKey:@"points"] minusSet:allPoints];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allPoints];
    
    for(TPoint *entity in allPoints) {
        [entity removeAllCategories];
        if(self.isTemp) {
            entity.map = nil;
        }
    }

    [allPoints release];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (TPoint *) pointByGID:(NSString *)gid {
    for(TPoint *point in self.points) {
        if([gid isEqualToString: point.GID]) {
            return point;
        }
    }
    return nil;
}



//---------------------------------------------------------------------------------------------------------------------
- (void)addCategory:(TCategory *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] addObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    if(self.isTemp) value.map=self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategory:(TCategory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] removeObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    [value removeAllPoints];
    [value removeAllSubcategories];
    if(self.isTemp) value.map=nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addCategories:(NSSet *)value {    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] unionSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    if(self.isTemp) {
        for(TCategory *entity in self.categories) {
            entity.map = self;
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategories:(NSSet *)value {
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] minusSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    
    for(TCategory *entity in self.categories) {
        [entity removeAllPoints];
        [entity removeAllSubcategories];
        if(self.isTemp) {
            entity.map = nil;
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllCategories {
    
    NSSet *allCategories = [[NSSet alloc] initWithSet:self.points];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allCategories];
    [[self primitiveValueForKey:@"categories"] minusSet:allCategories];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allCategories];
    
    for(TCategory *entity in allCategories) {
        [entity removeAllPoints];
        [entity removeAllSubcategories];
        if(self.isTemp) {
            entity.map = nil;
        }
    }
    
    [allCategories release];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (TCategory *) categoryByGID:(NSString *)gid {
    for(TCategory *cat in self.categories) {
        if([gid isEqualToString: cat.GID]) {
            return cat;
        }
    }
    return nil;
}


@end
