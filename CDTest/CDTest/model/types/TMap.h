//
//  TMap.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TBaseEntity.h"

@class TCategory, TPoint;


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TMap : TBaseEntity {
}

    @property (nonatomic, retain) NSSet* points;
    @property (nonatomic, retain) TPoint * extInfo;
    @property (nonatomic, retain) NSSet* categories;

//---------------------------------------------------------------------------------------------------------------------
+ (TMap *) newInstance;

- (void) markAsSynchonized;

//---------------------------------------------------------------------------------------------------------------------
- (void)addPoint:(TPoint *)value ;    
- (void)removePoint:(TPoint *)value ;
- (void)addPoints:(NSSet *)value ;    
- (void)removePoints:(NSSet *)value ;

- (void)addCategory:(TCategory *)value ;    
- (void)removeCategory:(TCategory *)value ;
- (void)addCategories:(NSSet *)value ;    
- (void)removeCategories:(NSSet *)value ;

@end
