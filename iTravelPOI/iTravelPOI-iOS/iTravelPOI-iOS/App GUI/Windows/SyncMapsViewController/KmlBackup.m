//
//  KmlBackup.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 28/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#define __KmlBackup__IMPL__
#import "KmlBackup.h"
#import "MPoint.h"
#import "MIcon.h"
#import "MTag.h"
#import "NSString+JavaStr.h"
#import "NetworkProgressWheelController.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface KmlBackup()



@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation KmlBackup




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) backupFolderWithDate:(NSDate *)date error:(NSError * __autoreleasing *)error {
    
    // Calcula el nombre del fichero con el mapa, que es local y la hora
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_hh-mm-ss_z"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    // Añade la subcarpeta "backup"
    NSString *backupPathStr = [NSString stringWithFormat:@"/backup/%@/",dateString];
    
    //Get the get the path to the Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //Combine Documents directory path with your file name to get the full path
    NSString *fullBackupPath = [documentsDirectory stringByAppendingPathComponent:backupPathStr];
    
    // Asegura que existira
    *error = nil;
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:fullBackupPath withIntermediateDirectories:YES attributes:nil error:error];
    if(!result && *error==nil) {
        *error = [self _createError:@"Error creating backup folder" withError:nil data:nil];
        return nil;
    }
    
    // Retorna el resultado
    return fullBackupPath;
}

//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) backupLocalMap:(MMap *)map inFolder:(NSString *)folder error:(NSError * __autoreleasing *)error {
    
    // Calcula el texto KML del mapa
    NSString *kmlContent = [self _mapToKml:map];

    // Calcula el nombre del fichero con el mapa
    NSString *mapFilePath = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-local.kml",map.name]];
    
    // Graba el resultado al fichero de salida
    *error = nil;
    BOOL result = [kmlContent writeToFile:mapFilePath atomically:YES encoding:NSUTF8StringEncoding error:error];
    return result;
}

//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) backupRemoteMap:(GMTMap *)map inFolder:(NSString *)folder error:(NSError *__autoreleasing *)error {
    
