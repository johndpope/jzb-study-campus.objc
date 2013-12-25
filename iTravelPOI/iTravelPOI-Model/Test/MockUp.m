//
// MockUp.m
// iTravelPOI
//
// Created by Jose Zarzuela on 16/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MockUp.h"
#import "NSManagedObjectContext+Utils.h"
#import "BaseCoreDataService.h"
#import "MMap.h"
#import "MPoint.h"
#import "MTag.h"
#import "MIcon.h"




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
+ (void) _setRandomLocationForPoint:(MPoint *)point {
    //[point setLatitude:((int)(arc4random() % 180) - 90) longitude:((int)(arc4random() % 360) - 180)];
    [point setLatitude:(41+(int)(arc4random() % 10) - 5) longitude:(-3+(int)(arc4random() % 10) - 5)];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) populateModel {

    if(!_init_model_) return;

    NSManagedObjectContext *moContext = [BaseCoreDataService moContext];

    // -------------------------------------------------------
    MMap *map1 = [MMap emptyMapWithName:@"@map1" inContext:moContext];
    MMap *map2 = [MMap emptyMapWithName:@"@map2" inContext:moContext];
    MMap *map3 = [MMap emptyMapWithName:@"@map3" inContext:moContext];

    
    // -------------------------------------------------------
    // TAGs
    MTag *tag1 = [MTag tagByName:@"tag_1" inContext:moContext];
    MTag *tag2 = [MTag tagByName:@"tag_2" inContext:moContext];
    MTag *tag3 = [MTag tagByName:@"tag_3" inContext:moContext];
    MTag *tag4 = [MTag tagByName:@"tag_4" inContext:moContext];
    MTag *tag5 = [MTag tagByName:@"tag_5" inContext:moContext];
    
    // -------------------------------------------------------
    MPoint *point;
    NSString *iconHref_0 = @"http://maps.gstatic.com/mapfiles/ms2/micons/yellow-dot.png";
    NSString *iconHref_1 = @"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png";
    NSString *iconHref_2 = @"http://maps.gstatic.com/mapfiles/ms2/micons/red-dot.png";

    point = [MPoint emptyPointWithName:@"p0" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_0 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag1, nil]];

    point = [MPoint emptyPointWithName:@"p1" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag1, tag2, nil]];
    
    point = [MPoint emptyPointWithName:@"p2" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag1, tag3, nil]];

    point = [MPoint emptyPointWithName:@"p3" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag1, tag4, nil]];
    
    point = [MPoint emptyPointWithName:@"p4" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag2, tag3, nil]];
    
    point = [MPoint emptyPointWithName:@"p5" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag2, tag4, nil]];

    point = [MPoint emptyPointWithName:@"p6" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag2, tag3, tag4, nil]];

    point = [MPoint emptyPointWithName:@"p7" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag1, tag4, nil]];

    point = [MPoint emptyPointWithName:@"p8" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag3, tag1, nil]];

    point = [MPoint emptyPointWithName:@"p_pos_fija" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag4, nil]];
    [point setLatitude:41.464003 longitude:-2.862453];
    
    
    // -----------------------------
    point = [MPoint emptyPointWithName:@"pA" inMap:map2];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag2, nil]];

    point = [MPoint emptyPointWithName:@"pb" inMap:map2];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag1, tag4, nil]];
    
    point = [MPoint emptyPointWithName:@"pC" inMap:map2];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag2, tag3, nil]];

    point = [MPoint emptyPointWithName:@"pD" inMap:map2];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag3, tag4, nil]];

    // -----------------------------
    point = [MPoint emptyPointWithName:@"pX" inMap:map3];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [point addTags:[NSSet setWithObjects:tag5, nil]];



    if([moContext saveChanges]) {
        DDLogVerbose(@"****** DATA MODEL SQLITE FILE PRE-POPULATED ******");
    } else {
        DDLogVerbose(@"****** ERROR SAVING PRE-POPULATED DATA MODEL ******");
    }


}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) listModel {
    
    if(!_init_model_) return;
    
    NSLog(@"----- listModel ------------------------------------------------------------------------");

    NSManagedObjectContext *moContext = [BaseCoreDataService moContext];
    
    //NSArray *maps = [MMap allMapsInContext:moContext includeMarkedAsDeleted:TRUE];
    //for(MMap *map in maps) {
    //    DDLogVerbose(@"%@", map);
    //}

    // NSArray *tags = [MTag allTagsInContext:moContext];
    // for(MTag *tag in tags) {
    //    DDLogVerbose(@"%@", tag);
    //}
    
    MTag *tag1 = [MTag tagByName:@"tag_1" inContext:moContext];
    MTag *tag2 = [MTag tagByName:@"tag_2" inContext:moContext];
    MTag *tag3 = [MTag tagByName:@"tag_3" inContext:moContext];
    MTag *tag4 = [MTag tagByName:@"tag_4" inContext:moContext];
    MTag *tag5 = [MTag tagByName:@"tag_5" inContext:moContext];
    NSSet *tags = [NSSet setWithObjects:tag1, tag5, nil];
    tags = [NSSet set];
    
    NSArray *points = [MPoint pointsTaggedWith:tags inMap:nil InContext:moContext];
    for(MPoint *point in points) {
        BOOL first = TRUE;
        NSMutableString *tags = [NSMutableString stringWithString:@"["];
        for(MTag *tag in point.tags) {
            if(!first) [tags appendString:@", "];
            [tags appendString:tag.name];
            first = FALSE;
        }
        [tags appendString:@"]"];

        DDLogVerbose(@"%@ - %@", point.name, tags);
    }
    
    NSArray *tags2 = [MTag tagsForPointsTaggedWith:tags InContext:moContext];
    for(MTag *tag in tags2) {
        DDLogVerbose(@"%@", tag.name);
    }

    NSLog(@"----- listModel ------------------------------------------------------------------------");
}


@end


