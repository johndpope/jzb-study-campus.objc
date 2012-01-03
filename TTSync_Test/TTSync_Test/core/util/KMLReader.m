//
//  KMLReader.m
//  JZBTest
//
//  Created by Snow Leopard User on 15/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KMLReader.h"
#import "JavaStringCat.h"
#import "GPOI.h"
#import "XMLUtilDoc.h"
#import "KMLCategorizer.h"


#define TT_CATEGORIES_XML_NODE_NAME_OLD1  @"@TT_CAT"
#define TT_CATEGORIES_XML_NODE_NAME_OLD2  @"@CAT_TT"
#define TT_CATEGORIES_XML_NODE_NAME       @"@TT_CATEGORIES"



//----------------------------------------------------------------------------
// PRIVATE METHODS
//----------------------------------------------------------------------------
@interface KMLReader () 

+ (void) parserKMLFile: (NSString *)filePath;
+ (GPOI *) parsePOIFromNode: (GDataXMLNode *)node XUDoc:(XMLUtilDoc *) XUDoc;
+ (void) parseCategorizer:(XMLUtilDoc *) XUDoc;

@end



//----------------------------------------------------------------------------
// UTILITY METHODS
//----------------------------------------------------------------------------
BOOL _is_TTCategories_POI(GPOI *poi);
BOOL _is_TTCategories_POI_OLD(GPOI *poi);





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

    XMLUtilDoc  *XUDoc = [XMLUtilDoc withDataAndNS:data ns:@"http://earth.google.com/kml/2.2"];
    //@TODO: Como chequeamos que todo fue bien. Que pasa con el autorelease del ".doc"
    if(XUDoc.doc == nil) {
        return;
    }

    [KMLReader parseCategorizer:XUDoc];
    
    // Iterate all the "Point" placemarks   
    NSMutableArray *pois = [NSMutableArray new];
    NSArray *children = [XUDoc nodesForXPath: @"/ns1:kml/ns1:Document/ns1:Placemark/ns1:Point/.."];
    for(GDataXMLNode *node in children) {
        GPOI *poi = [KMLReader parsePOIFromNode:node XUDoc:XUDoc];
        [pois addObject:poi];
    }

    for(GPOI *poi in pois) {
        if(_is_TTCategories_POI(poi)) {
            //[pois removeObject: poi];
            [poi dump];
        }
    }
    
    for(GPOI *poi in pois) {
        if(_is_TTCategories_POI(poi)) {
            //[pois removeObject: poi];	
        }
    }
    
}

//****************************************************************************
+ (void) parseCategorizer:(XMLUtilDoc *) XUDoc {

    BOOL old = FALSE;
    NSString *str;
    
    str=[XUDoc nodeStrCleanValue: @"/ns1:kml/ns1:Document/ns1:Placemark[ns1:name='" TT_CATEGORIES_XML_NODE_NAME "']/ns1:description/text()"];
    if([str length]<=0) {
        old = TRUE;
        str=[XUDoc nodeStrCleanValue: @"/ns1:kml/ns1:Document/ns1:Placemark[ns1:name='" TT_CATEGORIES_XML_NODE_NAME_OLD1 "']/ns1:description/text()"];
        if([str length]<=0) {
            str=[XUDoc nodeStrCleanValue: @"/ns1:kml/ns1:Document/ns1:Placemark[ns1:name='" TT_CATEGORIES_XML_NODE_NAME_OLD2 "']/ns1:description/text()"];
            if([str length]<=0) {
                // No habia un nodo de categorias
                return;
            }
        }
    }
    
    [KMLCategorizer createFromXMLInfo: str];
    
    NSLog(@"desc %@",str);

    
}

//****************************************************************************
+ (GPOI *) parsePOIFromNode: (GDataXMLNode *)node XUDoc:(XMLUtilDoc *) XUDoc {
    
    // TODO : Se hace aqui el autorelase???
    GPOI *poi = [[GPOI new] autorelease];
    
    
    // name
    poi.name = [XUDoc nodeStrValue:@"ns1:name/text()" node:node];
    
    
    // description | TODO clean HTML
    poi.desc = [XUDoc nodeStrCleanValue:@"ns1:description/text()" node:node];
    
    
    // Coordinates
    NSString *point = [XUDoc nodeStrValue:@"ns1:Point/ns1:coordinates" node:node];
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
    NSString *styleName = [XUDoc nodeStrValue:@"ns1:styleUrl" node:node];
    if([styleName length]>0) {
    
        if([styleName characterAtIndex:0]=='#') {
            styleName = [styleName subStrFrom:1];
        }
        
        NSString *xpath = [NSString stringWithFormat:@"/ns1:kml/ns1:Document/ns1:Style[@id='%@']/ns1:IconStyle/ns1:Icon/ns1:href",styleName];
        NSString *iconHREF = [XUDoc nodeStrValue:xpath node:node];
        // Valor por defecto en los mapas cuando no hay nada
        if([iconHREF length]==0) {
            iconHREF = @"http://maps.gstatic.com/intl/es_es/mapfiles/ms/micons/blue-dot.png";
        }
    
        
        // IconStyle
        poi.iconStyle = iconHREF;
        
    }
    
    
    return poi;
}

//****************************************************************************
BOOL _is_TTCategories_POI(GPOI *poi) {
    return [poi.name isEqualToString: TT_CATEGORIES_XML_NODE_NAME];
}

//****************************************************************************
BOOL _is_TTCategories_POI_OLD(GPOI *poi) {
    BOOL a=[poi.name isEqualToString: TT_CATEGORIES_XML_NODE_NAME_OLD1];
    BOOL b=[poi.name isEqualToString: TT_CATEGORIES_XML_NODE_NAME_OLD2];
    return a || b;
}

@end
