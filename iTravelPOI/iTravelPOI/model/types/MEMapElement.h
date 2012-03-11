//
//  MEMapElement.h
//  iTravelPOI
//
//  Created by JZarzuela on 11/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEBaseEntity.h"

@class MEMap;


//*********************************************************************************************************************
#pragma mark -
#pragma mark MEMapElement interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEMapElement : MEBaseEntity

@property (nonatomic, retain) MEMap * map;

@end
