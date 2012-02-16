//
//  main.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelService.h"
#import "TMap.h"
#import "TPoint.h"
#import "PointXmlCat.h"
#import "TCategory.h"
#import "GMapServiceAsync.h"
#import "GMapService.h"

void doIt(int argc, const char * argv[]);

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
int main2 (int argc, const char * argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    doIt(argc, argv);
    
    [pool drain];
    return 0;
}

//---------------------------------------------------------------------------------------------------------------------
void doIt (int argc, const char * argv[]) {
    
}

//---------------------------------------------------------------------------------------------------------------------
void doIt2 (int argc, const char * argv[])
{
    [[ModelService sharedInstance] initCDStack];
    NSManagedObjectContext * _moContext = [ModelService sharedInstance].moContext;
    
    TMap *map = [TMap insertNewTmp];
    map.name=@"hola";
    
    TPoint *point = [TPoint insertNewTmpInMap: map];
    point.name = @"adios";
    
    TCategory *cat = [TCategory insertNewTmpInMap: map];
    cat.name = @"cat";
    
    [cat addPoint: point];
    [cat addPoint: point];
    [cat addPoint: point];
    [cat addPoint: point];
    
    for(TPoint *p in cat.points) {
        NSLog(@"point name = %@",p.name);
    }
    
    
    [[ModelService sharedInstance] doneCDStack];
}

//---------------------------------------------------------------------------------------------------------------------
void doIt3 (int argc, const char * argv[])
{
    
    /**/
    NSString *storeFile = @"/Users/jzarzuela/Documents/CDTest.sqlite";
    NSError *error1;
    if([[NSFileManager defaultManager] fileExistsAtPath:storeFile]) {
        if(![[NSFileManager defaultManager] removeItemAtPath:storeFile error:&error1]) {
            NSLog(@"Error deleting SQLite file: %@, %@", error1, [error1 userInfo]);
            abort();
        }
    }
    /**/
    
    
    [[ModelService sharedInstance] initCDStack];
    NSManagedObjectContext * _moContext = [ModelService sharedInstance].moContext;
    
    /**/
    
    TMap * amap = [TMap insertNew];
    amap.name = @"test";
    
    TPoint *point1 = [TPoint insertNewInMap:amap];
    point1.name = @"p1";
    TPoint *point2 = [TPoint insertNewInMap:amap];
    point2.name = @"p2";
    TPoint *point3 = [TPoint insertNewInMap:amap];
    point3.name = @"p3";
    TPoint *point4 = [TPoint insertNewInMap:amap];
    point4.name = @"p4";
    
    TCategory *cat1 = [TCategory insertNewInMap:amap];
    cat1.name = @"c1";
    TCategory *cat2 = [TCategory insertNewInMap:amap];
    cat2.name = @"c2";
    TCategory *cat3 = [TCategory insertNewInMap:amap];
    cat3.name = @"c3";
    
    [cat2 addPoint:point1];
    [cat2 addPoint:point2];
    
    [point3 addCategory:cat3];
    [point4 addCategory:cat3];
    
    [cat1 addSubcategory: cat2];
    [cat3 addCategory: cat1];
    
    [[ModelService sharedInstance] saveContext];
    /**/
    
    NSString *kml = point1.kmlBlob;
    NSLog(@"kml =\n%@",kml);
    point2.kmlBlob = kml;
    NSLog(@"kml =\n%@",point2.kmlBlob);
    
    
    NSString *aName = @"test";
    NSEntityDescription *mapEntity = [NSEntityDescription entityForName:@"TMap" inManagedObjectContext:_moContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like[cd] %@",aName];
    NSFetchRequest *busqueda = [[NSFetchRequest alloc] init];
    [busqueda setEntity:mapEntity];
    [busqueda setPredicate:predicate];
    NSError *error = nil;
    NSArray *maps = [_moContext executeFetchRequest:busqueda error:&error];    
    for(TMap *quien in maps){
        NSLog(@"**> isLocal: %d",quien.isLocal);
        quien.changed = true;
        [[ModelService sharedInstance] saveContext];
        NSLog(@"xml =\n%@",[quien toXmlString]);
        
    }
    
    [[ModelService sharedInstance] doneCDStack];
}


/**
 NSManagedObjectModel *managedObjectModel() {
 
 static NSManagedObjectModel *model = nil;
 
 if (model != nil) {
 return model;
 }
 
 NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
 path = [path stringByDeletingPathExtension];
 NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"mom"]];
 model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
 
 return model;
 }
 
 
 NSManagedObjectContext *managedObjectContext() {
 
 static NSManagedObjectContext *context = nil;
 if (context != nil) {
 return context;
 }
 
 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];        
 context = [[NSManagedObjectContext alloc] init];
 
 NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel()];
 [context setPersistentStoreCoordinator: coordinator];
 
 NSString *STORE_TYPE = NSSQLiteStoreType;
 
 NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
 path = [path stringByDeletingPathExtension];
 NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
 
 NSError *error;
 NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
 
 if (newStore == nil) {
 NSLog(@"Store Configuration Failure %@",
 ([error localizedDescription] != nil) ?
 [error localizedDescription] : @"Unknown Error");
 }
 [pool drain];
 return context;
 }
 **/
