//
// MockUp.m
// iTravelPOI
//
// Created by Jose Zarzuela on 16/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "MockUp.h"
#import "NSString+JavaStr.h"
#import "NSManagedObjectContext+Utils.h"
#import "BaseCoreDataService.h"
#import "ErrorManagerService.h"
#import "MMap.h"
#import "MPoint.h"
#import "MTag.h"
#import "MIcon.h"
#import "MComplexFilter.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark MockUp implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation MockUp

BOOL _init_model_ = TRUE;



// *********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
/*
 Cosas varias:

 DDLogVerbose(@"** Geocoding");
 // 40.427382,-3.600941
 NSError *error=nil;
 NSStringEncoding encoding = -1;
 NSURL *theURL = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/geocode/xml?latlng=32.62,1.26&sensor=false&language=es"];
 NSString *str2 = [NSString stringWithContentsOfURL:theURL usedEncoding:&encoding error:&error];
 DDLogVerbose(@"Error: %@", error);
 DDLogVerbose(@"str: %@", str2);

 */

// ---------------------------------------------------------------------------------------------------------------------
+ (NSURL *) applicationDocumentsDirectory {

    // Returns the directory the application uses to store the Core Data store file.
    // This code uses a directory named "com.zetLabs.APP-NAME" in the user's Application Support directory.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *bundleAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *appSubfolder = [NSString stringWithFormat:@"com.zetLabs.%@", bundleAppName];
    NSURL *appDocDir = [appSupportURL URLByAppendingPathComponent:appSubfolder];

    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:[appDocDir path] withIntermediateDirectories:YES attributes:nil error:&error]) {
        DDLogVerbose(@"MockUp - Error getting Application Documents Directory: %@, %@", error, [error userInfo]);
        exit(1);
    }

    return appDocDir;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) resetModel:(NSString *)modelName {

    if(!_init_model_) return;


    NSLog(@"----- RESET DATA MODEL ------------------------------------------------------------------------");
    
    NSString *sqliteFileName = [NSString stringWithFormat:@"%@.sqlite", modelName];
    NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:sqliteFileName];


    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;

    if([storeURL checkResourceIsReachableAndReturnError:&error]) {
        if(![fileManager removeItemAtURL:storeURL error:&error]) {
            DDLogVerbose(@"Error removing data file: %@, %@", error, [error userInfo]);
            exit(1);
        } else {
            DDLogVerbose(@"****** DATA MODEL SQLITE FILE ERASED ******");
        }
    } else {
        DDLogVerbose(@"****** DATA MODEL SQLITE FILE DIDN'T EXIST AND COULDN'T BE ERASED ******");
    }

}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _testIconHREF:(NSString *)catPath {

    return [NSString stringWithFormat:@"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png?pcat=%@", catPath];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _setRandomLocationForPoint:(MPoint *)point {
    //[point updateLatitude:((int)(arc4random() % 180) - 90) longitude:((int)(arc4random() % 360) - 180)];
    [point updateLatitude:(41+(int)(arc4random() % 10) - 5) longitude:(-3+(int)(arc4random() % 10) - 5)];
}


// ---------------------------------------------------------------------------------------------------------------------
+ (void) _toPoint:(MPoint *)point addTag:(MTag *)tag  {
    
    [tag tagPoint:point];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) _toPoint:(MPoint *)point addTags:(NSSet *)tags  {
    
    for(MTag *tag in tags) {
        [tag tagPoint:point];
    }
}


// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) _testTags1:(NSSet *)tags moContext:(NSManagedObjectContext *)moContext {
    
    NSLog(@"----- MockUp - _testTags1 - in ---------------------------------------------------------------");
    NSDate *start = [NSDate date];
    
    MComplexFilter *filter = [MComplexFilter filterWithContext:moContext];
    filter.filterTags = tags;
    filter.filterMap = nil;
    //NSArray *allPoints = filter.pointList;
    NSSet *filteredTags = filter.tagsForPointList;

    // Ordena el set
    NSMutableArray *array = [NSMutableArray arrayWithArray:[filteredTags allObjects]];
    [array sortedArrayUsingComparator:^NSComparisonResult(MTag *tag1, MTag *tag2) {
        
        NSComparisonResult result;
        
        result = [tag1.isAutoTag compare:tag2.isAutoTag];
        if(result!=NSOrderedSame) return result;
        
        result = [tag1.name compare:tag2.name];
        return result;
    }];

    
    NSLog(@"MockUp - _testTags1 - out = %f",[start timeIntervalSinceNow]);
    
    //    for(MTag *tag in array) {
    //        NSLog(@"tag - %@",tag.name);
    //    }
    
    NSLog(@"-- %ld --", (unsigned long)array.count);
    
    return array;
}


// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) _testPoint1:(NSSet *)tags moContext:(NSManagedObjectContext *)moContext {
    
    
    NSLog(@"----- MockUp - _testPoint1 - in ---------------------------------------------------------------");
    NSDate *start = [NSDate date];
    
    
    MComplexFilter *filter = [MComplexFilter filterWithContext:moContext];
    filter.filterTags = tags;
    filter.filterMap = nil;
    NSArray *array = filter.pointList;
    
    
    NSLog(@"MockUp - _testPoint1 - out = %f",[start timeIntervalSinceNow]);
    
    //    for(MPoint *obj in array) {
    //        NSLog(@"%@",obj.name);
    //    }
    
    NSLog(@"-- %ld --", (unsigned long)array.count);
    return array;
}


// ---------------------------------------------------------------------------------------------------------------------
+ (void) listModel {
    
    if(!_init_model_) return;

    NSLog(@"----- listModel ------------------------------------------------------------------------");
    
    /*
    NSManagedObjectContext *moContext = [BaseCoreDataService moContext];
    
    //NSSet *tagSet = [NSSet setWithObjects:[MTag tagWithFullName:@"GMI_green" parentTag:nil inContext:moContext], [MTag tagWithFullName:@"Zona Norte|Z.N. - Oporto|Oporto" parentTag:nil inContext:moContext1], nil];
    //NSSet *tagSet = [NSSet setWithObjects:[MTag tagWithFullName:@"Zona Norte" parentTag:nil inContext:moContext], nil];
    //NSSet *tagSet = [NSSet setWithObjects:[MTag tagWithFullName:@"GMI_blue-dot" parentTag:nil inContext:moContext], nil];
    //NSSet *tagSet = [NSSet setWithObjects:[MTag tagWithFullName:@"Zona Norte|Z.N. - Oporto|Oporto" parentTag:nil inContext:moContext], [MTag tagWithFullName:@"GMI_blue-dot" parentTag:nil inContext:moContext1], nil];
    //NSSet *tagSet = [NSSet setWithObjects:[MTag tagWithFullName:@"Zona Norte|Z.N. - Oporto|Oporto" parentTag:nil inContext:moContext], nil];
    
    
    //NSArray *a1;
    //a1=[MockUp _testPoint1:tagSet moContext:moContext];
    //a1=[MockUp _testPoint1:tagSet moContext:moContext];
    // a1=[MockUp _testTags1:tagSet moContext:moContext];
    //a1=[MockUp _testTags1:tagSet moContext:moContext];
    

    MComplexFilter *complexFilter = [MComplexFilter filterWithContext:moContext];
    
    
    //[complexFilter reset];
    //NSLog(@"count = %ld", (unsigned long)complexFilter.pointList.count);
    //NSLog(@"ya");
    

    NSSet *filterTagSet;
    filterTagSet = [NSSet setWithObjects:
                    [MTag tagWithFullName:@"GMI_blue-dot" parentTag:nil inContext:moContext], nil];
    filterTagSet = [NSSet setWithObjects:
                    [MTag tagWithFullName:@"Zona Norte|Z.N. - Oporto|Oporto" parentTag:nil inContext:moContext], nil];
    
    [complexFilter reset];
    complexFilter.filterTags = filterTagSet;
    NSLog(@"count = %ld", (unsigned long)complexFilter.pointList.count);
    NSLog(@"ya");
    */

    NSLog(@"----- listModel ------------------------------------------------------------------------");
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) populateModelFromPListFiles {
    
    if(!_init_model_) return;
    
    NSLog(@"----- POPULATE DATA MODEL FROM PLIST ------------------------------------------------------------------------");

    NSManagedObjectContext *moContext = [BaseCoreDataService moContext];

    NSString *bundlePathName = [[NSBundle mainBundle] bundlePath];
    NSString *dataPathName = [bundlePathName stringByAppendingPathComponent:@"_PLISTs_.bundle"];

    NSError *localError = nil;
    NSArray *bundleFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPathName error:&localError];
    for(NSString *fileName in bundleFiles) {
        if([fileName hasSuffix:@".plist"]) {
            //            if(![fileName isEqualToString:@"HT_Portugal_2013.plist"]) {
            //                continue;
            //            }
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", dataPathName, fileName];
            [MockUp _loadPListMapFromPath:filePath inContext:moContext];
        }
    }
    
    [BaseCoreDataService.moContext saveChanges];
}


