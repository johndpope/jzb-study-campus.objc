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
#import "NSDataExtensions.h"


#define EXT_INFO_PREFIX @"@ext_info="


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



//---------------------------------------------------------------------------------------------------------------------
// AVISO: PARA PODER SER COMPATIBLES CON EXTERNALIZACIONES DE VERSIONES ANTERIORES NO SE PUEDE ELIMAR O CAMBIAR
// ELEMENTOS DEL ARRAY. HABRA QUE SEGUIR PONIENDO ALGO QUE TENGA SENTIDO CON COMPATIBILIDAD HACIA ATRAS
- (void) _putInArray:(NSMutableArray *)data category:(TCategory *)cat {
    
    // La informacion, para que sea muy compacta, se escribe en un NSArray de tipos basicos
    NSMutableArray *catData = [[[NSMutableArray alloc] init] autorelease];
    
    // Como esto es para persistir en GMap y no en el SQLite local, no se almacena lo siguiente:
    //  wasDeleted = false
    //  syncStatus = OK
    [catData addObject: cat.GID];
    [catData addObject: cat.name];
    [catData addObject: cat.desc];
    [catData addObject: cat.iconURL];
    [catData addObject: [NSNumber numberWithBool:cat.changed]];
    //[catData addObject: cat.wasDeleted];
    [catData addObject: cat.syncETag];
    //[catData addObject: cat.syncStatus];
    [catData addObject: cat.ts_created];
    [catData addObject: cat.ts_updated];
    
    [data addObject:[[catData copy] autorelease]];
}

//---------------------------------------------------------------------------------------------------------------------
// AVISO: PARA PODER SER COMPATIBLES CON EXTERNALIZACIONES DE VERSIONES ANTERIORES NO SE PUEDE ELIMAR O CAMBIAR
// ELEMENTOS DEL ARRAY. HABRA QUE SEGUIR PONIENDO ALGO QUE TENGA SENTIDO CON COMPATIBILIDAD HACIA ATRAS
- (void) _getFromArray:(NSArray *)catData category:(TCategory *)cat {
    
    // Como esto es para persistir en GMap y no en el SQLite local, no se almaceno lo siguiente:
    //  wasDeleted = false
    //  syncStatus = OK
    cat.GID        = [catData objectAtIndex:0];
    cat.name       = [catData objectAtIndex:1];
    cat.desc       = [catData objectAtIndex:2];
    cat.iconURL    = [catData objectAtIndex:3];
    cat.changed    = [[catData objectAtIndex:4] boolValue];
    cat.wasDeleted = false;
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
    NSMutableArray *data = [[[NSMutableArray alloc] init] autorelease];
    
    // Para las categorias se calcula y usa su INDEX en vez del GID para ahorrar espacio
    NSMutableDictionary *catIndexDic = [[NSMutableDictionary dictionary] autorelease];
    unsigned short catIndex = 0;
    
    
    // ********* Escribe informacion del mapa *********
    NSMutableArray *mapData = [[[NSMutableArray alloc] init] autorelease];
    [mapData addObject: self.map.name];
    [mapData addObject: self.map.iconURL];
    [data addObject:[[mapData copy] autorelease]];
    
    
    // ********* Escribe la informacion de las categorias *********
    NSMutableArray *catsData = [[[NSMutableArray alloc] init] autorelease];
    for(TCategory *cat in self.map.categories) {
        [catIndexDic setObject:[NSNumber numberWithUnsignedShort:catIndex++] forKey:cat.GID];
        [self _putInArray:catsData category:cat];
    }
    [data addObject:[[catsData copy] autorelease]];
    
    
    // ********* Escribe la informacion de points y subcategories de cada categoria *********
    NSMutableArray *linksData = [[[NSMutableArray alloc] init] autorelease];
    for(TCategory *cat in self.map.categories) {
        
        NSMutableArray *oneLinkData = [[[NSMutableArray alloc] init] autorelease];
        
        // El index de la categoria padre
        [oneLinkData addObject:[catIndexDic objectForKey:cat.GID]];
        
        // Los puntos
        NSMutableArray *pointsData = [[[NSMutableArray alloc] init] autorelease];
        for(TPoint *point in cat.points) {
            [pointsData addObject:point.GID];
        }
        [oneLinkData addObject: [[pointsData copy] autorelease]];
        
        // Las subcategorias
        NSMutableArray *subCatsData = [[[NSMutableArray alloc] init] autorelease];
        for(TCategory *subCat in cat.subcategories) {
            [subCatsData addObject:[catIndexDic objectForKey:subCat.GID]];
        }
        [oneLinkData addObject: [[subCatsData copy] autorelease]];
        
        // Añade esta entrada a la lista de enlaces
        [linksData addObject: [[oneLinkData copy] autorelease]];
    }
    [data addObject: [[linksData copy] autorelease]];
    
    
    // ********** AHORA LOS COMPRIME Y LO PONE EN BASE64 **********
    NSError *error;
    NSData *binData = [NSPropertyListSerialization dataWithPropertyList:[[data copy] autorelease] 
                                                                 format:NSPropertyListBinaryFormat_v1_0 
                                                                options:0 
                                                                  error:&error];
    NSData *gzData =[binData gzipDeflate];
    NSString *b64Info = [gzData b64Encoding];
    
    // ********** Establece la informacion en el punto **********
    self.desc= [[[NSString alloc] initWithFormat:@"%@%@",EXT_INFO_PREFIX,b64Info] autorelease];
}

