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
    //[point setLatitude:((int)(arc4random() % 180) - 90) longitude:((int)(arc4random() % 360) - 180)];
    [point setLatitude:(41+(int)(arc4random() % 10) - 5) longitude:(-3+(int)(arc4random() % 10) - 5)];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) populateModel {

    if(!_init_model_) return;

    NSLog(@"----- POPULATE DATA MODEL ------------------------------------------------------------------------");

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
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag1, nil]];

    point = [MPoint emptyPointWithName:@"p1" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag1, tag2, nil]];
    
    point = [MPoint emptyPointWithName:@"p2" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag1, tag3, nil]];

    point = [MPoint emptyPointWithName:@"p3" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag1, tag4, nil]];
    
    point = [MPoint emptyPointWithName:@"p4" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag2, tag3, nil]];
    
    point = [MPoint emptyPointWithName:@"p5" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag2, tag4, nil]];

    point = [MPoint emptyPointWithName:@"p6" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_1 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag2, tag3, tag4, nil]];

    point = [MPoint emptyPointWithName:@"p7" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag1, tag4, nil]];

    point = [MPoint emptyPointWithName:@"p8" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag3, tag1, nil]];

    point = [MPoint emptyPointWithName:@"p_pos_fija" inMap:map1];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag4, nil]];
    [point setLatitude:41.464003 longitude:-2.862453];
    
    
    // -----------------------------
    point = [MPoint emptyPointWithName:@"pA" inMap:map2];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag2, nil]];

    point = [MPoint emptyPointWithName:@"pb" inMap:map2];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag1, tag4, nil]];
    
    point = [MPoint emptyPointWithName:@"pC" inMap:map2];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag2, tag3, nil]];

    point = [MPoint emptyPointWithName:@"pD" inMap:map2];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag3, tag4, nil]];

    // -----------------------------
    point = [MPoint emptyPointWithName:@"pX" inMap:map3];
    [MockUp _setRandomLocationForPoint:point];
    [point updateIcon: [MIcon iconForHref:iconHref_2 inContext:moContext]];
    [MockUp _toPoint:point addTags:[NSSet setWithObjects:tag5, nil]];



    if([moContext saveChanges]) {
        DDLogVerbose(@"****** DATA MODEL SQLITE FILE PRE-POPULATED ******");
    } else {
        DDLogVerbose(@"****** ERROR SAVING PRE-POPULATED DATA MODEL ******");
    }


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
    
    
    NSArray *array = [MTag tagsForPointsTaggedWith:tags InContext:moContext];

    NSLog(@"MockUp - _testTags1 - out = %f",[start timeIntervalSinceNow]);
    
    for(MTag *tag in array) {
        //NSLog(@"tag - %@",tag.name);
    }
    
    NSLog(@"--");
    
    return array;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) _testTags2:(NSSet *)tags moContext:(NSManagedObjectContext *)moContext {
    
    NSLog(@"----- MockUp - _testTags2 - in ---------------------------------------------------------------");
    NSDate *start = [NSDate date];
    
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RPointTag"];

    
    NSExpressionDescription* expDesc = [[NSExpressionDescription alloc] init];
    [expDesc setName: @"count2"];
    [expDesc setExpressionResultType: NSInteger32AttributeType];
    [expDesc setExpression: [NSExpression expressionWithFormat:@"isDirect.@count"]];
    
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"point", expDesc, nil]];
    [request setResultType:NSDictionaryResultType];
    

    [request setPropertiesToGroupBy:[NSArray arrayWithObject:@"point"]];
    
    

    
    // Se asigna una condicion de filtro
    NSString *queryStr = @"point.markedAsDeleted=NO AND tag IN %@";
    NSPredicate *query = [NSPredicate predicateWithFormat:queryStr, tags];
    [request setPredicate:query];
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"point.name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortNameDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MTag:tagsForPointsTaggedWith - Error fetching tags for points tagged in context [tags=%@]",tags];
    }
    
    NSMutableSet *allTags = [NSMutableSet set];
    for(NSDictionary *dict in array) {
        if([[dict objectForKey:@"count2"] intValue]>=tags.count) {
            NSManagedObjectID *objID = [dict objectForKey:@"point"];
            MPoint *obj = (MPoint *)[moContext objectWithID:objID];
            [allTags unionSet:[obj.rTags valueForKey:@"tag"]];
        }
    }
    
    
    NSLog(@"MockUp - _testTags2 - out = %f",[start timeIntervalSinceNow]);
    
    for(MTag *tag in allTags) {
        //NSLog(@"tag - %@",tag.name);
    }
    
    NSLog(@"--");
    return  [allTags allObjects];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) _testPoint1:(NSSet *)tags moContext:(NSManagedObjectContext *)moContext {
    
    NSLog(@"----- MockUp - _testPoint1 - in ---------------------------------------------------------------");
    NSDate *start = [NSDate date];
    
    
    NSArray *array = [MPoint pointsTaggedWith:tags inMap:nil InContext:moContext];
    
    
    NSLog(@"MockUp - _testPoint1 - out = %f",[start timeIntervalSinceNow]);
    
    for(MPoint *obj in array) {
        //NSLog(@"%@",obj.name);
    }
    
    NSLog(@"--");
    return array;
}


// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) _testPoint2:(NSSet *)tags moContext:(NSManagedObjectContext *)moContext {
    
    NSLog(@"----- MockUp - _testPoint2 - in ---------------------------------------------------------------");
    NSDate *start = [NSDate date];
    
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RPointTag"];
    
    
    NSExpressionDescription* expDesc = [[NSExpressionDescription alloc] init];
    [expDesc setName: @"count2"];
    [expDesc setExpressionResultType: NSInteger32AttributeType];
    [expDesc setExpression: [NSExpression expressionWithFormat:@"isDirect.@count"]];
    
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"point", expDesc, nil]];
    [request setResultType:NSDictionaryResultType];
    
    
    [request setPropertiesToGroupBy:[NSArray arrayWithObject:@"point"]];
    
    
    
    
    // Se asigna una condicion de filtro
    NSString *queryStr = @"point.markedAsDeleted=NO AND tag IN %@";
    NSPredicate *query = [NSPredicate predicateWithFormat:queryStr, tags];
    [request setPredicate:query];
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"point.name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortNameDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MTag:tagsForPointsTaggedWith - Error fetching tags for points tagged in context [tags=%@]",tags];
    }
    
    //NSArray *array2 = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"count2 >= %ld",tags.count]];
    
    NSMutableArray *array3 = [NSMutableArray arrayWithCapacity:array.count];
    for(NSDictionary *dict in array) {
        NSNumber *count2=[dict objectForKey:@"count2"];
        if(count2.intValue>=tags.count) {
            NSManagedObjectID *objID = [dict objectForKey:@"point"];
            MPoint *obj = (MPoint *)[moContext objectWithID:objID];
            [array3 addObject:obj];
        }
    }
    
    NSLog(@"MockUp - _testPoint2 - out = %f",[start timeIntervalSinceNow]);
    
    for(MPoint *obj in array3) {
        //NSLog(@"%@",obj.name);
    }
    
    NSLog(@"--");
    
    return array3;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) listModel {
    
    NSManagedObjectContext *moContext1 = [BaseCoreDataService moContext];
    //NSSet *tagSet= [NSSet setWithObjects:[MTag tagByName:@"GMI_green" inContext:moContext1], [MTag tagByName:@"Oporto" inContext:moContext1], nil];
    //NSSet *tagSet = [NSSet setWithObjects:[MTag tagByName:@"Zona Norte" inContext:moContext1], nil];
    NSSet *tagSet = [NSSet setWithObjects:[MTag tagByName:@"GMI_blue-dot" inContext:moContext1], nil];
    //NSSet *tagSet= [NSSet setWithObjects:[MTag tagByName:@"Oporto" inContext:moContext1], [MTag tagByName:@"GMI_blue-dot" inContext:moContext1], nil];

    NSArray *a1,*a2;
    a2=[MockUp _testTags2:tagSet moContext:moContext1];
    a2=[MockUp _testTags2:tagSet moContext:moContext1];
    a1=[MockUp _testTags1:tagSet moContext:moContext1];
    a1=[MockUp _testTags1:tagSet moContext:moContext1];
    
    for(MTag *obj1 in a1) {
        if(![a2 containsObject:obj1]) {
            NSLog(@"Error - %@",obj1.name);
        }
    }
    for(MTag *obj2 in a2) {
        if(![a1 containsObject:obj2]) {
            NSLog(@"Error - %@",obj2.name);
        }
    }
    
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
        for(MTag *tag in [point.rTags valueForKey:@"tag"]) {
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
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", dataPathName, fileName];
            [MockUp _loadPListMapFromPath:filePath inContext:moContext];
        }
    }
    
    // Lanza la actualizacion de los tags de localizacion
    //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:FALSE];
    
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
        [point setLatitude:[poiLat doubleValue] longitude:[poiLng doubleValue]];
        [point updateIcon:[MIcon iconForHref:poiIcon inContext:moContext]];
        [readPois setObject:point forKey:poiIndex];
    }
    
    
    NSMutableDictionary *readTags = [NSMutableDictionary dictionary];
    NSArray *tagList = [mapInfo valueForKey:@"tags"];
    for(NSDictionary *tagInfo in tagList) {
        NSNumber *tagIndex = [tagInfo valueForKey:@"index"];
        NSString *tagName = [tagInfo valueForKey:@"name"];
        MTag *tag = [MTag tagByName:tagName inContext:moContext];
        tag.rootID = tagIndex;
        tag.shortName = tagName;
        [readTags setObject:tag forKey:tagIndex];
        DDLogVerbose(@"");
        DDLogVerbose(@"  TAG name: '%@' / index: %@", tagName, tagIndex);
        
        NSArray *poiIndexList = [tagInfo valueForKey:@"poiIndexes"];
        for(NSString *poiIndexStr in poiIndexList) {
            NSUInteger p1 = [poiIndexStr indexOf:@"-"];
            if(p1==NSNotFound) {
                NSNumber *index = [NSNumber numberWithInt:[poiIndexStr integerValue]];
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
    
    for(NSDictionary *tagInfo in tagList) {
        NSNumber *tagIndex = [tagInfo valueForKey:@"index"];
        MTag *parentTag = [readTags objectForKey:tagIndex];
        NSArray *tagIndexList = [tagInfo valueForKey:@"tagIndexes"];
        for(NSString *tagIndexStr in tagIndexList) {
            NSUInteger p1 = [tagIndexStr indexOf:@"-"];
            if(p1==NSNotFound) {
                NSNumber *index = [NSNumber numberWithInt:[tagIndexStr integerValue]];
                MTag *subtag = [readTags objectForKey:index];
                if(subtag) {
                    [parentTag tagChildTag:subtag];
                }
            } else {
                NSString *startStrIndex = [tagIndexStr subStrFrom:0 to:p1];
                NSString *endStrIndex = [tagIndexStr substringFromIndex:p1+1];
                int sIndex = [startStrIndex intValue];
                int eIndex = [endStrIndex intValue];
                for(int n=sIndex;n<=eIndex;n++) {
                    NSNumber *index = [NSNumber numberWithInt:n];
                    MTag *subtag = [readTags objectForKey:index];
                    if(subtag) {
                        [parentTag tagChildTag:subtag];
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
        NSManagedObjectID __block *pointMOID = point.objectID;
        
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
                
                
                NSManagedObjectContext *moContext = [BaseCoreDataService moContext];
                NSMutableSet *tags = [NSMutableSet set];
                NSMutableString *fullTagName = [NSMutableString stringWithString:@""];
                
                if(placemark.country) {
                    [fullTagName appendFormat:@"#%@",placemark.country];
                    MTag *tag = [MTag tagByName:[fullTagName copy] inContext:moContext];
                    tag.shortName = [NSString stringWithFormat:@"1-%@", placemark.country];
                    [tags addObject:tag];
                }
                
                if(placemark.administrativeArea) {
                    [fullTagName appendFormat:@"#%@",placemark.administrativeArea];
                    MTag *tag = [MTag tagByName:[fullTagName copy] inContext:moContext];
                    tag.shortName = [NSString stringWithFormat:@"2-%@", placemark.administrativeArea];
                    [tags addObject:tag];
                }
                
                if(placemark.subAdministrativeArea) {
                    [fullTagName appendFormat:@"#%@",placemark.subAdministrativeArea];
                    MTag *tag = [MTag tagByName:[fullTagName copy] inContext:moContext];
                    tag.shortName = [NSString stringWithFormat:@"3-%@", placemark.subAdministrativeArea];
                    [tags addObject:tag];
                }
                
                if(placemark.locality) {
                    [fullTagName appendFormat:@"#%@",placemark.locality];
                    MTag *tag = [MTag tagByName:[fullTagName copy] inContext:moContext];
                    tag.shortName = [NSString stringWithFormat:@"4-%@", placemark.locality];
                    [tags addObject:tag];
                }
                
                
                MPoint *point = (MPoint *)[moContext objectWithID:pointMOID];
                [MockUp _toPoint:point addTags:tags];
                //point.locationTag =  [tags allObjects][0];
                [moContext saveChanges];
                
                [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:FALSE];
            }
        }];
        
    } else {
        NSLog(@"Ya estan todos!");
    }
    
    
}

@end


