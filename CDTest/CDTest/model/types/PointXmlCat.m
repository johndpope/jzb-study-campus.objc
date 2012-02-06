//
//  PointXmlUtil.m
//  CDTest
//
//  Created by jzarzuela on 06/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GDataXMLNode.h"
#import "RegexKitLite.h"

#import "PointXmlCat.h"




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation TPoint (PointXmlCat)


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) cleanHTML: (NSString *)str {
    
    NSMutableString *cleanStr = [NSMutableString new];
    NSArray  *listItems = [str componentsSeparatedByRegex:@"<[^<>]*>"];    
    for(int n=1;n<[listItems count];n++) {
        NSString *item = [listItems objectAtIndex: n];
        if([item length]>0) {
            [cleanStr appendString: item];
        }
    }
    
    [cleanStr replaceOccurrencesOfString:@"&lt;"   withString:@"<" options:0 range:(NSRange){0, [cleanStr length]}];
    [cleanStr replaceOccurrencesOfString:@"&gt;"   withString:@">" options:0 range:(NSRange){0, [cleanStr length]}];
    [cleanStr replaceOccurrencesOfString:@"&amp;"  withString:@"&" options:0 range:(NSRange){0, [cleanStr length]}];
    [cleanStr replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:0 range:(NSRange){0, [cleanStr length]}];
    
    NSString *result = [NSString stringWithString:cleanStr];
    
    return result;
    
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) nodeStrCleanValue: (NSString *)xpath node:(GDataXMLNode*)node defValue:(NSString *)defValue {
    
    NSArray *children = [node nodesForXPath:xpath namespaces:nil error:nil];
    if([children count]>0) {
        NSString *val = [[children objectAtIndex:0] stringValue]; 
        return [self cleanHTML: val];
    }
    else {
        return defValue;
    }
    
}


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) kmlBlob {

    static NSUInteger s_idCounter = 1;

    NSMutableString *kmlStr = [NSMutableString string];
    
    [kmlStr appendString:@"<Placemark><name>"];
    [kmlStr appendString:self.name];
    [kmlStr appendString:@"</name><description>"];
    if(self.desc) {
        [kmlStr appendString:self.desc];
    }
    [kmlStr appendString:@"</description>"];

    s_idCounter++;
    NSString *styleID = [NSString stringWithFormat:@"Style-%u-%u",time(0L), s_idCounter];
    [kmlStr appendFormat:@"<Style id=\"%@\"><IconStyle><Icon><href>", styleID];
    if(self.iconURL) {
        [kmlStr appendString:self.iconURL];
    }
    [kmlStr appendString:@"</href></Icon></IconStyle></Style>"];

    [kmlStr appendString:@"<Point><coordinates>"];
    [kmlStr appendFormat:@"%lf, %lf, 0.0",self.lng, self.lat];
    [kmlStr appendString:@"</coordinates></Point></Placemark>"];
    
    return [kmlStr copy];
    
}


//---------------------------------------------------------------------------------------------------------------------
- (void) setKmlBlob:(NSString *) value {

    if(value==nil) {
        return;
    }
    
    GDataXMLNode *doc;
    NSError *error;
    
    doc = [[GDataXMLDocument alloc] initWithXMLString:value options:0 error: &error];
    if(doc==nil) {
        // Un error en el XML
        NSLog(@"Error parsing KML content: %@, %@", error, [error userInfo]);
        return;
    }
    
    NSString *str;
    
    str=[self nodeStrCleanValue: @"/Placemark/name/text()" node:doc defValue:@""];
    self.name = str;

    str=[self nodeStrCleanValue: @"/Placemark/description/text()" node:doc defValue:@""];
    self.desc = str;

    str=[self nodeStrCleanValue: @"/Placemark/Style/IconStyle/Icon/href/text()" node:doc defValue:nil];
    if(str){
        self.iconURL = @"el icono por defecto";
    } else {
        self.iconURL = str;
    }

    str=[self nodeStrCleanValue: @"/Placemark/Point/coordinates/text()" node:doc defValue:@""];
    // Parse lat y lng
    self.lng = 0.0;
    self.lat = 0.0;
}

@end
