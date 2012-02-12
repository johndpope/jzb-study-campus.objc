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
NSString* _cleanHTML(NSString *str) {
    
    NSMutableString *cleanStr = [[NSMutableString string] autorelease];
    NSArray  *listItems = [str componentsSeparatedByRegex:@"<[^<>]*>"];    
    for(int n=0;n<[listItems count];n++) {
        NSString *item = [listItems objectAtIndex: n];
        if([item length]>0) {
            [cleanStr appendString: item];
        }
    }
    
    return [[cleanStr copy] autorelease];
    
}


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) nodeStringValue: (NSString *)xpath fromNode:(GDataXMLNode*)node defValue:(NSString *)defValue {
    
    NSArray *children = [node nodesForXPath:xpath namespaces:nil error:nil];
    if([children count]>0) {
        NSString *val = [[children objectAtIndex:0] stringValue]; 
        return val;
    }
    else {
        return defValue;
    }
    
}


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) nodeStringCleanValue: (NSString *)xpath fromNode:(GDataXMLNode*)node defValue:(NSString *)defValue {
    
    return _cleanHTML([self nodeStringValue:xpath fromNode:node defValue:defValue]);
    
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
    
    return [[kmlStr copy] autorelease];
    
}


//---------------------------------------------------------------------------------------------------------------------
- (void) setKmlBlob:(NSString *) value {
    
    if(value==nil) {
        return;
    }
    
    NSError *error;
    GDataXMLNode *doc = [[[GDataXMLDocument alloc] initWithXMLString:value options:0 error: &error] autorelease];
    if(doc==nil) {
        // Un error en el XML
        NSLog(@"PointXmlCat - setKmlBlob - Error parsing KML content: %@, %@", error, [error userInfo]);
        return;
    }
    
    NSString *str;
    
    str=[self nodeStringValue: @"/Placemark/name/text()" fromNode:doc defValue:@""];
    self.name = str;
    
    str=[self nodeStringCleanValue: @"/Placemark/description/text()" fromNode:doc defValue:@""];
    self.desc = str;
    
    str=[self nodeStringValue: @"/Placemark/Style/IconStyle/Icon/href/text()" fromNode:doc defValue:nil];
    if(str){
        self.iconURL = str;
    } else {
        self.iconURL = @"el icono por defecto";
    }
    
    str=[self nodeStringValue: @"/Placemark/Point/coordinates/text()" fromNode:doc defValue:@""];
    if(!str || [str length] == 0) {
        self.lng = 0.0; // Valores por defecto???
        self.lat = 0.0;
    } else {
        NSArray *comps = [str componentsSeparatedByString:@","];
        self.lng = [[comps objectAtIndex:0] doubleValue];
        self.lat = [[comps objectAtIndex:1] doubleValue];
    }
    
}

@end
