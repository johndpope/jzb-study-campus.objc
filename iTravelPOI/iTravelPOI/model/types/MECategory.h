//
//  MECategory.h
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MEBaseEntity.h"


@class MECategory, MEMap, MEPoint;


//*********************************************************************************************************************
#pragma mark -
#pragma mark MECategory interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MECategory : MEBaseEntity

@property (nonatomic, retain) MEMap * map;
@property (nonatomic, retain) NSSet* points;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, retain) NSSet* subcategories;
@property (nonatomic, assign) NSUInteger t_displayCount;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MECategory CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSEntityDescription *) categoryEntity;

+ (MECategory *) insertNewInMap:(MEMap *)ownerMap;
+ (MECategory *) insertTmpNewInMap:(MEMap *)ownerMap;

+ (NSArray *)sortCategorized:(NSSet *)categories;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MECategory general INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted;
- (void) unmarkAsDeleted;
- (void) updateToRemoteETag;

- (BOOL) recursiveContainsSubCategory:(MECategory *)subCat;
- (BOOL) recursiveContainsPoint:(MEPoint *)point;

- (NSSet *) allRecursivePoints;
- (NSSet *) allParentCategories;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "categories" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MEPoint *) pointByGID:(NSString *)gid;
- (void)addPoint:(MEPoint *)value;    
- (void)removePoint:(MEPoint *)value;
- (void)addPoints:(NSSet *)value;    
- (void)removePoints:(NSSet *)value;
- (void)removeAllPoints;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "categories" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MECategory *) subcategoryByGID:(NSString *)gid;
- (void)addSubcategory:(MECategory *)value;    
- (void)removeSubcategory:(MECategory *)value;
- (void)addSubcategories:(NSSet *)value;    
- (void)removeSubcategories:(NSSet *)value;
- (void)removeAllSubcategories;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "categories" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MECategory *) categoryByGID:(NSString *)gid;
- (void)addCategory:(MECategory *)value;    
- (void)removeCategory:(MECategory *)value;
- (void)addCategories:(NSSet *)value;    
- (void)removeCategories:(NSSet *)value;
- (void)removeAllCategories;


@end
