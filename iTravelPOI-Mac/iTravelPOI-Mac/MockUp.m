//
//  MockUp.m
//  iTravelPOI
//
//  Created by Jose Zarzuela on 16/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MockUp.h"
#import "BaseCoreData.h"
#import "Model.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark MockUp implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MockUp

BOOL _init_model_ = TRUE;

//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
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

//---------------------------------------------------------------------------------------------------------------------
+ (NSURL *) applicationDocumentsDirectory {
    
    // Returns the directory the application uses to store the Core Data store file.
    // This code uses a directory named "com.zetLabs.APP-NAME" in the user's Application Support directory.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *bundleAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *appSubfolder = [NSString stringWithFormat:@"com.zetLabs.%@",bundleAppName];
    NSURL *appDocDir = [appSupportURL URLByAppendingPathComponent:appSubfolder];
    
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:[appDocDir path] withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"MockUp - Error getting Application Documents Directory: %@, %@", error, [error userInfo]);
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    return appDocDir;
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) resetModel:(NSString *)modelName {
    
    if(!_init_model_) return;
    
    
    NSString *sqliteFileName = [NSString stringWithFormat:@"%@.sqlite",modelName];
    NSURL *storeURL =  [self.applicationDocumentsDirectory URLByAppendingPathComponent:sqliteFileName];

    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;

    if([storeURL checkResourceIsReachableAndReturnError:&error]) {
        if(![fileManager removeItemAtURL:storeURL  error:&error]) {
            NSLog(@"Error removing data file: %@, %@", error, [error userInfo]);
            [[NSApplication sharedApplication] terminate:nil];
        } else {
            NSLog(@"****** DATA MODEL SQLITE FILE ERASED ******");
        }
    } else {
        NSLog(@"****** DATA MODEL SQLITE FILE DIDN'T EXIST AND COULDN'T BE ERASED ******");
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) populateModel {
    
    if(!_init_model_) return;
    
    NSManagedObjectContext *moContext = [BaseCoreData moContext];
    
    //-------------------------------------------------------
    MGroup *grp1 = [MGroup createGroupWithName:@"cat_1" parentGrp:nil  inContext:moContext];
    MGroup *grp2 = [MGroup createGroupWithName:@"cat_2" parentGrp:grp1 inContext:moContext];
    MGroup *grp3 = [MGroup createGroupWithName:@"cat_3" parentGrp:grp1 inContext:moContext];
    MGroup *grp4 = [MGroup createGroupWithName:@"cat_4" parentGrp:grp2 inContext:moContext];
    MGroup *grp5 = [MGroup createGroupWithName:@"cat_5" parentGrp:grp2 inContext:moContext];
    MGroup *grp6 = [MGroup createGroupWithName:@"cat_6" parentGrp:grp3 inContext:moContext];
    MGroup *grp7 = [MGroup createGroupWithName:@"cat_7" parentGrp:grp3 inContext:moContext];
    
    //-------------------------------------------------------
    MGroup *grpA = [MGroup createGroupWithName:@"cat_A" parentGrp:nil  inContext:moContext];
    MGroup *grpB = [MGroup createGroupWithName:@"cat_B" parentGrp:grpA inContext:moContext];
    MGroup *grpC = [MGroup createGroupWithName:@"cat_C" parentGrp:grpA inContext:moContext];
    MGroup *grpD = [MGroup createGroupWithName:@"cat_D" parentGrp:grpB inContext:moContext];
    MGroup *grpE = [MGroup createGroupWithName:@"cat_E" parentGrp:grpB inContext:moContext];
    MGroup *grpF = [MGroup createGroupWithName:@"cat_F" parentGrp:grpC inContext:moContext];
    MGroup *grpG = [MGroup createGroupWithName:@"cat_G" parentGrp:grpC inContext:moContext];
    
    //-------------------------------------------------------
    MGroup *grpX = [MGroup createGroupWithName:@"cat_X" parentGrp:nil  inContext:moContext];
    
    
    //-------------------------------------------------------
    int NUM_POINTS = 1;
    NSMutableArray *point1 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point1 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_1_%d",n] groups:nil  inContext:moContext]];
    }
    NSMutableArray *point2 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point2 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_2_%d",n] groups:nil  inContext:moContext]];
    }
    NSMutableArray *point3 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point3 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_3_%d",n] groups:nil  inContext:moContext]];
    }
    NSMutableArray *point4 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point4 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_4_%d",n] groups:nil  inContext:moContext]];
    }
    NSMutableArray *point5 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point5 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_5_%d",n] groups:nil  inContext:moContext]];
    }
    NSMutableArray *point6 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point6 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_6_%d",n] groups:nil  inContext:moContext]];
    }
    
    
    //-------------------------------------------------------
    for(MPoint *pnt in point1) {
        [pnt updatePointAssignmentsWithGroups:[NSSet setWithObjects:grp4, nil]];
    }
    for(MPoint *pnt in point2) {
        [pnt updatePointAssignmentsWithGroups:[NSSet setWithObjects:grp6, grpE, nil]];
    }
    for(MPoint *pnt in point3) {
        [pnt updatePointAssignmentsWithGroups:[NSSet setWithObjects:grp3, grpB, nil]];
    }
    for(MPoint *pnt in point4) {
        [pnt updatePointAssignmentsWithGroups:[NSSet setWithObjects:grp3, grpX, nil]];
    }
    for(MPoint *pnt in point5) {
        [pnt updatePointAssignmentsWithGroups:[NSSet setWithObjects:grpA, grpX, nil]];
    }
    for(MPoint *pnt in point6) {
        [pnt updatePointAssignmentsWithGroups:[NSSet setWithObjects:grpG, nil]];
    }
    
    [BaseCoreData saveContext];
    
    NSLog(@"****** DATA MODEL SQLITE FILE PRE-POPULATED ******");
    
}


@end
