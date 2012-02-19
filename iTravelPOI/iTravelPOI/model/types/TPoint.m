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
#import "TBaseEntity_Protected.h"


#define EXT_INFO_POINT_NAME     @"@EXT_INFO"
#define EXT_INFO_POINT_ICON_URL @"http://maps.gstatic.com/mapfiles/ms2/micons/earthquake.png"
#define EXT_INFO_POINT_LNG      -101.804811
#define EXT_INFO_POINT_LAT      40.736959


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TPoint() 

@property (nonatomic, assign) BOOL isTemp;

@property (nonatomic, retain) NSNumber* _i_lng;
@property (nonatomic, retain) NSNumber* _i_lat;

- (void) resetEntity;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation TPoint

@dynamic map;
@dynamic categories;
@dynamic _i_lng;
@dynamic _i_lat;

@synthesize isTemp;



//---------------------------------------------------------------------------------------------------------------------
+ (NSEntityDescription *) entity {
    static NSEntityDescription *entity = nil;
    
    if(!entity) {
        NSManagedObjectContext * ctx = [ModelService sharedInstance].moContext;
        entity = [NSEntityDescription entityForName:@"TPoint" inManagedObjectContext:ctx];
    }
    return entity;
}


//---------------------------------------------------------------------------------------------------------------------
+ (TPoint *) insertNewInMap:(TMap *)ownerMap {
    
    NSManagedObjectContext * ctx = [ModelService sharedInstance].moContext;
    if(ctx) 
    {
        TPoint *newPoint = [[NSManagedObject alloc] initWithEntity:[TPoint entity] insertIntoManagedObjectContext:ctx];
        newPoint.isTemp = false;
        [newPoint resetEntity];
        [ownerMap addPoint:newPoint];
        return newPoint;
    }
    else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (TPoint *) insertTmpNewInMap:(TMap *)ownerMap {
    
    TPoint *newPoint = [[NSManagedObject alloc] initWithEntity:[TPoint entity] insertIntoManagedObjectContext:nil];
    newPoint.isTemp = true;
    [newPoint resetEntity];
    [ownerMap addPoint:newPoint];
    return [newPoint autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) resetExtInfo:(TPoint *) extInfo {
    
    extInfo.name = EXT_INFO_POINT_NAME;
    extInfo.iconURL = EXT_INFO_POINT_ICON_URL;
    extInfo.lng = EXT_INFO_POINT_LNG;
    extInfo.lat = EXT_INFO_POINT_LAT;
}

//---------------------------------------------------------------------------------------------------------------------
+ (TPoint *) insertEmptyExtInfoInMap:(TMap *)ownerMap {
    
    NSManagedObjectContext * ctx = [ModelService sharedInstance].moContext;
    if(ctx) 
    {
        TPoint *extInfo = [[NSManagedObject alloc] initWithEntity:[TPoint entity] insertIntoManagedObjectContext:ctx];
        extInfo.isTemp = false;
        [extInfo resetEntity];
        [TPoint resetExtInfo:extInfo];
        ownerMap.extInfo= extInfo;
        //extInfo.map = ownerMap; No se puede porque lo añade al conjunto de puntos
        return extInfo;
    }
    else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (TPoint *) insertTmpEmptyExtInfoInMap:(TMap *)ownerMap {
    
    TPoint *extInfo = [[NSManagedObject alloc] initWithEntity:[TPoint entity] insertIntoManagedObjectContext:nil];
    extInfo.isTemp = true;
    [extInfo resetEntity];
    [TPoint resetExtInfo:extInfo];
    ownerMap.extInfo = extInfo;
    //extInfo.map = ownerMap; No se puede porque lo añade al conjunto de puntos
    return [extInfo autorelease];
}


//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) isExtInfoName:(NSString *) aName {
    return [aName isEqualToString:EXT_INFO_POINT_NAME];
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
- (BOOL) isExtInfo {
    return [self.name isEqualToString:EXT_INFO_POINT_NAME];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBody: (NSMutableString*) sbuf ident:(NSString *) ident {
    
    [super _xmlStringBody:sbuf ident:ident];
    
    // --- Map name ---
    [sbuf appendFormat:@"%@<map>%@</map>\n",ident, self.map.name];

    // --- Coordinates ---
    [sbuf appendFormat:@"%@<coordinates>%lf, %lf, 0</coordinates>\n",ident, self.lng, self.lat];
    
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

    if(self.isTemp && ![value.points containsObject:self]) [value addPoint: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategory:(TCategory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] removeObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];

    if(self.isTemp && [value.points containsObject:self]) [value removePoint: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)addCategories:(NSSet *)value {    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] unionSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    if(self.isTemp) {
        for(TCategory *entity in value) {
            if(![entity.points containsObject:self]) {
                [entity addPoint: self];
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
            if([entity.points containsObject:self]) {
                [entity removePoint: self];
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
            if([entity.points containsObject:self]) {
                [entity removePoint: self];
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
