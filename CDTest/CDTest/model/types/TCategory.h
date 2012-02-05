//
//  TCategory.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TBaseEntity.h"

@class TCategory, TMap, TPoint;

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TCategory : TBaseEntity {
@private
}

@property (nonatomic, retain) NSSet* points;
@property (nonatomic, retain) NSSet* subcategories;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, retain) TMap * map;

//---------------------------------------------------------------------------------------------------------------------
+ (TCategory *) newInstanceInMap:(TMap *)ownerMap;



//---------------------------------------------------------------------------------------------------------------------
- (void)addPoint:(TPoint *)value ;    
- (void)removePoint:(TPoint *)value ;
- (void)addPoints:(NSSet *)value ;    
- (void)removePoints:(NSSet *)value ;

- (void)addSubcategory:(TCategory *)value ;    
- (void)removeSubcategory:(TCategory *)value ;
- (void)addSubcategories:(NSSet *)value ;    
- (void)removeSubcategories:(NSSet *)value ;

- (void)addCategory:(TCategory *)value ;    
- (void)removeCategory:(TCategory *)value ;
- (void)addCategories:(NSSet *)value ;    
- (void)removeCategories:(NSSet *)value ;


@end
