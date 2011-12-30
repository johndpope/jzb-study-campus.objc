//
//  main.m
//  JZBTest
//
//  Created by Snow Leopard User on 12/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyClass.h"
#import "MyCategory.h"
#import "MyParserDelegate.h"
#import "XMLReader.h"
#import "GDataXMLNode.h"
#import "POIData.h"
#import "KMLReader.h"


void doIt();


//**************************************************************************************************************************
int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    // insert code here...
    NSLog(@"Hello, World!");

    doIt();
    
    [pool release];
    return 0;

}


//**************************************************************************************************************************
void doIt() {
    
    NSString  *iconStyle = @"http://maps.gstatic.com/intl/es_es/mapfiles/ms/micons/earthquake.png";
    NSString *cat = [POIData calcCategoryFromIconStyle: iconStyle];
    NSLog(@"cat = %@", cat);

    iconStyle = @"http://maps.google.com/mapfiles/kml/shapes/hiker_maps.png";
    cat = [POIData calcCategoryFromIconStyle: iconStyle];
    NSLog(@"cat = %@", cat);


    POIData *poi = [POIData new];
    [poi dump];

    
    [KMLReader readKMLFileFromPath:@"/Users/User/Desktop/kmls/BT_Boston_2010.kml" allowDuplicated:TRUE];
    
}
    
//**************************************************************************************************************************
void doIt3() {
    

    NSString *txt = @"cad1|cad2#cad3&cad4|cad5|cad6|";
    
    NSRange r1=[txt rangeOfString:@"&"];
    NSLog(@"pos1 = %li, length = %li",r1.location,r1.length);


    NSRange r2=[txt rangeOfString:@"#" options:NSBackwardsSearch range:(NSRange){r1.location,[txt length]-r1.location}];
    NSLog(@"pos2 = %li, length = %li",r2.location,r2.length);
    
    
    NSMutableString *ms = [NSMutableString stringWithFormat:@"hola %@", [txt substringWithRange: (NSRange){r1.location+1,[txt length]-r1.location-1} ]];
    [ms replaceOccurrencesOfString:@"|" withString:@"_" options:0 range: (NSRange){0,[ms length]} ];
    
    NSLog(@"valor = %@", [ms copy]);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
}


//**************************************************************************************************************************
void doIt2() {

        
    NSError * err;
    NSURL *url = [NSURL fileURLWithPath:@"./test.xml"];
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingFromURL:url error:&err];
    NSData *data = [fh readDataToEndOfFile];
    
    char buffer[1000];
    [data getBytes:buffer];
    for(int n=0;n<10;n++) {
        NSLog(@"%c",buffer[n]);
    }
    
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error: &err];
    if(doc == nil) {
        NSLog(@"Sin documento");
    }

    GDataXMLElement *root=[doc rootElement];
    NSArray *children = [root children];
    
    for(GDataXMLNode *node in children) {
        NSLog(@"Node name: %@", [node name]);
    }
    
    children = [doc nodesForXPath: @"/note/heading[@id='1']" error: &err];
    for(GDataXMLNode *node in children) {
        NSLog(@"Node name XPath: %@", [node stringValue]);
    }
    
    
    NSDictionary *dict = [XMLReader dictionaryForXMLData:data error:&err];
    NSLog(@"error %li",[err code]);
    NSLog(@"count %li", [dict count]);
    
    NSDictionary *child = [dict objectForKey:@"note"];
    
    for(NSString *key in child){
        NSLog(@"%@",key);
    }
    
}

