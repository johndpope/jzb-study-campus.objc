//
//  PointXmlUtil.m
//  CDTest
//
//  Created by jzarzuela on 06/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PointXmlCat.h"

#import "GMapIcon.h"

#import "GDataXMLNode.h"
#import "RegexKitLite.h"
#import "NSDataExtensions.h"

#import "GTMNSString+HTML.h"

#import "JavaStringCat.h"


#define EXT_INFO_PREFIX @"extended_Info:"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation MEPoint (PointXmlCat)



//---------------------------------------------------------------------------------------------------------------------
NSString* _cleanHTML(NSString *str) {
    
    NSMutableString *cleanStr = [NSMutableString string];
    NSArray  *listItems = [str componentsSeparatedByRegex:@"<[^<>]*>"];    
    for(int n=0;n<[listItems count];n++) {
        NSString *item = [listItems objectAtIndex: n];
        if([item length]>0) {
            [cleanStr appendString: item];
        }
    }
    
    return cleanStr;
    
}


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) nodeStringValue: (NSString *)xpath fromNode:(GDataXMLNode*)node defValue:(NSString *)defValue ns:(NSDictionary *)ns {
    
    NSError *error = nil;
    NSArray *children = [node nodesForXPath:xpath namespaces:ns error:&error];
    if([children count]>0) {
        NSString *val = [[children objectAtIndex:0] stringValue]; 
        return val;
    }
    else {
        return defValue;
    }
    
}


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) nodeStringCleanValue: (NSString *)xpath fromNode:(GDataXMLNode*)node defValue:(NSString *)defValue  ns:(NSDictionary *)ns {
    
    return _cleanHTML([self nodeStringValue:xpath fromNode:node defValue:defValue ns:ns]);
    
}


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) kmlBlob {
    
    static NSUInteger s_idCounter = 1;
    
    NSMutableString *kmlStr = [NSMutableString string];
    
    [kmlStr appendString:@"<Placemark><name><![CDATA["];
    [kmlStr appendString:[self.name gtm_stringByEscapingForAsciiHTML]];
    [kmlStr appendString:@"]]></name><description><![CDATA["];
    if(self.desc) {
        [kmlStr appendString:[self.desc gtm_stringByEscapingForAsciiHTML]];
    }
    [kmlStr appendString:@"]]></description>"];
    
    s_idCounter++;
    NSString *styleID = [NSString stringWithFormat:@"Style-%u-%u",time(0L), s_idCounter];
    [kmlStr appendFormat:@"<Style id=\"%@\"><IconStyle><Icon><href>", styleID];
    if(self.icon.url) {
        [kmlStr appendString:self.icon.url];
    }
    [kmlStr appendString:@"</href></Icon></IconStyle></Style>"];
    
    [kmlStr appendString:@"<Point><coordinates>"];
    [kmlStr appendFormat:@"%lf, %lf, 0.0",self.lng, self.lat];
    [kmlStr appendString:@"</coordinates></Point></Placemark>"];
    
    return kmlStr;
    
}


//---------------------------------------------------------------------------------------------------------------------
- (void) setKmlBlob:(NSString *) value {

    // Si no hay nada que parsear retorna
    if(value==nil) {
        return;
    }
    
    // Parsea el XML que esta en el BLOB KML del elemento
    NSError *error = nil;
    GDataXMLDocument *doc = [[[GDataXMLDocument alloc] initWithXMLString:value options:0 error: &error] autorelease];
    if(doc==nil) {
        // Un error en el XML
        NSLog(@"PointXmlCat - setKmlBlob - Error parsing KML content: %@, %@", error, [error userInfo]);
        return;
    }
    GDataXMLNode *rootNode = [doc rootElement];
    
    
    // Captura el NameSpace que tiene el nodo raiz (SOLO UNO)
    NSDictionary *namespaces = nil;
    for(GDataXMLNode *ns in [[doc rootElement] namespaces]) {
        namespaces = [NSDictionary dictionaryWithObject:[ns stringValue] forKey:@"NSX"];
    }

    // Busca los diferentes valores
    NSString *str = nil;
    NSString *xpathExpr = nil;
    
    xpathExpr = namespaces ? @"/NSX:Placemark/NSX:name/text()" : @"/Placemark/name/text()";
    str=[self nodeStringValue: xpathExpr fromNode:rootNode defValue:@"" ns:namespaces];
    self.name = [str gtm_stringByUnescapingFromHTML];
    
    xpathExpr = namespaces ? @"/NSX:Placemark/NSX:description/text()" : @"/Placemark/description/text()";
    str=[self nodeStringCleanValue: xpathExpr fromNode:rootNode defValue:@"" ns:namespaces];
    self.desc = [str gtm_stringByUnescapingFromHTML];
    
    xpathExpr = namespaces ? @"/NSX:Placemark/NSX:Style/NSX:IconStyle/NSX:Icon/NSX:href/text()" : @"/Placemark/Style/IconStyle/Icon/href/text()";
    str=[self nodeStringValue: xpathExpr fromNode:rootNode defValue:nil ns:namespaces];
    if(!str || [str length] == 0) {
        str = [MEPoint defaultIconURL];
    }
    self.icon = [GMapIcon iconForURL:str];
    
    xpathExpr = namespaces ? @"/NSX:Placemark/NSX:Point/NSX:coordinates/text()" : @"/Placemark/Point/coordinates/text()";
    str=[self nodeStringValue: xpathExpr fromNode:rootNode defValue:@"" ns:namespaces];
    if(!str || [str length] == 0) {
        self.lng = 0.0; // Valores por defecto???
        self.lat = 0.0;
    } else {
        NSArray *comps = [str componentsSeparatedByString:@","];
        self.lng = [[comps objectAtIndex:0] doubleValue];
        self.lat = [[comps objectAtIndex:1] doubleValue];
    }
    
}



