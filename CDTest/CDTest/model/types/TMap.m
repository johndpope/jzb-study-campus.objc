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


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TMap() {
}

- (void) initEntity;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation TMap

@dynamic points;
@dynamic ExtInfo;
@dynamic categories;


//---------------------------------------------------------------------------------------------------------------------
+ (TMap *) newMapInstance {

    NSManagedObjectContext * ctx = [ModelService sharedInstance].moContext;
    if(ctx) {
        TMap *newMap = [NSEntityDescription insertNewObjectForEntityForName: @"TMap" inManagedObjectContext:ctx];
        [newMap initEntity];
            return newMap;
         }
         else {
             return nil;
    }
}
         

//---------------------------------------------------------------------------------------------------------------------
- (void) initEntity
{
    [super initEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addPointsObject:(TPoint *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] addObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removePointsObject:(TPoint *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"points"] removeObject:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addPoints:(NSSet *)value {    
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"points"] unionSet:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removePoints:(NSSet *)value {
    [self willChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"points"] minusSet:value];
    [self didChangeValueForKey:@"points" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}



- (void)addCategoriesObject:(TCategory *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] addObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCategoriesObject:(TCategory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] removeObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addCategories:(NSSet *)value {    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] unionSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeCategories:(NSSet *)value {
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] minusSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
