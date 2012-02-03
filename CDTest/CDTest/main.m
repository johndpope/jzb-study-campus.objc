//
//  main.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#include "ModelService.h"

int main (int argc, const char * argv[])
{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    
    [[ModelService sharedInstance] initCDStack];
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