//---------------------------------------------------------------------------------------------------------------------
// AVISO: PARA PODER SER COMPATIBLES CON EXTERNALIZACIONES DE VERSIONES ANTERIORES NO SE PUEDE ELIMAR O CAMBIAR
// ELEMENTOS DEL ARRAY. HABRA QUE SEGUIR PONIENDO ALGO QUE TENGA SENTIDO CON COMPATIBILIDAD HACIA ATRAS
- (void) parseExtInfoFromString:(NSString*) value {
    
    // Si no es un punto con informacion extendida no hace nada
    if(!self.isExtInfo) {
        return;
    }

    // Si el texto no tiene el formato adecuado no hace nada
    if(![value hasPrefix:EXT_INFO_PREFIX]) {
        return;
    }
    
    
    
    // ********** DECODIFICA EL BASE64 Y DESCOMPRIME EN EL PLIST **********
    value = [value substringFromIndex:[EXT_INFO_PREFIX length]];
    NSData *gzData = [NSData dataWithB64EncodedString:value]; 
    NSData *binData = [gzData gzipInflate];
    NSError *error;
    NSArray *data = [NSPropertyListSerialization propertyListWithData: binData
                                                              options:0
                                                               format:nil
                                                                error:&error];
    
    
    
    
    // Para las categorias se calculo y uso su INDEX en vez del GID para ahorrar espacio
    NSMutableArray *catsByIndexArray = [[[NSMutableArray alloc] init] autorelease];
    
    
    // ********* Lee informacion del mapa *********
    NSArray *mapData = [data objectAtIndex:0];
    self.map.name = [mapData objectAtIndex:0];
    self.map.iconURL = [mapData objectAtIndex:1];
    
    
    // ********* Lee la informacion de las categorias *********
    NSArray *catsData = [data objectAtIndex:1];
    for(NSArray *itemData in catsData) {
        TCategory *cat = [TCategory insertTmpNewInMap:self.map];
        [self _getFromArray:itemData category:cat];
        [self.map addCategory:cat];
        [catsByIndexArray addObject:cat];
    }
    
    
    // ********* Lee la informacion de points y subcategories de cada categoria *********
    NSArray *linksData = [data objectAtIndex:2];
    for(NSArray *oneLinkData in linksData) {
        
        // El index de la categoria padre
        unsigned short catIndex = [[oneLinkData objectAtIndex:0] unsignedShortValue];
        TCategory *cat = [catsByIndexArray objectAtIndex:catIndex];
        
        // Lee los puntos
        NSArray *pointsData = [oneLinkData objectAtIndex:1];
        for(NSString *pointGID in pointsData) {
            // Se busca el punto por GID
            TPoint *point = [self.map pointByGID:pointGID];
            if( point!=nil) {
                [cat addPoint:point];
            }
        }
        
        // Lee las subcategorias
        NSArray *subCatsData = [oneLinkData objectAtIndex:2];
        for(NSNumber *subCatIndex in subCatsData) {
            // Se busca por indice
            TCategory *subcat = [catsByIndexArray objectAtIndex:[subCatIndex intValue]];
            [cat addSubcategory:subcat];
        }
        
    }
    
}


@end
