//
//  KMLCategorizer.m
//  TTSync_Test
//
//  Created by jzarzuela on 03/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "KMLCategorizer.h"
#import "RegexKitLite.h"
#import "XMLUtilDoc.h"




//----------------------------------------------------------------------------
// Internal data structures
//----------------------------------------------------------------------------
@implementation TNameCleaner

@synthesize reMatch, strReplace;

+ (TNameCleaner *) initWithMatch: (NSString *)reMatch strReplace:(NSString *) strReplace {
    
    TNameCleaner *me = [[TNameCleaner alloc] init];
    me.reMatch = reMatch;
    me.strReplace = strReplace;
    return me;
}

@end






//----------------------------------------------------------------------------
// PRIVATE METHODS
//----------------------------------------------------------------------------
@interface KMLCategorizer () 


@end



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
    [cats autorelease];
    [super dealloc];
}

//****************************************************************************
+ (KMLCategorizer *) createFromXMLInfo: (NSString *)xmlStr {
    
    TCatSelector *p;
    [TCatSelector alloc];
    
    XMLUtilDoc  *XUDoc = [XMLUtilDoc withXMLStrAndNS:xmlStr ns:@""];
    
    NSString *val = [XUDoc nodeStrValue:@"TTInfo/TTAll/@name"];
    NSLog(@"val = %@",val);
    
    return nil;   
}

@end
