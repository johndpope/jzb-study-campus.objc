//
//  POIData.m
//  JZBTest
//
//  Created by Snow Leopard User on 15/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GPOI.h"


@implementation GPOI


@synthesize name, desc, lng, lat, iconStyle;


//****************************************************************************
- (id)init
{
    self = [super init];
    if (self) {
        name = @"";
        desc = @"";
        iconStyle = @"";
    }
    
    return self;
}

//****************************************************************************
- (void)dealloc
{
    // @TODO:  ¿Hace falta esto?
    [name autorelease];
    [desc autorelease];
    [iconStyle autorelease];
    [super dealloc];
}


//****************************************************************************
- (void) dump {
    NSLog(@"POIData name='%@' desc='%@' lng='%f' lat='%f' iconStyle='%@'",name,desc,lng,lat,iconStyle);
}


@end
