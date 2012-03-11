//
//  MECategory.m
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


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


@property (nonatomic, assign) BOOL isTemp;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MECategory implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MECategory


@dynamic map;
@dynamic points;
@dynamic categories;
@dynamic subcategories;

@synthesize isTemp = _isTemp;
@synthesize t_displayCount = _t_displayCount;



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
+ (NSEntityDescription *) categoryEntity:(NSManagedObjectContext *) ctx {
    NSEntityDescription * _categoryEntity = [NSEntityDescription entityForName:@"MECategory" inManagedObjectContext:ctx];
    return _categoryEntity;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) defaultIconURL {
    return DEFAULT_CATEGORY_ICON_URL;
}

//---------------------------------------------------------------------------------------------------------------------
+ (MECategory *) insertNewInMap:(MEMap *)ownerMap {
    
    NSManagedObjectContext * ctx = [ownerMap managedObjectContext];
    if(ctx) 
    {
        MECategory *newCat = (MECategory *)[[NSManagedObject alloc] initWithEntity:[MECategory categoryEntity:ctx] insertIntoManagedObjectContext:ctx];
        newCat.isTemp = false;
        [newCat resetEntity];
        [ownerMap addCategory:newCat];
        return newCat;
    } else {
        return nil;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (MECategory *) insertTmpNewInMap:(MEMap *)ownerMap {
    
    MECategory *newCat = (MECategory *)[[NSManagedObject alloc] initWithEntity:[MECategory categoryEntity:nil] insertIntoManagedObjectContext:nil];
    newCat.isTemp = true;
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



//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) touchAsUpdated {
    [super touchAsUpdated];
    [self.map touchAsUpdated];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted {
    
    [super markAsDeleted];
    [self.map removeCategory:self];
    [self.map addDeletedCategory:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) unmarkAsDeleted {
    
    [super unmarkAsDeleted];
    [self.map removeDeletedCategory:self];
    [self.map addCategory:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateToRemoteETag {
    self.syncETag = [MEBaseEntity calcRemoteCategotyETag];
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
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] addObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    if(self.isTemp && ![value.categories containsObject:self]) [value addCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removePoint:(MEPoint *)value {
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
        for(MEPoint *entity in value) {
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
        for(MEPoint *entity in value) {
            if([entity.categories containsObject:self]) {
                [entity removeCategory: self];
            }
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllPoints {
    
    NSSet *allPoints = [NSSet setWithSet:self.points];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allPoints];
    [[self primitiveValueForKey:@"points"] minusSet:allPoints];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allPoints];
    
    if(self.isTemp) {
        for(MEPoint *entity in allPoints) {
            if([entity.categories containsObject:self]) {
                [entity removeCategory: self];
            }
        }
    }
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
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subcategories"] addObject:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    if(self.isTemp && ![value.categories containsObject:self]) [value addCategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeSubcategory:(MECategory *)value {
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
        for(MECategory *entity in value) {
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
        for(MECategory *entity in value) {
            if([entity.categories containsObject:self]) {
                [entity removeCategory: self];
            }
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllSubcategories {
    
    NSSet *allSubcategories = [NSSet setWithSet:self.subcategories];
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allSubcategories];
    [[self primitiveValueForKey:@"subcategories"] minusSet:allSubcategories];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allSubcategories];
    
    if(self.isTemp) {
        for(MECategory *entity in allSubcategories) {
            if([entity.categories containsObject:self]) {
                [entity removeCategory: self];
            }
        }
    }
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
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] addObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
    
    if(self.isTemp && ![value.subcategories containsObject:self]) [value addSubcategory: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategory:(MECategory *)value {
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
        for(MECategory *entity in value) {
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
        for(MECategory *entity in value) {
            if([entity.subcategories containsObject:self]) {
                [entity removeSubcategory: self];
            }
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeAllCategories {
    
    NSSet *allCategories = [NSSet setWithSet:self.categories];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allCategories];
    [[self primitiveValueForKey:@"categories"] minusSet:allCategories];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:allCategories];
    
    if(self.isTemp) {
        for(MECategory *entity in allCategories) {
            if([entity.subcategories containsObject:self]) {
                [entity removeSubcategory: self];
            }
        }
    }
}


@end
