//
//  MockUp.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 16/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MockUp.h"
#import "Services/BaseCoreData.h"
#import "Model/Model.h"

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
+ (void) resetModel {
    
    if(!_init_model_) return;
    
    NSString *dataFile = @"/Users/jzarzuela/Library/Application Support/com.zetLabs.MCDTest2/MCDTest2.sqlite";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if([fileManager fileExistsAtPath:dataFile]) {
        if(![fileManager removeItemAtPath:dataFile error:&error]) {
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
    
    //-------------------------------------------------------
    MGroup *grp1 = [MGroup createGroupWithName:@"cat_1" parentGrp:nil];
    MGroup *grp2 = [MGroup createGroupWithName:@"cat_2" parentGrp:grp1];
    MGroup *grp3 = [MGroup createGroupWithName:@"cat_3" parentGrp:grp1];
    MGroup *grp4 = [MGroup createGroupWithName:@"cat_4" parentGrp:grp2];
    MGroup *grp5 = [MGroup createGroupWithName:@"cat_5" parentGrp:grp2];
    MGroup *grp6 = [MGroup createGroupWithName:@"cat_6" parentGrp:grp3];
    MGroup *grp7 = [MGroup createGroupWithName:@"cat_7" parentGrp:grp3];
    
    //-------------------------------------------------------
    MGroup *grpA = [MGroup createGroupWithName:@"cat_A" parentGrp:nil];
    MGroup *grpB = [MGroup createGroupWithName:@"cat_B" parentGrp:grpA];
    MGroup *grpC = [MGroup createGroupWithName:@"cat_C" parentGrp:grpA];
    MGroup *grpD = [MGroup createGroupWithName:@"cat_D" parentGrp:grpB];
    MGroup *grpE = [MGroup createGroupWithName:@"cat_E" parentGrp:grpB];
    MGroup *grpF = [MGroup createGroupWithName:@"cat_F" parentGrp:grpC];
    MGroup *grpG = [MGroup createGroupWithName:@"cat_G" parentGrp:grpC];
    
    //-------------------------------------------------------
    MGroup *grpX = [MGroup createGroupWithName:@"cat_X" parentGrp:nil];
    
    
    //-------------------------------------------------------
    int NUM_POINTS = 1;
    NSMutableArray *point1 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point1 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_1_%d",n] groups:nil]];
    }
    NSMutableArray *point2 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point2 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_2_%d",n] groups:nil]];
    }
    NSMutableArray *point3 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point3 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_3_%d",n] groups:nil]];
    }
    NSMutableArray *point4 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point4 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_4_%d",n] groups:nil]];
    }
    NSMutableArray *point5 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point5 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_5_%d",n] groups:nil]];
    }
    NSMutableArray *point6 = [NSMutableArray new];
    for(int n=0;n<NUM_POINTS;n++) {
        [point6 addObject:[MPoint createPointWithName:[NSString stringWithFormat:@"point_6_%d",n] groups:nil]];
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
