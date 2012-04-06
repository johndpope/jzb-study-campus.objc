//
//  MEPoint.h
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MEMapElement.h"


@class MEMap, MECategory;



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEPoint interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEPoint : MEMapElement 

@property (nonatomic, assign)   double lng;
@property (nonatomic, assign)   double lat;

@property (nonatomic, retain)   NSSet* categories;

@property (nonatomic, readonly) BOOL   isExtInfo;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEPoint CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MEPoint *) pointInMap:(MEMap *)ownerMap;

+ (NSString *) defaultIconURL;

+ (MEPoint *) extInfoInMap:(MEMap *)map;

+ (BOOL) isExtInfoName:(NSString *) aName;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEPoint general INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEPoint "categories" INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MECategory *) categoryByGID:(NSString *)gid;

- (void)addCategory:(MECategory *)value ;    
- (void)removeCategory:(MECategory *)value ;
- (void)addCategories:(NSSet *)value ;    
- (void)removeCategories:(NSSet *)value ;
- (void)removeAllCategories;


@end
