//
//  KMLReader.m
//  JZBTest
//
//  Created by Snow Leopard User on 15/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KMLReader.h"
#import "GDataXMLNode.h"
#import "POIData.h"
#import "JavaStringCat.h"
#import "RegexKitLite.h"


//----------------------------------------------------------------------------
// PRIVATE METHODS
//----------------------------------------------------------------------------
@interface KMLReader () 

+ (void) parserKMLFile: (NSString *)filePath;
+ (POIData *) parsePOIFromNode: (GDataXMLNode *)node namespaces:(NSDictionary *)nss error:(NSError*) err;

@end

//----------------------------------------------------------------------------
// UTILITY METHODS
//----------------------------------------------------------------------------
NSString * _cleanHTML(NSString *str);
NSString * _getNodeStrValue(NSString *xpath, GDataXMLNode *node, NSDictionary *nss, NSError *err);



@implementation KMLReader



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

//****************************************************************************
+ (void) readKMLFileFromPath: (NSString *)filePath allowDuplicated: (BOOL) allow {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if(![fm isReadableFileAtPath: filePath]) {
        return;
    }
    
    [KMLReader parserKMLFile:filePath];
}

//****************************************************************************
+ (void) parserKMLFile:(NSString *)filePath {
  
    NSError *err;
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingFromURL:url error:&err];
    NSData *data = [fh readDataToEndOfFile];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error: &err];
    if(doc == nil) {
        return;
    }

    
    NSDictionary *nss = [NSDictionary dictionaryWithObject:@"http://earth.google.com/kml/2.2" forKey:@"ns1"];
    GDataXMLElement *root=[doc rootElement];

    // Iterate all the "Point" placemarks   
    NSArray *children = [doc nodesForXPath: @"/ns1:kml/ns1:Document/ns1:Placemark/ns1:Point/.." namespaces:nss error: &err];
    for(GDataXMLNode *node in children) {
        POIData *poi = [KMLReader parsePOIFromNode:node namespaces:nss error:err];
        [poi dump];
    }
        
}


//****************************************************************************
+ (POIData *) parsePOIFromNode: (GDataXMLNode *)node namespaces:(NSDictionary *)nss error:(NSError*) err {
    
    // TODO : Se hace aqui el autorelase???
    POIData *poi = [[POIData new] autorelease];
    
    
    // name
    poi.name = _getNodeStrValue(@"ns1:name/text()", node, nss, err);
    
    
    // description | TODO clean HTML
    poi.desc = _cleanHTML( _getNodeStrValue(@"ns1:description/text()", node, nss, err) );
    
    
    // Coordinates
    NSString *point = _getNodeStrValue(@"ns1:Point/ns1:coordinates", node, nss, err);
    NSUInteger p1=[point indexOf:@","];
    NSString *strLng = [point subStrFrom:0 To:p1];
    NSUInteger p2=[point indexOf:@"," startIndex:p1+1];
    if(p2 == NSNotFound) {
        p2 = [point length];
    }
    NSString *strLat = [point subStrFrom:p1+1 To:p2];
    poi.lng = [strLng doubleValue];
    poi.lat = [strLat doubleValue];
    
    
    // IconStyle (resolviendo la indireccion por ID)
    NSString *styleName = _getNodeStrValue(@"ns1:styleUrl", node, nss, err);
    if([styleName length]>0) {
    
        if([styleName characterAtIndex:0]=='#') {
            styleName = [styleName subStrFrom:1];
        }
        
        NSString *xpath = [NSString stringWithFormat:@"/ns1:kml/ns1:Document/ns1:Style[@id='%@']/ns1:IconStyle/ns1:Icon/ns1:href",styleName];
        NSString *iconHREF = _getNodeStrValue(xpath, node, nss, err);
        // Valor por defecto en los mapas cuando no hay nada
        if([iconHREF length]==0) {
            iconHREF = @"http://maps.gstatic.com/intl/es_es/mapfiles/ms/micons/blue-dot.png";
        }
    
        
        // IconStyle
        poi.iconStyle = iconHREF;
        
        
        // Category
        poi.category = [POIData calcCategoryFromIconStyle:iconHREF];
        
    }
    
    
    return poi;
}


//****************************************************************************
NSString * _cleanHTML(NSString *str) {

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

//****************************************************************************
NSString * _getNodeStrValue(NSString *xpath, GDataXMLNode *node, NSDictionary *nss, NSError *err) {

    
    NSArray *children = [node nodesForXPath:xpath namespaces:nss error:&err];
    if([children count]>0) {
        return [[children objectAtIndex:0] stringValue]; 
    }
    else {
        return @"";
    }
}

@end
