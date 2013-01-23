//
// BaseCoreData.m
// iTravelPOI-FRWK
//
// Created by Jose Zarzuela on 29/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "BaseCoreData.h"
#import "ErrorManagerService.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Service private enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark BaseCoreData Service private interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface BaseCoreData ()


@property (strong, readonly) NSManagedObjectContext *moContext;
@property (strong, readonly) NSManagedObjectModel *moModel;
@property (strong, readonly) NSPersistentStoreCoordinator *psCoordinator;


@property (strong) NSString *modelName;
@property (weak, readonly) NSURL *applicationDocumentsDirectory;


+ (BaseCoreData *) sharedInstance;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark BaseCoreData Service implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation BaseCoreData


@synthesize moContext = _moContext;
@synthesize moModel = _moModel;
@synthesize psCoordinator = _psCoordinator;
@synthesize applicationDocumentsDirectory = _applicationDocumentsDirectory;



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSEntityDescription *) entityByName:(NSString *)name {

    return [[BaseCoreData.sharedInstance.moModel entitiesByName] objectForKey:name];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (BOOL) initCDStack:(NSString *)modelName {

    NSLog(@"BaseCoreData - initCDStack for model: '%@'", modelName);

    BaseCoreData.sharedInstance.modelName = modelName;
    [self moContext];
    return self.moContext != nil;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (BOOL) saveContext {

    if(BaseCoreData.sharedInstance.moContext != nil) {
        return [BaseCoreData saveMOContext:BaseCoreData.sharedInstance.moContext];
    }
    return true;

}

// ---------------------------------------------------------------------------------------------------------------------
+ (BOOL) saveMOContext:(NSManagedObjectContext *)moContext {

    NSError *error = nil;
    if([moContext hasChanges] && ![moContext save:&error]) {
        [ErrorManagerService manageError:error compID:@"BaseCoreData" messageWithFormat:@"Error saving NSManagedContext"];
        return false;
    }
    return true;

}

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Getter & Setter methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSManagedObjectContext *) moContext {
    return BaseCoreData.sharedInstance.moContext;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectContext *) moContext {

    if(_moContext != nil) {
        return _moContext;
    }

    NSLog(@"BaseCoreData - Creating moContext");

    NSPersistentStoreCoordinator *coor = self.psCoordinator;
    if(coor != nil) {
        _moContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_moContext setPersistentStoreCoordinator:coor];
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

    NSLog(@"BaseCoreData - Creating psCoordinator");

    NSManagedObjectModel *model = self.moModel;
    if(model != nil) {

        NSString *sqliteFileName = [NSString stringWithFormat:@"%@.sqlite", self.modelName];
        NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:sqliteFileName];
        NSLog(@"storeURL = %@", storeURL);


        _psCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        if(_psCoordinator != nil) {
            NSError *error = nil;
            if(![_psCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
                _psCoordinator = nil;
                [ErrorManagerService manageError:error compID:@"BaseCoreData" messageWithFormat:@"Error creating NSPersistentStoreCoordinator"];
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

    NSLog(@"BaseCoreData - Creating moModel");

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
    _moModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    if(_moModel == nil) {
        NSLog(@"BaseCoreData - Error creating the NSManagedObjectModel");
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
        [ErrorManagerService manageError:error compID:@"BaseCoreData" messageWithFormat:@"Error getting Application Documents Directory"];
    }

    return appDocDir;
}

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS private methods
// ---------------------------------------------------------------------------------------------------------------------
+ (BaseCoreData *) sharedInstance {

    static BaseCoreData *_globalModelInstance = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
                      NSLog (@"BaseCoreData - Creating sharedInstance");
                      _globalModelInstance = [[self alloc] init];
                  });
    return _globalModelInstance;
}

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------

@end

