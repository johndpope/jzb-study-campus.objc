//
//  Category.m
//  TTSync_Test
//
//  Created by jzarzuela on 02/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GCategory.h"
#import "JavaStringCat.h"


@implementation GCategory


@synthesize name, iconName, pois;


//****************************************************************************
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        name = @"";
        iconName = @"";
        pois = [[NSMutableArray alloc] init];
    }
    
    return self;
}

//****************************************************************************
- (void)dealloc
{
    [name autorelease];
    [iconName autorelease];
    [pois autorelease];
    [super dealloc];
}

/****************************************************************************
 * Utility method that extracts a "simplified" category name from the iconStyle attribute (url).
 * It is simplier to read that information than the whole one in iconStyle
 **/
+ (NSString *) calcCategoryFromIconStyle: (NSString *)iconStyle {
    
    NSString *catName;
    
    //-----------------------------------------------------------
    if(iconStyle == nil || [iconStyle length] == 0) {
        
        return UNKNOWN_CATEGORY;
        
    } 
    //-----------------------------------------------------------
    else if([iconStyle indexOf:@"chst=d_map_pin_letter"] != NSNotFound) {
        
        NSUInteger p1 = [iconStyle lastIndexOf:@"chld="];
        if(p1 != NSNotFound) {
            
            NSUInteger p2 = [iconStyle lastIndexOf:@"|" startIndex:p1];
            if(p2 == NSNotFound) {
                p2 = [iconStyle length];
            }
            
            catName = [NSString stringWithFormat:@"Pin_Letter_%@", [iconStyle subStrFrom: p1+5 To:p2]];
            catName = [catName replaceStr:@"|" Width:@"_"];
            
            return catName;
            
        } else {
            return [iconStyle copy];
        }
    }
    //-----------------------------------------------------------
    else if([iconStyle indexOf:@"/kml/paddle"] != NSNotFound) {
        
        NSUInteger p1 = [iconStyle lastIndexOf:@"/"];
        if(p1 != NSNotFound) {
            
            NSUInteger p2 = [iconStyle lastIndexOf:@"_maps" startIndex:p1];
            if(p2 == NSNotFound) {
                p2 = [iconStyle length];
            }
            
            catName = [NSString stringWithFormat:@"Pin_Letter_%@", [iconStyle subStrFrom: p1+1 To:p2]];
            
            return catName;
            
        } else {
            return [iconStyle copy];
        }
    }
    //-----------------------------------------------------------
    else if([iconStyle indexOf:@"/mapfiles/ms/micons"] != NSNotFound || [iconStyle indexOf:@"/mapfiles/ms2/micons"] != NSNotFound) {
        
        NSUInteger p1 = [iconStyle lastIndexOf:@"/"];
        if(p1 != NSNotFound) {
            
            NSUInteger p2 = [iconStyle lastIndexOf:@"." startIndex:p1];
            if(p2 == NSNotFound) {
                p2 = [iconStyle length];
            }
            
            catName = [NSString stringWithFormat:@"GMI_%@", [iconStyle subStrFrom: p1+1 To:p2]];
            
            return catName;
            
        } else {
            return [iconStyle copy];
        }
    }
    //-----------------------------------------------------------
    else if([iconStyle indexOf:@"/kml/shapes"] != NSNotFound) {
        
        NSUInteger p1 = [iconStyle lastIndexOf:@"/"];
        if(p1 != NSNotFound) {
            
            NSUInteger p2 = [iconStyle lastIndexOf:@"_maps" startIndex:p1];
            if(p2 == NSNotFound) {
                p2 = [iconStyle length];
            }
            
            catName = [NSString stringWithFormat:@"GMI_%@", [iconStyle subStrFrom: p1+1 To:p2]];
            
            return catName;
            
        } else {
            return [iconStyle copy];
        }
    }
    //-----------------------------------------------------------
    else {
        return UNKNOWN_CATEGORY;
    }
    
}

@end