//---------------------------------------------------------------------------------------------------------------------
+ (void) _loadPListMapFromPath:(NSString *)filePath inContext:(NSManagedObjectContext *)moContext {
    
    
    DDLogVerbose(@"");
    DDLogVerbose(@"---------------------------------------------------------------------------");
    DDLogVerbose(@"Reading map info from: %@", filePath);
    NSDictionary *mapInfo = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if(!mapInfo) {
        DDLogVerbose(@"*** ERROR reading map plist file");
        return;
    }

    NSString *mapName = [mapInfo valueForKey:@"mapName"];

    DDLogVerbose(@"Map name: %@",mapName);
    
    MMap *map = [MMap emptyMapWithName:mapName inContext:moContext];

    
    NSMutableDictionary *readPois = [NSMutableDictionary dictionary];
    NSArray *poiList = [mapInfo valueForKey:@"pois"];
    for(NSDictionary *poiInfo in poiList) {
        NSNumber *poiIndex = [poiInfo valueForKey:@"index"];
        NSString *poiName = [poiInfo valueForKey:@"name"];
        NSString *poiDesc = [poiInfo valueForKey:@"desc"];
        NSString *poiIcon = [poiInfo valueForKey:@"icon"];
        NSNumber *poiLat = [poiInfo valueForKey:@"lat"];
        NSNumber *poiLng = [poiInfo valueForKey:@"lng"];

        DDLogVerbose(@"");
        DDLogVerbose(@"  POI name: '%@' / index: %@", poiName, poiIndex);
        DDLogVerbose(@"      icon: %@", poiIcon);
        DDLogVerbose(@"      lat: %@  lng: %@", poiLat,poiLng);
        DDLogVerbose(@"      desc: '%@'", poiDesc);
        
        MPoint *point = [MPoint emptyPointWithName:poiName inMap:map];
        [point updateLatitude:[poiLat doubleValue] longitude:[poiLng doubleValue]];
        [point updateIcon:[MIcon iconForHref:poiIcon inContext:moContext]];
        [readPois setObject:point forKey:poiIndex];
    }
    
    
    NSMutableDictionary *readTags = [NSMutableDictionary dictionary];
    NSArray *tagList = [mapInfo valueForKey:@"tags"];
    for(NSDictionary *tagInfo in tagList) {
        NSNumber *tagIndex = [tagInfo valueForKey:@"index"];
        NSString *tagName = [tagInfo valueForKey:@"name"];
        [readTags setObject:tagName forKey:tagIndex];
    }

    for(NSDictionary *tagInfo in tagList) {
        NSNumber *tagIndex = [tagInfo valueForKey:@"index"];
        NSString *parentTagName = [readTags objectForKey:tagIndex];
        NSArray *tagIndexList = [tagInfo valueForKey:@"tagIndexes"];
        for(NSString *tagIndexStr in tagIndexList) {
            NSUInteger p1 = [tagIndexStr indexOf:@"-"];
            if(p1==NSNotFound) {
                NSNumber *index = [NSNumber numberWithLong:[tagIndexStr integerValue]];
                NSString *childTagName = [readTags objectForKey:index];
                [readTags setObject:[NSString stringWithFormat:@"%@%@%@",parentTagName,TAG_NAME_SEPARATOR,childTagName] forKey:index];
            } else {
                NSString *startStrIndex = [tagIndexStr subStrFrom:0 to:p1];
                NSString *endStrIndex = [tagIndexStr substringFromIndex:p1+1];
                int sIndex = [startStrIndex intValue];
                int eIndex = [endStrIndex intValue];
                for(int n=sIndex;n<=eIndex;n++) {
                    NSNumber *index = [NSNumber numberWithInt:n];
                    NSString *childTagName = [readTags objectForKey:index];
                    [readTags setObject:[NSString stringWithFormat:@"%@%@%@",parentTagName,TAG_NAME_SEPARATOR,childTagName] forKey:index];
                }
            }
        }
    }
    
    
    for(NSDictionary *tagInfo in tagList) {
        
        NSNumber *tagIndex = [tagInfo valueForKey:@"index"];
        NSString *tagName = [readTags objectForKey:tagIndex];
        
        MTag *tag = [MTag tagWithFullName:tagName inContext:moContext];
        
        NSArray *poiIndexList = [tagInfo valueForKey:@"poiIndexes"];
        for(NSString *poiIndexStr in poiIndexList) {
            NSUInteger p1 = [poiIndexStr indexOf:@"-"];
            if(p1==NSNotFound) {
                NSNumber *index = [NSNumber numberWithLong:[poiIndexStr integerValue]];
                MPoint *point = [readPois objectForKey:index];
                if(point) {
                    [MockUp _toPoint:point addTag:tag];
                }
            } else {
                NSString *startStrIndex = [poiIndexStr subStrFrom:0 to:p1];
                NSString *endStrIndex = [poiIndexStr substringFromIndex:p1+1];
                int sIndex = [startStrIndex intValue];
                int eIndex = [endStrIndex intValue];
                for(int n=sIndex;n<=eIndex;n++) {
                    NSNumber *index = [NSNumber numberWithInt:n];
                    MPoint *point = [readPois objectForKey:index];
                    if(point) {
                        [MockUp _toPoint:point addTag:tag];
                    }
                }
            }
        }
        
    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (void)timerFired:(NSTimer *)timer {
    
    NSManagedObjectContext *moContext = [BaseCoreDataService moContext];
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MPoint"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"locationTag=nil"];
    [request setPredicate:query];
    
    // Solo queremos un elemento
    [request setFetchLimit:1];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MockUp" messageWithFormat:@"MockUp:timerFired - Error fetching points without locationTag"];
    }
    
    if(array.count>0) {
        
        MPoint *point = array[0];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:point.latitudeValue  longitude:point.longitudeValue];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"Error fetching point location %@", error.description);
            } else {
                CLPlacemark *placemark = [placemarks lastObject];
                
                DDLogVerbose(@"placemark:");
                DDLogVerbose(@"  name                  = %@",placemark.name);
                DDLogVerbose(@"  ISOcountryCode        = %@",placemark.ISOcountryCode);
                DDLogVerbose(@"  country               = %@",placemark.country);
                DDLogVerbose(@"  locality              = %@",placemark.locality);
                DDLogVerbose(@"  subLocality           = %@",placemark.subLocality);
                DDLogVerbose(@"  administrativeArea    = %@",placemark.administrativeArea);
                DDLogVerbose(@"  subAdministrativeArea = %@",placemark.subAdministrativeArea);
                DDLogVerbose(@"  region                = %@",placemark.region);
                DDLogVerbose(@"  postalCode            = %@",placemark.postalCode);
                DDLogVerbose(@"  thoroughfare          = %@",placemark.thoroughfare);
                DDLogVerbose(@"  subThoroughfare       = %@",placemark.subThoroughfare);
                DDLogVerbose(@"  inlandWater           = %@",placemark.inlandWater);
                DDLogVerbose(@"  ocean                 = %@",placemark.ocean);
                DDLogVerbose(@"  areasOfInterest   = %@",placemark.areasOfInterest);
                DDLogVerbose(@"  addressDictionary = %@",placemark.addressDictionary);
                
            }
        }];
        
    } else {
        NSLog(@"Ya estan todos!");
    }
    
    
}

@end


