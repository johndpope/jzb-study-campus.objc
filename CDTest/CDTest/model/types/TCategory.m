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

- (void) initEntity;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation TCategory

@dynamic points;
@dynamic subcategories;
@dynamic categories;
@dynamic map;


//---------------------------------------------------------------------------------------------------------------------
+ (TCategory *) insertInCtx: (NSManagedObjectContext *) ctx withMap:(TMap *)ownerMap{
    
    NSManagedObjectContext * ctx2 = [ModelService sharedInstance].moContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TCategory" inManagedObjectContext:ctx2];
    //if(ctx) 
    {
        TCategory *newCat = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:ctx];
        [newCat initEntity];
        newCat.map = ownerMap;
        [ownerMap addCategory:newCat];
        return newCat;
    }
//    else {
//        return nil;
//    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (TCategory *) insertNewInMap:(TMap *)ownerMap {
    
    NSManagedObjectContext * ctx = [ModelService sharedInstance].moContext;
    return [TCategory insertInCtx:ctx withMap:ownerMap];
}

//---------------------------------------------------------------------------------------------------------------------
+ (TCategory *) insertNewTmpInMap:(TMap *)ownerMap {
    
//    NSManagedObjectContext * ctx = [ModelService sharedInstance].moTmpContext;
    NSManagedObjectContext * ctx = nil;
    
    return [TCategory insertInCtx:ctx withMap:ownerMap];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) initEntity {
    
    [super initEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateToRemoteETag {
    self.syncETag = [TBaseEntity calcRemoteCategotyETag];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBody: (NSMutableString*) sbuf ident:(NSString *) ident {
    
    [super _xmlStringBody:sbuf ident:ident];
    
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
    NSLog(@"---- addPoint ----");
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] addObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    [value addCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoint:(TPoint *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] removeObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addPoints:(NSSet *)value {    
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"points"] unionSet:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoints:(NSSet *)value {
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"points"] minusSet:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllPoints {
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:nil];
    [[self primitiveValueForKey:@"points"] removeAllObjects];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:nil];
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
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeSubcategory:(TCategory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subcategories"] removeObject:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addSubcategories:(NSSet *)value {    
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"subcategories"] unionSet:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeSubcategories:(NSSet *)value {
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"subcategories"] minusSet:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllSubcategories {
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:nil];
    [[self primitiveValueForKey:@"subcategories"] removeAllObjects];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:nil];
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
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategory:(TCategory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] removeObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addCategories:(NSSet *)value {    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] unionSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategories:(NSSet *)value {
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] minusSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllCategories {
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:nil];
    [[self primitiveValueForKey:@"categories"] removeAllObjects];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:nil];
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
