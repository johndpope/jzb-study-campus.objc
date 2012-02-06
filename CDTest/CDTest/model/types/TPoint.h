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

//---------------------------------------------------------------------------------------------------------------------
+ (TPoint *) newInstanceInMap:(TMap *)ownerMap;


//---------------------------------------------------------------------------------------------------------------------
- (void)addCategory:(TCategory *)value ;    
- (void)removeCategory:(TCategory *)value ;
- (void)addCategories:(NSSet *)value ;    
- (void)removeCategories:(NSSet *)value ;


@end
