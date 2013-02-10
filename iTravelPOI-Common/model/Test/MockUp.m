//
// MockUp.m
// iTravelPOI
//
// Created by Jose Zarzuela on 16/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MockUp.h"
#import "BaseCoreData.h"
#import "MMap.h"
#import "MPoint.h"
#import "MCategory.h"




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

 NSLog(@"** Geocoding");
 // 40.427382,-3.600941
 NSError *error=nil;
 NSStringEncoding encoding = -1;
 NSURL *theURL = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/geocode/xml?latlng=32.62,1.26&sensor=false&language=es"];
 NSString *str2 = [NSString stringWithContentsOfURL:theURL usedEncoding:&encoding error:&error];
 NSLog(@"Error: %@", error);
 NSLog(@"str: %@", str2);

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
        NSLog(@"MockUp - Error getting Application Documents Directory: %@, %@", error, [error userInfo]);
        exit(1);
    }

    return appDocDir;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) resetModel:(NSString *)modelName {

    if(!_init_model_) return;


    NSString *sqliteFileName = [NSString stringWithFormat:@"%@.sqlite", modelName];
    NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:sqliteFileName];


    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;

    if([storeURL checkResourceIsReachableAndReturnError:&error]) {
        if(![fileManager removeItemAtURL:storeURL error:&error]) {
            NSLog(@"Error removing data file: %@, %@", error, [error userInfo]);
            exit(1);
        } else {
            NSLog(@"****** DATA MODEL SQLITE FILE ERASED ******");
        }
    } else {
        NSLog(@"****** DATA MODEL SQLITE FILE DIDN'T EXIST AND COULDN'T BE ERASED ******");
    }

}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _testIconHREF:(NSString *)catPath {

    return [NSString stringWithFormat:@"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png?pcat=%@", catPath];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) populateModel {

    if(!_init_model_) return;

    NSManagedObjectContext *moContext = [BaseCoreData moContext];

    // -------------------------------------------------------
    MMap *map1 = [MMap emptyMapWithName:@"@map1" inContext:moContext];

    
    // -------------------------------------------------------
    MPoint *point;
    NSString *baseURL1 = @"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png";
    NSString *baseURL2 = @"http://maps.gstatic.com/mapfiles/ms2/micons/red-dot.png";
    
    point = [MPoint emptyPointWithName:@"p0" inMap:map1 withCategory:[MCategory categoryForIconBaseHREF:baseURL1 extraInfo:@"rest#" inContext:moContext]];
    
    point = [MPoint emptyPointWithName:@"p1" inMap:map1 withCategory:[MCategory categoryForIconBaseHREF:baseURL1 extraInfo:@"rest#chino#" inContext:moContext]];

    point = [MPoint emptyPointWithName:@"p2" inMap:map1 withCategory:[MCategory categoryForIconBaseHREF:baseURL1 extraInfo:@"rest#veg#" inContext:moContext]];
    point = [MPoint emptyPointWithName:@"p3" inMap:map1 withCategory:[MCategory categoryForIconBaseHREF:baseURL1 extraInfo:@"rest#veg#eco#" inContext:moContext]];
    point = [MPoint emptyPointWithName:@"p4" inMap:map1 withCategory:[MCategory categoryForIconBaseHREF:baseURL1 extraInfo:@"rest#veg#dise#" inContext:moContext]];

    point = [MPoint emptyPointWithName:@"p5" inMap:map1 withCategory:[MCategory categoryForIconBaseHREF:baseURL1 extraInfo:@"rest#trad#" inContext:moContext]];
    point = [MPoint emptyPointWithName:@"p6" inMap:map1 withCategory:[MCategory categoryForIconBaseHREF:baseURL1 extraInfo:@"rest#trad#esp#" inContext:moContext]];
    point = [MPoint emptyPointWithName:@"p7" inMap:map1 withCategory:[MCategory categoryForIconBaseHREF:baseURL1 extraInfo:@"rest#trad#belga#" inContext:moContext]];

    point = [MPoint emptyPointWithName:@"p8" inMap:map1 withCategory:[MCategory categoryForIconBaseHREF:baseURL2 extraInfo:@"casas#" inContext:moContext]];


    if([BaseCoreData saveContext]) {
        NSLog(@"****** DATA MODEL SQLITE FILE PRE-POPULATED ******");
    } else {
        NSLog(@"****** ERROR SAVING PRE-POPULATED DATA MODEL ******");
    }


}

@end


