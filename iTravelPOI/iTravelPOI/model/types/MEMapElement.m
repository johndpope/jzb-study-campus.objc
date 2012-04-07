//
//  MEMapElement.m
//  iTravelPOI
//
//  Created by JZarzuela on 11/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEMapElement_Protected.h"
#import "MEBaseEntity_Protected.h"
#import "MEMap.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark MEMapElement implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MEMapElement


@synthesize map = _map;



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

//---------------------------------------------------------------------------------------------------------------------
- (void) setMapOwner:(MEMap *)map {
    _map = map;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------


//*********************************************************************************************************************
#pragma mark -
#pragma mark PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _xmlStringBody: (NSMutableString*) sbuf ident:(NSString *) ident {
    
    [super _xmlStringBody:sbuf ident:ident];
    
    // --- Map name ---
    [sbuf appendFormat:@"%@<map>%@</map>\n",ident, self.map.name];
}


@end