//---------------------------------------------------------------------------------------------------------------------
// AVISO: PARA PODER SER COMPATIBLES CON EXTERNALIZACIONES DE VERSIONES ANTERIORES NO SE PUEDE ELIMAR O CAMBIAR
// ELEMENTOS DEL ARRAY. HABRA QUE SEGUIR PONIENDO ALGO QUE TENGA SENTIDO CON COMPATIBILIDAD HACIA ATRAS
- (void) _putInArray:(NSMutableArray *)data category:(MECategory *)cat {
    
    // La informacion, para que sea muy compacta, se escribe en un NSArray de tipos basicos
    NSMutableArray *catData = [NSMutableArray array];
    
    // Como esto es para persistir en GMap y no en el SQLite local, no se almacena lo siguiente:
    //  wasDeleted = false
    //  syncStatus = OK
    [catData addObject: cat.GID];
    [catData addObject: cat.name];
    [catData addObject: cat.desc];
    [catData addObject: cat.icon.url];
    [catData addObject: [NSNumber numberWithBool:cat.changed]];
    //[catData addObject: cat.wasDeleted];
    [catData addObject: cat.syncETag];
    //[catData addObject: cat.syncStatus];
    [catData addObject: cat.ts_created];
    [catData addObject: cat.ts_updated];
    
    [data addObject:catData];
}

//---------------------------------------------------------------------------------------------------------------------
// AVISO: PARA PODER SER COMPATIBLES CON EXTERNALIZACIONES DE VERSIONES ANTERIORES NO SE PUEDE ELIMAR O CAMBIAR
// ELEMENTOS DEL ARRAY. HABRA QUE SEGUIR PONIENDO ALGO QUE TENGA SENTIDO CON COMPATIBILIDAD HACIA ATRAS
- (void) _getFromArray:(NSArray *)catData category:(MECategory *)cat {
    
    // Como esto es para persistir en GMap y no en el SQLite local, no se almaceno lo siguiente:
    //  wasDeleted = false
    //  syncStatus = OK
    cat.GID        = [catData objectAtIndex:0];
    cat.name       = [catData objectAtIndex:1];
    cat.desc       = [catData objectAtIndex:2];
    cat.icon       = [GMapIcon iconForURL:[catData objectAtIndex:3]];
    cat.changed    = [[catData objectAtIndex:4] boolValue];
    cat.syncETag   = [catData objectAtIndex:5];
    cat.syncStatus = ST_Sync_OK;
    cat.ts_created = [catData objectAtIndex:6];
    cat.ts_updated = [catData objectAtIndex:7];
}

