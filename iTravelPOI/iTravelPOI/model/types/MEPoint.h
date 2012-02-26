//
//  MEPoint.h
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MEBaseEntity.h"


@class MEMap, MECategory;



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEPoint interfade definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEPoint : MEBaseEntity {
@private
}

@property (nonatomic, assign)   double lng;
@property (nonatomic, assign)   double lat;
@property (nonatomic, readonly) BOOL   isExtInfo;
@property (nonatomic, retain)   MEMap * map;
@property (nonatomic, retain)   NSSet* categories;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEPoint CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MEPoint *) insertNewInMap:(MEMap *)ownerMap;
+ (MEPoint *) insertTmpNewInMap:(MEMap *)ownerMap;

+ (MEPoint *) insertEmptyExtInfoInMap:(MEMap *)map;
+ (MEPoint *) insertTmpEmptyExtInfoInMap:(MEMap *)map;

+ (BOOL) isExtInfoName:(NSString *) aName;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEPoint general INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted;
- (void) unmarkAsDeleted;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEMap "categories" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MECategory *) categoryByGID:(NSString *)gid;
- (void)addCategory:(MECategory *)value ;    
- (void)removeCategory:(MECategory *)value ;
- (void)addCategories:(NSSet *)value ;    
- (void)removeCategories:(NSSet *)value ;
- (void)removeAllCategories;


@end
