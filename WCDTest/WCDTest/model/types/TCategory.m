//
//  TCategory.m
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ModelService.h"
#import "TCategory.h"
#import "TCategory.h"
#import "TMap.h"
#import "TPoint.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TCategory() {
}

@property (nonatomic, assign) BOOL isTemp;

- (void) resetEntity;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation TCategory

@dynamic points;
@dynamic subcategories;
@dynamic categories;
@dynamic map;

@synthesize isTemp;



//---------------------------------------------------------------------------------------------------------------------
+ (NSEntityDescription *) entity {
    static NSEntityDescription *entity = nil;
    
    if(!entity) {
        NSManagedObjectContext * ctx = [ModelService sharedInstance].moContext;
        entity = [NSEntityDescription entityForName:@"TCategory" inManagedObjectContext:ctx];
    }
    return entity;
}


//---------------------------------------------------------------------------------------------------------------------
+ (TCategory *) insertNewInMap:(TMap *)ownerMap {
    
    NSManagedObjectContext * ctx = [ModelService sharedInstance].moContext;
    if(ctx) 
    {
        TCategory *newCat = [[NSManagedObject alloc] initWithEntity:[TCategory entity] insertIntoManagedObjectContext:ctx];
        newCat.isTemp = false;
        [newCat resetEntity];
        [ownerMap addCategory:newCat];
        return newCat;
    }
    else {
        return nil;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (TCategory *) insertTmpNewInMap:(TMap *)ownerMap {
    
    TCategory *newCat = [[NSManagedObject alloc] initWithEntity:[TCategory entity] insertIntoManagedObjectContext:nil];
    newCat.isTemp = true;
    [newCat resetEntity];
    [ownerMap addCategory:newCat];
    return [newCat autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) resetEntity {
    
    [super resetEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateToRemoteETag {
    self.syncETag = [TBaseEntity calcRemoteCategotyETag];
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
        for(TPoint *point in self.points) {
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
        for(TCategory* cat in self.categories) {
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
        for(TCategory* cat in self.subcategories) {
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
- (void)addPoint:(TPoint *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] addObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    if(self.isTemp && ![value.categories containsObject:self]) [value addCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoint:(TPoint *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] removeObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    if(self.isTemp && [value.categories containsObject:self]) [value removeCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addPoints:(NSSet *)value {    
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"points"] unionSet:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    if(self.isTemp) {
        for(TPoint *entity in value) {
            if(![entity.categories containsObject:self]) {
                [entity addCategory: self];
            }
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoints:(NSSet *)value {
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"points"] minusSet:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    
    if(self.isTemp) {
        for(TPoint *entity in value) {
            if([entity.categories containsObject:self]) {
                [entity removeCategory: self];
            }
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllPoints {

    NSSet *allPoints = [[NSSet alloc] initWithSet:self.points];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allPoints];
    [[self primitiveValueForKey:@"points"] minusSet:allPoints];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allPoints];
    
    if(self.isTemp) {
        for(TPoint *entity in allPoints) {
            if([entity.categories containsObject:self]) {
                [entity removeCategory: self];
            }
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
- (void)addSubcategory:(TCategory *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subcategories"] addObject:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    if(self.isTemp && ![value.categories containsObject:self]) [value addCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeSubcategory:(TCategory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subcategories"] removeObject:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    if(self.isTemp && [value.categories containsObject:self]) [value removeCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addSubcategories:(NSSet *)value {    
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"subcategories"] unionSet:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    if(self.isTemp) {
        for(TCategory *entity in value) {
            if(![entity.categories containsObject:self]) {
                [entity addCategory: self];
            }
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeSubcategories:(NSSet *)value {
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"subcategories"] minusSet:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    
    if(self.isTemp) {
        for(TCategory *entity in value) {
            if([entity.categories containsObject:self]) {
                [entity removeCategory: self];
            }
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllSubcategories {
    
    NSSet *allSubcategories = [[NSSet alloc] initWithSet:self.subcategories];
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allSubcategories];
    [[self primitiveValueForKey:@"subcategories"] minusSet:allSubcategories];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allSubcategories];
    
    if(self.isTemp) {
        for(TCategory *entity in allSubcategories) {
            if([entity.categories containsObject:self]) {
                [entity removeCategory: self];
            }
        }
    }
    
    [allSubcategories release];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (TCategory *) subcategoryByGID:(NSString *)gid {
    for(TCategory *cat in self.subcategories) {
        if([gid isEqualToString: cat.GID]) {
            return cat;
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
    
    if(self.isTemp && ![value.subcategories containsObject:self]) [value addSubcategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategory:(TCategory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] removeObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    if(self.isTemp && [value.subcategories containsObject:self]) [value removeSubcategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addCategories:(NSSet *)value {    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] unionSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    if(self.isTemp) {
        for(TCategory *entity in value) {
            if(![entity.subcategories containsObject:self]) {
                [entity addSubcategory: self];
            }
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategories:(NSSet *)value {
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] minusSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    
    if(self.isTemp) {
        for(TCategory *entity in value) {
            if([entity.subcategories containsObject:self]) {
                [entity removeSubcategory: self];
            }
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllCategories {

    NSSet *allCategories = [[NSSet alloc] initWithSet:self.categories];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allCategories];
    [[self primitiveValueForKey:@"categories"] minusSet:allCategories];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allCategories];
    
    if(self.isTemp) {
        for(TCategory *entity in allCategories) {
            if([entity.subcategories containsObject:self]) {
                [entity removeSubcategory: self];
            }
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
