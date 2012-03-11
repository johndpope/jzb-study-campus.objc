//
//  MEMapElement.m
//  iTravelPOI
//
//  Created by JZarzuela on 11/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEMapElement.h"
#import "MEMap.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark MEMapElement implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MEMapElement


@dynamic map;


//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setChanged:(BOOL)value {
    [super setChanged:value];
    if(value) {
        self.map.changed=YES;
    }
}


@end
