//
// NSManagedObjectContext+Utils.m
// iTravelPOI-FRWK
//
// Created by Jose Zarzuela on 29/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "NSManagedObjectContext+Utils.h"
#import "ErrorManagerService.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Service private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark NSManagedObjectContext Category
// ---------------------------------------------------------------------------------------------------------------------

@implementation NSManagedObjectContext(Utils)



// ---------------------------------------------------------------------------------------------------------------------
// Solo salva los cambios de ese contexto "un nivel hacia abajo"
- (BOOL) saveChanges {
    
    NSError *error = nil;
    if([self hasChanges] && ![self save:&error]) {
        [ErrorManagerService manageError:error compID:@"NSManagedObjectContext+SaveChanges" messageWithFormat:@"Error saving NSManagedContext"];
        return NO;
    }
    
    return YES;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectContext *) childContext {
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    childContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    childContext.parentContext = self;
    return childContext;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectContext *) ChildContextASync {

    NSManagedObjectContext *childContextASync = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    childContextASync.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    childContextASync.parentContext = self;
    return childContextASync;
}



@end


