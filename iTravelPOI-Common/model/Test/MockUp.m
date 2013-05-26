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
+ (void) populateModel {

    if(!_init_model_) return;

    NSManagedObjectContext *moContext = [BaseCoreData moContext];

    // -------------------------------------------------------
    MMap *map1 = [MMap emptyMapWithName:@"@map1" inContext:moContext];
    MMap *map2 = [MMap emptyMapWithName:@"@map2" inContext:moContext];
    MMap *map3 = [MMap emptyMapWithName:@"@map3" inContext:moContext];

    
    // -------------------------------------------------------
    MCategory *cat1 = [MCategory categoryWithFullName:@"rest" inContext:moContext];
    MCategory *cat1_1 = [MCategory categoryWithFullName:@"rest.chino" inContext:moContext];
    MCategory *cat1_2 = [MCategory categoryWithFullName:@"rest.veg" inContext:moContext];
    MCategory *cat1_2_1 = [MCategory categoryWithFullName:@"rest.veg.eco" inContext:moContext];
    MCategory *cat1_2_2 = [MCategory categoryWithFullName:@"rest.veg.dise" inContext:moContext];
    MCategory *cat1_3 = [MCategory categoryWithFullName:@"rest.trad" inContext:moContext];
    MCategory *cat1_3_1 = [MCategory categoryWithFullName:@"rest.trad.esp" inContext:moContext];
    MCategory *cat1_3_2 = [MCategory categoryWithFullName:@"rest.trad.belga" inContext:moContext];
    MCategory *cat2 = [MCategory categoryWithFullName:@"casas" inContext:moContext];

    MCategory *cat3_1 = [MCategory categoryWithFullName:@"ny.cpark" inContext:moContext];
    MCategory *cat3_2 = [MCategory categoryWithFullName:@"ny.soho" inContext:moContext];
    MCategory *cat4_1 = [MCategory categoryWithFullName:@"francia.loira" inContext:moContext];
    MCategory *cat4_2 = [MCategory categoryWithFullName:@"francia.bretaña" inContext:moContext];

    
    // -------------------------------------------------------
    MPoint *point;
    NSString *iconHref_0 = @"http://maps.gstatic.com/mapfiles/ms2/micons/yellow-dot.png";
    NSString *iconHref_1 = @"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png";
    NSString *iconHref_2 = @"http://maps.gstatic.com/mapfiles/ms2/micons/red-dot.png";

    point = [MPoint emptyPointWithName:@"p0" inMap:map1];
    point.iconHREF=iconHref_0;

    point = [MPoint emptyPointWithName:@"p1" inMap:map1];
    point.iconHREF=iconHref_1;
    [point addToCategory:cat1];
    
    point = [MPoint emptyPointWithName:@"p2" inMap:map1];
    point.iconHREF=iconHref_1;
    [point addToCategory:cat1_1];

    point = [MPoint emptyPointWithName:@"p3" inMap:map1];
    point.iconHREF=iconHref_1;
    [point addToCategory:cat1_2];
    
    point = [MPoint emptyPointWithName:@"p4" inMap:map1];
    point.iconHREF=iconHref_1;
    [point addToCategory:cat1_2_1];
    
    point = [MPoint emptyPointWithName:@"p5" inMap:map1];
    point.iconHREF=iconHref_1;
    [point addToCategory:cat1_2_2];

    point = [MPoint emptyPointWithName:@"p6" inMap:map1];
    point.iconHREF=iconHref_1;
    [point addToCategory:cat1_3];

    point = [MPoint emptyPointWithName:@"p7" inMap:map1];
    point.iconHREF=iconHref_2;
    [point addToCategory:cat1_3_1];

    point = [MPoint emptyPointWithName:@"p8" inMap:map1];
    point.iconHREF=iconHref_2;
    [point addToCategory:cat1_3_2];

    point = [MPoint emptyPointWithName:@"p99" inMap:map1];
    point.iconHREF=iconHref_2;
    [point addToCategory:cat2];
    [point setLatitude:41.464003 longitude:-2.862453];
    
    
    // -----------------------------
    point = [MPoint emptyPointWithName:@"pA" inMap:map2];
    point.iconHREF=iconHref_2;
    [point addToCategory:cat3_1];

    point = [MPoint emptyPointWithName:@"pb" inMap:map2];
    point.iconHREF=iconHref_2;
    [point addToCategory:cat3_2];
    
    point = [MPoint emptyPointWithName:@"pC" inMap:map2];
    point.iconHREF=iconHref_2;
    [point addToCategory:cat4_1];

    point = [MPoint emptyPointWithName:@"pD" inMap:map2];
    point.iconHREF=iconHref_2;
    [point addToCategory:cat2];

    // -----------------------------
    point = [MPoint emptyPointWithName:@"pX" inMap:map3];
    point.iconHREF=iconHref_2;
    [point addToCategory:cat4_2];



    if([BaseCoreData saveContext]) {
        DDLogVerbose(@"****** DATA MODEL SQLITE FILE PRE-POPULATED ******");
    } else {
        DDLogVerbose(@"****** ERROR SAVING PRE-POPULATED DATA MODEL ******");
    }


}

@end