//---------------------------------------------------------------------------------------------------------------------
// AVISO: PARA PODER SER COMPATIBLES CON EXTERNALIZACIONES DE VERSIONES ANTERIORES NO SE PUEDE ELIMAR O CAMBIAR
// ELEMENTOS DEL ARRAY. HABRA QUE SEGUIR PONIENDO ALGO QUE TENGA SENTIDO CON COMPATIBILIDAD HACIA ATRAS
- (void) updateExtInfoFromMap {
    
    // Si no es un punto con informacion extendida no hace nada
    if(!self.isExtInfo) {
        return;
    }
    
    
    // La informacion, para que sea muy compacta, se escribe en un NSArray de tipos basicos
    NSMutableArray *data = [NSMutableArray array];
    
    // Para las categorias se calcula y usa su INDEX en vez del GID para ahorrar espacio
    NSMutableDictionary *catIndexDic = [NSMutableDictionary dictionary];
    unsigned short catIndex = 0;
    
    
    // ********* Escribe informacion del mapa *********
    NSMutableArray *mapData = [NSMutableArray array];
    [mapData addObject: self.map.icon.url];
    [data addObject:mapData];
    
    
    // ********* Escribe la informacion de las categorias *********
    NSMutableArray *catsData = [NSMutableArray array];
    for(MECategory *cat in self.map.categories) {
        [catIndexDic setObject:[NSNumber numberWithUnsignedShort:catIndex++] forKey:cat.GID];
        [self _putInArray:catsData category:cat];
    }
    [data addObject:catsData];
    
    
    // ********* Escribe la informacion de points y subcategories de cada categoria *********
    NSMutableArray *linksData = [NSMutableArray array];
    for(MECategory *cat in self.map.categories) {
        
        NSMutableArray *oneLinkData = [NSMutableArray array];
        
        // El index de la categoria padre
        [oneLinkData addObject:[catIndexDic objectForKey:cat.GID]];
        
        // Los puntos
        NSMutableArray *pointsData = [NSMutableArray array];
        for(MEPoint *point in cat.points) {
            [pointsData addObject:point.GID];
        }
        [oneLinkData addObject: pointsData];
        
        // Las subcategorias
        NSMutableArray *subCatsData = [NSMutableArray array];
        for(MECategory *subCat in cat.subcategories) {
            [subCatsData addObject:[catIndexDic objectForKey:subCat.GID]];
        }
        [oneLinkData addObject: subCatsData];
        
        // Añade esta entrada a la lista de enlaces
        [linksData addObject: oneLinkData];
    }
    [data addObject: linksData];
    
    
    // ********** AHORA LOS COMPRIME Y LO PONE EN BASE64 **********
    NSError *error = nil;
    NSData *binData = [NSPropertyListSerialization dataWithPropertyList:data 
                                                                 format:NSPropertyListBinaryFormat_v1_0 
                                                                options:0 
                                                                  error:&error];
    NSData *gzData =[binData gzipDeflate];
    NSString *b64Info = [gzData b64Encoding];
    
    // ********** Establece la informacion en el punto **********
    self.desc= [NSString stringWithFormat:@"%@%@",EXT_INFO_PREFIX,b64Info];
}

//---------------------------------------------------------------------------------------------------------------------
// AVISO: PARA PODER SER COMPATIBLES CON EXTERNALIZACIONES DE VERSIONES ANTERIORES NO SE PUEDE ELIMAR O CAMBIAR
// ELEMENTOS DEL ARRAY. HABRA QUE SEGUIR PONIENDO ALGO QUE TENGA SENTIDO CON COMPATIBILIDAD HACIA ATRAS
- (BOOL) parseExtInfoFromString:(NSString*) value {
    
    // Si no es un punto con informacion extendida no hace nada
    if(!self.isExtInfo) {
        return false;
    }
    
    // Si el texto no tiene el formato adecuado no hace nada
    if(![value hasPrefix:EXT_INFO_PREFIX]) {
        return false;
    }
    
    
    
    // ********** DECODIFICA EL BASE64 Y DESCOMPRIME EN EL PLIST **********
    value = [value substringFromIndex:[EXT_INFO_PREFIX length]];
    NSData *gzData = [NSData dataWithB64EncodedString:value]; 
    NSData *binData = [gzData gzipInflate];
    NSError *error=nil;
    NSArray *data = [NSPropertyListSerialization propertyListWithData: binData
                                                              options:0
                                                               format:nil
                                                                error:&error];
    
    
    
    // Si los datos estan mal aborta el parseo
    if(error) {
        NSLog(@"parseExtInfoFromString - error: %@ / %@",error, [error userInfo]);
        return false;
    }
    
    
    // Para las categorias se calculo y uso su INDEX en vez del GID para ahorrar espacio
    NSMutableArray *catsByIndexArray = [NSMutableArray array];
    
    
    // ********* Lee informacion del mapa *********
    NSArray *mapData = [data objectAtIndex:0];
    self.map.icon    = [GMapIcon iconForURL:[mapData objectAtIndex:0]];
    
    
    // ********* Lee la informacion de las categorias *********
    NSArray *catsData = [data objectAtIndex:1];
    for(NSArray *itemData in catsData) {
        MECategory *cat = [MECategory categoryInMap:self.map];
        [self _getFromArray:itemData category:cat];
        [self.map addCategory:cat];
        [catsByIndexArray addObject:cat];
    }
    
    
    // ********* Lee la informacion de points y subcategories de cada categoria *********
    NSArray *linksData = [data objectAtIndex:2];
    for(NSArray *oneLinkData in linksData) {
        
        // El index de la categoria padre
        unsigned short catIndex = [[oneLinkData objectAtIndex:0] unsignedShortValue];
        MECategory *cat = [catsByIndexArray objectAtIndex:catIndex];
        
        // Lee los puntos
        NSArray *pointsData = [oneLinkData objectAtIndex:1];
        for(NSString *pointGID in pointsData) {
            // Se busca el punto por GID
            MEPoint *point = [self.map pointByGID:pointGID];
            if( point!=nil) {
                [cat addPoint:point];
            }
        }
        
        // Lee las subcategorias
        NSArray *subCatsData = [oneLinkData objectAtIndex:2];
        for(NSNumber *subCatIndex in subCatsData) {
            // Se busca por indice
            MECategory *subcat = [catsByIndexArray objectAtIndex:[subCatIndex intValue]];
            [cat addSubcategory:subcat];
        }
        
    }
    
    // Todo parseado
    return true;
    
}


@end
