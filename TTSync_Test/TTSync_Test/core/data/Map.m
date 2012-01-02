//
//  Map.m
//  TTSync_Test
//
//  Created by jzarzuela on 02/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Map.h"


@implementation Map


@synthesize guid, name, desc, icon, catPrefix, mapURL, lastUpdate, pois;

//****************************************************************************
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        guid = @"";
        name = @"";
        desc = @"";
        icon = nil;
        pois =  [[NSArray alloc] init];
        catPrefix = @"";
        mapURL = @"";
        lastUpdate = @"";
    }
    
    return self;
}

//****************************************************************************
- (void)dealloc
{
    // @TODO:  ¿Hace falta esto?
    [guid autorelease];
    [name autorelease];
    [desc autorelease];
    [icon autorelease];
    [pois autorelease];
    [catPrefix autorelease];
    [mapURL autorelease];
    [lastUpdate autorelease];
    [super dealloc];
}

@end
