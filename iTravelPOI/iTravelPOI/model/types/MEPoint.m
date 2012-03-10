//
//  MEPoint.m
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEPoint.h"
#import "MECategory.h"
#import "MEMap.h"
#import "MEBaseEntity_Protected.h"
#import "ModelService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEPoint PRIVATE CONSTANTS and C-Methods definitions
//---------------------------------------------------------------------------------------------------------------------
#define EXT_INFO_POINT_NAME     @"@EXT_INFO"
#define EXT_INFO_POINT_ICON_URL @"http://maps.gstatic.com/mapfiles/ms2/micons/earthquake.png"
#define EXT_INFO_POINT_LNG      -101.804811
#define EXT_INFO_POINT_LAT      40.736959

#define DEFAULT_POINT_ICON_URL  @"http://maps.google.com/mapfiles/ms/micons/blue-dot.png"


//*********************************************************************************************************************
#pragma mark -
#pragma mark MEPoint PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEPoint () 


@property (nonatomic, assign) BOOL isTemp;

@property (nonatomic, retain) NSNumber* _i_lng;
@property (nonatomic, retain) NSNumber* _i_lat;


- (void) resetExtInfo;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEPoint implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MEPoint

@dynamic _i_lng;
@dynamic _i_lat;

@dynamic map;
@dynamic categories;

@synthesize isTemp = _isTemp;



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
+ (NSEntityDescription *) pointEntity:(NSManagedObjectContext *) ctx {
    NSEntityDescription * _pointEntity = [NSEntityDescription entityForName:@"MEPoint" inManagedObjectContext:ctx];
    return _pointEntity;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) defaultIconURL {
    return DEFAULT_POINT_ICON_URL;
}

//---------------------------------------------------------------------------------------------------------------------
+ (MEPoint *) insertNewInMap:(MEMap *)ownerMap {
    
    NSManagedObjectContext * ctx = [ownerMap managedObjectContext];
    if(ctx) 
    {
        MEPoint *newPoint = (MEPoint *)[[NSManagedObject alloc] initWithEntity:[MEPoint pointEntity:ctx] insertIntoManagedObjectContext:ctx];
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
+ (MEPoint *) insertTmpNewInMap:(MEMap *)ownerMap {
    
    MEPoint *newPoint = (MEPoint *)[[NSManagedObject alloc] initWithEntity:[MEPoint pointEntity:nil] insertIntoManagedObjectContext:nil];
    newPoint.isTemp = true;
    [newPoint resetEntity];
    [ownerMap addPoint:newPoint];
    return [newPoint autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
+ (MEPoint *) insertEmptyExtInfoInMap:(MEMap *)ownerMap {
    
    NSManagedObjectContext * ctx = [ownerMap managedObjectContext];
    if(ctx) 
    {
        MEPoint *extInfo = (MEPoint *)[[NSManagedObject alloc] initWithEntity:[MEPoint pointEntity:ctx] insertIntoManagedObjectContext:ctx];
        extInfo.isTemp = false;
        [extInfo resetEntity];
        [extInfo resetExtInfo];
        ownerMap.extInfo= extInfo;
        extInfo.map = ownerMap;
        return extInfo;
    }
    else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (MEPoint *) insertTmpEmptyExtInfoInMap:(MEMap *)ownerMap {
    
    MEPoint *extInfo = (MEPoint *)[[NSManagedObject alloc] initWithEntity:[MEPoint pointEntity:nil] insertIntoManagedObjectContext:nil];
    extInfo.isTemp = true;
    [extInfo resetEntity];
    [extInfo resetExtInfo];
    ownerMap.extInfo = extInfo;
    extInfo.map = ownerMap;
    return [extInfo autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) isExtInfoName:(NSString *) aName {
    return [aName isEqualToString:EXT_INFO_POINT_NAME];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
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



//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted {
    
    [super markAsDeleted];
    [self.map removePoint:self];
    [self.map addDeletedPoint:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) unmarkAsDeleted {
    
    [super unmarkAsDeleted];
    [self.map removeDeletedPoint:self];
    [self.map addPoint:self];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
- (void) resetEntity {
    
    [super resetEntity];
    self.icon = [GMapIcon iconForURL:DEFAULT_POINT_ICON_URL];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) resetExtInfo {
    
    [super resetEntity];
    self.name = EXT_INFO_POINT_NAME;
    self.icon = [GMapIcon iconForURL:EXT_INFO_POINT_ICON_URL];
    self.lng = EXT_INFO_POINT_LNG;
    self.lat = EXT_INFO_POINT_LAT;
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
        for(MECategory* cat in self.categories) {
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
    
    if(self.isTemp && ![value.points containsObject:self]) [value addPoint: self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)removeCategory:(MECategory *)value {
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
        for(MECategory *entity in value) {
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
        for(MECategory *entity in value) {
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
        for(MECategory *entity in allCategories) {
            if([entity.points containsObject:self]) {
                [entity removePoint: self];
            }
        }
    }
    
    [allCategories release];
    
}


@end
