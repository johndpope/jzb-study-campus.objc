//
//  MEMapElement.h
//  iTravelPOI
//
//  Created by JZarzuela on 11/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEMapElement.h"

@class MEMap;


//*********************************************************************************************************************
#pragma mark -
#pragma mark MEBaseEntity PROTECTED methods definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEMapElement(ProtectedMethods)

- (void) setMapOwner:(MEMap *)map;

@end