#define MAP_GID_MARKED      @"/feeds/maps/"
#define DOWNLOAD_TIMEOUT    10
    
    
    // No se puede hacer backup si no hay mapa
    NSUInteger p1 = [map.gID indexOf:MAP_GID_MARKED];
    if(!map || p1==NSNotFound) {
        return TRUE;
    }
    
    // Separa ambas partes del ID
    NSArray *mapIDs = [[map.gID substringFromIndex:p1+MAP_GID_MARKED.length] componentsSeparatedByString:@"/"];
    if(mapIDs.count != 2) {
        *error = [self _createError:@"Remote map doesn't have a proper gID to download from Google Maps" withError:nil data:map];
        return FALSE;
    }

    // Compone la URL de peticion del mapa
    NSString *urlStr = [NSString stringWithFormat:@"https://maps.google.es/maps/ms?hl=en&ie=UTF8&vps=3&jsv=304e&oe=UTF8&msa=0&msid=%@.%@&output=kml",mapIDs[0],mapIDs[1]];
    
    // Hace la peticion para bajarse el contenido
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:DOWNLOAD_TIMEOUT];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    
    NSHTTPURLResponse *response = nil;
    [NetworkProgressWheelController start];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    [NetworkProgressWheelController stop];

    NSString *kmlContent = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    // Comprueba si fue bien
    if(*error!=nil) return FALSE;
    if(response.statusCode!=200 && response.statusCode!=201) {
        *error = [self _createError:[NSString stringWithFormat:@"Error downloading remote map '%@' from Google Maps (%@)", map.name, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]] withError:*error data:kmlContent];
        return FALSE;
    }
    if(kmlContent.length==0) {
        *error = [self _createError:[NSString stringWithFormat:@"Error downloading remote map '%@' from Google Maps (Zero bytes received)", map.name] withError:*error data:kmlContent];
        return FALSE;
    }
    
    // Calcula el nombre del fichero con el mapa
    NSString *mapFilePath = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-remote.kml",map.name]];
    
    // Graba el resultado al fichero de salida
    *error = nil;
    BOOL result = [kmlContent writeToFile:mapFilePath atomically:YES encoding:NSUTF8StringEncoding error:error];
    return result;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _mapToKml:(MMap *)map {

    
    NSMutableString *kmlStr = [NSMutableString stringWithString:@""];
    
    [kmlStr appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [kmlStr appendString:@"<kml xmlns=\"http://earth.google.com/kml/2.2\">\n"];
    [kmlStr appendString:@"<Document>\n"];
    [kmlStr appendFormat:@"  <name>%@</name>\n", map.name];
    [kmlStr appendFormat:@"  <description><![CDATA[%@]]></description>\n", map.summary];
    
    NSDictionary *styleIndexes = [self _calcStyleIndexes:map];
    [styleIndexes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *value, BOOL *stop) {
        [kmlStr appendFormat:@"  <Style id=\"style-%zd\">\n", value.integerValue];
        [kmlStr appendString:@"    <IconStyle>\n"];
        [kmlStr appendString:@"      <Icon>\n"];
        [kmlStr appendFormat:@"        <href>%@</href>\n", key];
        [kmlStr appendString:@"      </Icon>\n"];
        [kmlStr appendString:@"    </IconStyle>\n"];
        [kmlStr appendString:@"  </Style>\n"];
    }];
    
    for(MPoint *point in map.points) {
        if(!point.markedAsDeletedValue) {
            NSString *kmlPoint = [self _pointToKml:point withStyleIndexes:styleIndexes];
            [kmlStr appendString:kmlPoint];
        }
    }
    
    [kmlStr appendString:@"</Document>\n"];
    [kmlStr appendString:@"</kml>\n"];
    
    return  kmlStr;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _pointToKml:(MPoint *)point withStyleIndexes:(NSDictionary *)styleIndexes {
    
    NSNumber *index = [styleIndexes objectForKey:point.icon.iconHREF];
    if(index==nil) {
        index = [NSNumber numberWithUnsignedInteger:0];
    }
    
    NSMutableString *kmlStr = [NSMutableString stringWithString:@""];
    [kmlStr appendString:@"  <Placemark>\n"];
    [kmlStr appendFormat:@"    <name>%@</name>\n", [self _escapeStr:point.name]];
    [kmlStr appendFormat:@"    <description><![CDATA[%@]]></description>\n",[point combinedDescAndTagsInfo]];
    [kmlStr appendFormat:@"    <styleUrl>#style-%zd</styleUrl>\n", index.integerValue];
    [kmlStr appendString:@"    <Point>\n"];
    [kmlStr appendFormat:@"      <coordinates>%06f,%06f,0.000000</coordinates>\n", point.coordinate.longitude, point.coordinate.latitude];
    [kmlStr appendString:@"    </Point>\n"];
    [kmlStr appendString:@"  </Placemark>\n"];
    
    return kmlStr;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _escapeStr:(NSString *)value {

    value = [value replaceStr:@"&" with:@"&amp;"];
    value = [value replaceStr:@"|" with:@"&quot;"];
    value = [value replaceStr:@"<" with:@"&lt;"];
    value = [value replaceStr:@">" with:@"&gt;"];
    return value;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSDictionary *) _calcStyleIndexes:(MMap *)map {
    
    unsigned int index = 100;

    NSMutableDictionary *styleIndexes = [NSMutableDictionary dictionary];
    [styleIndexes setObject:[NSNumber numberWithUnsignedInt:0] forKey:@"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png"];
    
    for(MPoint *point in map.points) {
        
        if([styleIndexes objectForKey:point.icon.iconHREF]==nil) {
            [styleIndexes setObject:[NSNumber numberWithUnsignedInt:index] forKey:point.icon.iconHREF];
            index++;
        }
    }
    return styleIndexes;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSError *) _createError:(NSString *)desc withError:(NSError *)prevErr data:(id)data {
    
    NSString *content = data == nil ? @"" : [data description];
    NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             desc, NSLocalizedDescriptionKey,
                             [NSString stringWithFormat:@"Data: %@", content], @"ErrorData",
                             [NSString stringWithFormat:@"%@", prevErr], @"PreviousErrorInfo", nil];
    NSError *err = [NSError errorWithDomain:@"KmlBackup" code:200 userInfo:errInfo];
    return err;
}


@end

