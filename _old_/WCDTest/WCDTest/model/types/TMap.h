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
+ (TMap *) insertNew;
+ (TMap *) insertTmpNew;

- (void) clearAllData;
- (void) markAsSynchronized;

//---------------------------------------------------------------------------------------------------------------------
- (void)addPoint:(TPoint *)value ;    
- (void)removePoint:(TPoint *)value ;
- (void)addPoints:(NSSet *)value ;    
- (void)removePoints:(NSSet *)value ;
- (void)removeAllPoints;
- (TPoint *) pointByGID:(NSString *)gid;



- (void)addCategory:(TCategory *)value ;    
- (void)removeCategory:(TCategory *)value ;
- (void)addCategories:(NSSet *)value ;    
- (void)removeCategories:(NSSet *)value ;
- (void)removeAllCategories;
- (TCategory *) categoryByGID:(NSString *)gid;


@end
