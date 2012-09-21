//
//  Map.m
//  TTSync_Test
//
//  Created by jzarzuela on 02/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GMap.h"
#import "GCategory.h"


@implementation GMap


@synthesize guid, name, mapURL, lastUpdate, pois;

//****************************************************************************
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        guid = @"";
        name = @"";
        pois =  [[NSMutableArray alloc] init];
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
    [pois autorelease];
    [mapURL autorelease];
    [lastUpdate autorelease];
    [super dealloc];
}


//****************************************************************************
// Añade un nuevo GPOI al mapa. A partir de ese punto el mapa es el dueño del POI
- (void) addPOI: (GPOI *)apoi {

    // Category
    NSString *cat = [GCategory calcCategoryFromIconStyle:apoi.iconStyle];

    [pois addObject: apoi];
}

@end
