//
//  KMLCategorizer.m
//  TTSync_Test
//
//  Created by jzarzuela on 03/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "KMLCategorizer.h"
#import "RegexKitLite.h"


//----------------------------------------------------------------------------
// PRIVATE CLASSES
//----------------------------------------------------------------------------
struct TNameCleaner {
    NSString *reMatch;
    NSString *strReplace;
}; 

struct TCatSelector {
    NSString *name;
    NSString *icon;
    NSString *reStyle;
    NSString *reName;
    NSMutableArray *cleaners;
}; 




@implementation KMLCategorizer


//****************************************************************************
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//****************************************************************************
- (void)dealloc
{
    [super dealloc];
}

@end
