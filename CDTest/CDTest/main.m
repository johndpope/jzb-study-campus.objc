//
//  main.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#include "ModelService.h"
#include "TMap.h"

int main (int argc, const char * argv[])
{
#define LOCAL_ETAG_PREFIX @"peepluis"


    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    
    [[ModelService sharedInstance] initCDStack];
    
    NSManagedObjectContext * _moContext = [ModelService sharedInstance].moContext;
    
    /**
    TMap * amap = [TMap newMapInstance];
    amap.name = @"test";
    amap.GID = @"1234";
    [[ModelService sharedInstance] saveContext];
    **/
        
    NSString *aName = @"test";
    NSEntityDescription *mapEntity = [NSEntityDescription entityForName:@"TMap" inManagedObjectContext:_moContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like[cd] %@",aName];
    NSFetchRequest *busqueda = [[NSFetchRequest alloc] init];
    [busqueda setEntity:mapEntity];
    [busqueda setPredicate:predicate];
    NSError *error = nil;
    NSArray *maps = [_moContext executeFetchRequest:busqueda error:&error];    
    for(TMap *quien in maps){
        NSLog(@"**> quien: %d",quien.changed);
        quien.changed = true;
        [[ModelService sharedInstance] saveContext];
        if(quien.changed) {
            NSLog(@"pepe luis garcia");
        }
    }
    
    
    
    [[ModelService sharedInstance] doneCDStack];
    
    [pool drain];
    return 0;
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
