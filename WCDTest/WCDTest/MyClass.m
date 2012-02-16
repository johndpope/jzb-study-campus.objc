//
//  MyClass.m
//  WCDTest
//
//  Created by jzarzuela on 15/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyClass.h"
#import "GMapServiceAsync.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation MyClass


//---------------------------------------------------------------------------------------------------------------------
+ (void) updateMap1:(TMap *)map {
    
    [[GMapServiceAsync sharedInstance] updateGMap:map callback:^(TMap *map, NSError *error) {
        NSLog(@"*** DONE!: map %@ - %@",map.name , map.GID);
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) updateMap2:(TMap *)map {
    
    [[GMapServiceAsync sharedInstance] fetchMapData:map callback:^(TMap *map, NSError *error) {
        if(!error) {
            
            for(TPoint *point in map.points) {
                point.iconURL = @"http://maps.gstatic.com/mapfiles/ms2/micons/yellow-dot.png";
                point.syncStatus = ST_Sync_Update_Remote;
            }
            [MyClass updateMap1:map];
        }
    }];    
}


//---------------------------------------------------------------------------------------------------------------------
+ (void) updateMap3:(TMap *)map {
    
    [[GMapServiceAsync sharedInstance] fetchMapData:map callback:^(TMap *map, NSError *error) {
        if(!error) {
            
            for(TPoint *point in map.points) {
                point.iconURL = @"http://maps.gstatic.com/mapfiles/ms2/micons/yellow-dot.png";
                point.syncStatus = ST_Sync_Delete_Remote;
            }
            [MyClass updateMap1:map];
        }
    }];    
}


//---------------------------------------------------------------------------------------------------------------------
+ (void) createMap {
    
    //[[ModelService sharedInstance] initCDStack];
    
    TMap *map = [TMap insertTmpNew];
    map.name=@"@test";
    
    TPoint *point1 = [TPoint insertTmpNewInMap: map];
    point1.name = @"p-1";
    point1.syncStatus = ST_Sync_Create_Remote;

    TPoint *point2 = [TPoint insertTmpNewInMap: map];
    point2.name = @"p-2";
    point2.syncStatus = ST_Sync_Create_Remote;
    
    TCategory *cat = [TCategory insertTmpNewInMap: map];
    cat.name = @"cat";
    cat.syncStatus = ST_Sync_Create_Remote;
    
    [cat addPoint: point1];
    [cat addPoint: point2];
    
    [[GMapServiceAsync sharedInstance] createNewGMap:map callback:^(TMap *newMap, NSError *error) {
        NSLog(@"map %@ - %@",newMap.name , newMap.GID);
        if(!error) {
            [MyClass updateMap1:map];
        }
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) deleteMap:(TMap *) map {
    
    [[GMapServiceAsync sharedInstance] deleteGMap:map callback:^(TMap *map, NSError *error) {
        NSLog(@"*** DONE!: map %@ - %@",map.name , map.GID);
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) listMapsExecutingOnMap:(NSString *)mapName callback:(void (^)(TMap *map)) callback {
    
    [[GMapServiceAsync sharedInstance] fetchUserMapList:^(NSArray *maps, NSError *error) {
        
        if(error==nil && maps) {
            TMap *selectedMap;
            for(TMap *map in maps) {
                NSLog(@"map %@ - %@",map.name , map.GID);
                if([map.name isEqualToString:mapName]) {
                    selectedMap = map;
                }
            }
            
            if(callback && selectedMap) {
                callback(selectedMap);
            }
        }
        
        
    }];
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) doIt:(NSString *)userEMail password:(NSString *)userPassword {
    
    [[GMapServiceAsync sharedInstance] loginWithUser:userEMail password:userPassword];
    
    //[MyClass listMapsExecutingOnMap:@"@test" callback:^(TMap *map) {
    //    [MyClass deleteMap:map];
    //}];
    
    //[MyClass createMap];
    
    [MyClass listMapsExecutingOnMap:@"@test" callback:^(TMap *map) {
        [MyClass updateMap3:map];
    }];
    
}



//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [super dealloc];
}

@end
