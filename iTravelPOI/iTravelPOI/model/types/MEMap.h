//
//  MEMap.h
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MEBaseEntity.h"
#import "MECategory.h"
#import "MEPoint.h"


@class MECategory, MEPoint;


//*********************************************************************************************************************
#pragma mark -
#pragma mark MEMap interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEMap : MEBaseEntity

@property (nonatomic, assign) BOOL wasDeleted;

@property (nonatomic, retain) NSSet* points;
@property (nonatomic, retain) NSSet* categories;

@property (nonatomic, retain) MEPoint * extInfo;

@property (nonatomic, retain) NSSet* deletedPoints;
@property (nonatomic, retain) NSSet* deletedCategories;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSEntityDescription *) mapEntity:(NSManagedObjectContext *)ctx;

+ (MEMap *) insertNew:(NSManagedObjectContext *) ctx;
+ (MEMap *) insertTmpNew;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap general INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted;
- (void) unmarkAsDeleted;

// Limpia el estado de sincronizacion y borrar DEFINITIVAMENTE los elementos marcados como borrados
- (void) markAsSynchronized;
- (void) removeAllPointsAndCategories;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "points" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MEPoint *) pointByGID:(NSString *)gid;
- (void) addPoint:(MEPoint *)value ;    
- (void) removePoint:(MEPoint *)value ;
- (void) addPoints:(NSSet *)value ;    
- (void) removePoints:(NSSet *)value ;
- (void) removeAllPoints;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "categories" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MECategory *) categoryByGID:(NSString *)gid;
- (void) addCategory:(MECategory *)value ;    
- (void) removeCategory:(MECategory *)value ;
- (void) addCategories:(NSSet *)value ;    
- (void) removeCategories:(NSSet *)value ;
- (void) removeAllCategories;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "deletedPoints" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MEPoint *) deletedPointByGID:(NSString *)gid;
- (void) addDeletedPoint:(MEPoint *)value ;    
- (void) removeDeletedPoint:(MEPoint *)value ;
- (void) addDeletedPoints:(NSSet *)value ;    
- (void) removeDeletedPoints:(NSSet *)value ;
- (void) removeAllDeletedPoints;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "deletedCategories" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MECategory *) deletedCategoryByGID:(NSString *)gid;
- (void) addDeletedCategory:(MECategory *)value ;    
- (void) removeDeletedCategory:(MECategory *)value ;
- (void) addDeletedCategories:(NSSet *)value ;    
- (void) removeDeletedCategories:(NSSet *)value ;
- (void) removeAllDeletedCategories;


@end
