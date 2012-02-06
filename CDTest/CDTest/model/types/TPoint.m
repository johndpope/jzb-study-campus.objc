//
//  TPoint.m
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelService.h"
#import "TPoint.h"
#import "TCategory.h"
#import "TMap.h"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TPoint() {
}

@property (nonatomic, retain) NSNumber* _i_lng;
@property (nonatomic, retain) NSNumber* _i_lat;

- (void) initEntity;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation TPoint

@dynamic map;
@dynamic categories;
@dynamic _i_lng;
@dynamic _i_lat;


//---------------------------------------------------------------------------------------------------------------------
+ (TPoint *) insertEntityInMap:(TMap *)ownerMap {
    
    NSManagedObjectContext * ctx = [ModelService sharedInstance].moContext;
    if(ctx) {
        TPoint *newPoint = [NSEntityDescription insertNewObjectForEntityForName: @"TPoint" inManagedObjectContext:ctx];
        [newPoint initEntity];
        newPoint.map = ownerMap;
        return newPoint;
    }
    else {
        return nil;
    }
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
- (double) lng {
    return [self._i_lng doubleValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (double) lat {
    return [self._i_lat doubleValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setLng:(double)lng {
    self._i_lng = [NSNumber numberWithDouble:lng];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setLat:(double)lat {
    self._i_lat = [NSNumber numberWithDouble:lat];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBody: (NSMutableString*) sbuf ident:(NSString *) ident {
    
    [super _xmlStringBody:sbuf ident:ident];
    
    // --- Coordinates ---
    [sbuf appendFormat:@"%@<coordinates>%d, %d, 0<coordinates/>\n",ident, self.lng, self.lat];
    
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
