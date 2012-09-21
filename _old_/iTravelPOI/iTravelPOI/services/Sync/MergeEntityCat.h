//
//  MergeEntityCat.h
//  CDTest
//
//  Created by jzarzuela on 06/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEBaseEntity.h"
#import "MEPoint.h"
#import "MECategory.h"
#import "MEMap.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MEBaseEntity (MergeMEBaseEntityCat)

- (void) mergeFrom:(MEBaseEntity *) other withConflict:(BOOL) thereWasConflit;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MEPoint (MergeMEPointCat)

- (void) mergeFrom:(MEPoint *) other withConflict:(BOOL) thereWasConflit;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MECategory (MergeMECategoryCat)

- (void) mergeFrom:(MECategory *) other withConflict:(BOOL) thereWasConflit;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MEMap (MergeMEMapCat)

- (void) mergeFrom:(MEMap *) other withConflict:(BOOL) thereWasConflit;

@end


