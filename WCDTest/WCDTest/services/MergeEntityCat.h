//
//  MergeEntityCat.h
//  CDTest
//
//  Created by jzarzuela on 06/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBaseEntity.h"
#import "TPoint.h"
#import "TCategory.h"
#import "TMap.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TBaseEntity (MergeTBaseEntityCat)

- (void) mergeFrom:(TBaseEntity *) other withConflit:(BOOL) thereWasConflit;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TPoint (MergeTPointCat)

- (void) mergeFrom:(TPoint *) other withConflit:(BOOL) thereWasConflit;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TCategory (MergeTCategoryCat)

- (void) mergeFrom:(TCategory *) other withConflit:(BOOL) thereWasConflit;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TMap (MergeTMapCat)

- (void) mergeFrom:(TMap *) other withConflit:(BOOL) thereWasConflit;

@end


