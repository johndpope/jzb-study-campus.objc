//
// BaseCoreDataService.m
// iTravelPOI-FRWK
//
// Created by Jose Zarzuela on 29/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "BaseCoreDataService.h"
#import "ErrorManagerService.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Service private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark BaseCoreDataService Service private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface BaseCoreDataService ()


@property (strong, readonly) NSManagedObjectContext *moContext;
@property (strong, readonly) NSManagedObjectModel *moModel;
@property (strong, readonly) NSPersistentStoreCoordinator *psCoordinator;


@property (strong, nonatomic) NSString *modelName;
@property (weak, readonly) NSURL *applicationDocumentsDirectory;


+ (BaseCoreDataService *) sharedInstance;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark BaseCoreDataService Service implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation BaseCoreDataService



@synthesize moContext = _moContext;
@synthesize moModel = _moModel;
@synthesize psCoordinator = _psCoordinator;




// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSEntityDescription *) entityByName:(NSString *)name {

    return [[BaseCoreDataService.sharedInstance.moModel entitiesByName] objectForKey:name];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (BOOL) initCDStack:(NSString *)modelName {

    DDLogVerbose(@"BaseCoreDataService - initCDStack for model: '%@'", modelName);

    BaseCoreDataService.sharedInstance.modelName = modelName;
    [self moContext];
    return self.moContext != nil;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSManagedObjectContext *) childContextFor:(NSManagedObjectContext *)moContext {
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    childContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    childContext.parentContext = moContext;
    return childContext;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSManagedObjectContext *) childContextASyncFor:(NSManagedObjectContext *)moContext {
    
    NSManagedObjectContext *childContextASync = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    childContextASync.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    childContextASync.parentContext = moContext;
    return childContextASync;
}

// ---------------------------------------------------------------------------------------------------------------------
// Solo salva los cambios de ese contexto "un nivel hacia abajo"
+ (BOOL) saveChangesInContext:(NSManagedObjectContext *)moContext {
    
    NSError *error = nil;
    if([moContext hasChanges] && ![moContext save:&error]) {
        [ErrorManagerService manageError:error compID:@"BaseCoreDataService" messageWithFormat:@"Error saving NSManagedContext"];
        return NO;
    }
    
    return YES;
}





// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Getter & Setter methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSManagedObjectContext *) moContext {
    return BaseCoreDataService.sharedInstance.moContext;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectContext *) moContext {

    if(_moContext != nil) {
        return _moContext;
    }

    DDLogVerbose(@"BaseCoreDataService - Creating moContext");

    NSPersistentStoreCoordinator *coor = self.psCoordinator;
    if(coor != nil) {
        _moContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_moContext setPersistentStoreCoordinator:coor];
        _moContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        return _moContext;
    } else {
        return nil;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (NSPersistentStoreCoordinator *) psCoordinator {

    if(_psCoordinator != nil) {
        return _psCoordinator;
    }

    DDLogVerbose(@"BaseCoreDataService - Creating psCoordinator");

    NSManagedObjectModel *model = self.moModel;
    if(model != nil) {

        NSString *sqliteFileName = [NSString stringWithFormat:@"%@.sqlite", self.modelName];
        NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:sqliteFileName];
        DDLogVerbose(@"storeURL = %@", storeURL);


        _psCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        if(_psCoordinator != nil) {
            NSError *error = nil;
            if(![_psCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
                _psCoordinator = nil;
                [ErrorManagerService manageError:error compID:@"BaseCoreDataService" messageWithFormat:@"Error creating NSPersistentStoreCoordinator"];
            }
        }
    }

    return _psCoordinator;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectModel *) moModel {


    if(_moModel != nil) {
        return _moModel;
    }

    DDLogVerbose(@"BaseCoreDataService - Creating moModel");

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
    _moModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    if(_moModel == nil) {
        DDLogVerbose(@"BaseCoreDataService - Error creating the NSManagedObjectModel");
    }

    return _moModel;
}



// ---------------------------------------------------------------------------------------------------------------------
- (NSURL *) applicationDocumentsDirectory {

    // Returns the directory the application uses to store the Core Data store file.
    // This code uses a directory named "com.zetLabs.APP-NAME" in the user's Application Support directory.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *bundleAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *appSubfolder = [NSString stringWithFormat:@"com.zetLabs.%@", bundleAppName];
    NSURL *appDocDir = [appSupportURL URLByAppendingPathComponent:appSubfolder];

    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:[appDocDir path] withIntermediateDirectories:YES attributes:nil error:&error]) {
        [ErrorManagerService manageError:error compID:@"BaseCoreDataService" messageWithFormat:@"Error getting Application Documents Directory"];
    }

    return appDocDir;
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS private methods
// ---------------------------------------------------------------------------------------------------------------------
+ (BaseCoreDataService *) sharedInstance {

    static BaseCoreDataService *_globalModelInstance = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
                      DDLogVerbose(@"BaseCoreDataService - Creating sharedInstance");
                      _globalModelInstance = [[self alloc] init];
                  });
    return _globalModelInstance;
}

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------

@end

