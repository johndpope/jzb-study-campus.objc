//
//  TPoint.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TBaseEntity.h"

@class TCategory, TCoordinates, TMap;


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TPoint : TBaseEntity {
@private
}

@property (nonatomic, retain) TMap * map;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, assign) double lng;
@property (nonatomic, assign) double lat;
@property (readonly, nonatomic, assign) BOOL isExtInfo;

//---------------------------------------------------------------------------------------------------------------------
+ (TPoint *) insertNewInMap:(TMap *)ownerMap;
+ (TPoint *) insertTmpNewInMap:(TMap *)ownerMap;

+ (TPoint *) insertEmptyExtInfoInMap:(TMap *)map;
+ (TPoint *) insertTmpEmptyExtInfoInMap:(TMap *)map;

+ (BOOL) isExtInfoName:(NSString *) aName;


//---------------------------------------------------------------------------------------------------------------------
- (void)addCategory:(TCategory *)value ;    
- (void)removeCategory:(TCategory *)value ;
- (void)addCategories:(NSSet *)value ;    
- (void)removeCategories:(NSSet *)value ;
- (void)removeAllCategories;


@end
