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
@dynamic extInfo;
@dynamic categories;


//---------------------------------------------------------------------------------------------------------------------
+ (TMap *) newInstance {

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
- (void) markAsSynchonized {
    
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


@end
