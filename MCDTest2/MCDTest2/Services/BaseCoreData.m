//
//  BaseCoreData.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "BaseCoreData.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
//---------------------------------------------------------------------------------------------------------------------



//*********************************************************************************************************************
#pragma mark -
#pragma mark BaseCoreData PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface BaseCoreData ()

@property(weak) NSError *lastError;

@property (strong, readonly) NSManagedObjectContext *moContext;
@property (strong, readonly) NSManagedObjectModel *moModel;
@property (strong, readonly) NSPersistentStoreCoordinator * psCoordinator;


@property (strong) NSString *modelName;
@property (weak, readonly) NSURL *applicationDocumentsDirectory;


+ (BaseCoreData *)sharedInstance;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark BaseCoreData implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation BaseCoreData


@synthesize lastError = _lastError;

@synthesize moContext = _moContext;
@synthesize moModel = _moModel;
@synthesize psCoordinator = _psCoordinator;
@synthesize applicationDocumentsDirectory = _applicationDocumentsDirectory;



//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (BaseCoreData *)sharedInstance {
    
    static BaseCoreData *_globalModelInstance = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        NSLog(@"BaseCoreData - Creating sharedInstance");
        _globalModelInstance = [[self alloc] init];
    });
    return _globalModelInstance;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSManagedObjectContext *) moContext {
    return BaseCoreData.sharedInstance.moContext;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSError *) lastError {
    return BaseCoreData.sharedInstance.lastError;
}
//---------------------------------------------------------------------------------------------------------------------
+ (void) setLastError:(NSError *)err {
    BaseCoreData.sharedInstance.lastError=err;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSEntityDescription *) entityByName:(NSString *)name {
    return [[BaseCoreData.sharedInstance.moModel entitiesByName] objectForKey:name];
}

//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) initCDStack:(NSString *)modelName {
    
    NSLog(@"initCDStack for model: '%@'", modelName);
    
    BaseCoreData.sharedInstance.modelName = modelName;
    [self moContext];
    return self.moContext!=nil;
}

//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) saveContext {
    
    NSError *error = nil;
    if(BaseCoreData.sharedInstance.moContext!=nil) {
        if([BaseCoreData.sharedInstance.moContext hasChanges] && ![BaseCoreData.sharedInstance.moContext save:&error]){
            NSLog(@"Error saving NSManagedContext: %@, %@", error, [error userInfo]);
            BaseCoreData.sharedInstance.lastError=error;
            return false;
        }
    }
    return true;
    
}




//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectContext *) moContext {
    
    if(_moContext!=nil) {
        return _moContext;
    }
    
    NSLog(@"Creating moContext");
    
    NSPersistentStoreCoordinator *coor = self.psCoordinator;
    if(coor!=nil) {
        _moContext = [[NSManagedObjectContext alloc] init];
        [_moContext setPersistentStoreCoordinator:coor];
        return _moContext;
    } else {
        return nil;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (NSPersistentStoreCoordinator *) psCoordinator {
    
    if(_psCoordinator!=nil) {
        return _psCoordinator;
    }
    
    NSLog(@"Creating psCoordinator");
    
    NSManagedObjectModel * model = self.moModel;
    if(model!=nil) {
        
        NSString *sqliteFileName = [NSString stringWithFormat:@"%@.sqlite",self.modelName];
        NSURL *storeURL =  [self.applicationDocumentsDirectory URLByAppendingPathComponent:sqliteFileName];
        NSLog(@"storeURL = %@",storeURL);
        
        
        _psCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
        if(_psCoordinator!=nil) {
            _lastError = nil;
            NSError *error = nil;
            if(![_psCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
                NSLog(@"Error creating NSPersistentStoreCoordinator: %@, %@", error, [error userInfo]);
                _psCoordinator = nil;
                _lastError = error;
            }
        }
    }
    
    return _psCoordinator;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectModel *) moModel {
    
    
    if(_moModel!=nil) {
        return _moModel;
    }
    
    NSLog(@"Creating moModel");
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
    _moModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    if(_moModel==nil) {
        NSLog(@"Error creating the NSManagedObjectModel");
    }
    
    return _moModel;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSURL *) applicationDocumentsDirectory {
    
    // Returns the directory the application uses to store the Core Data store file.
    // This code uses a directory named "com.zetLabs.APP-NAME" in the user's Application Support directory.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *bundleAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *appSubfolder = [NSString stringWithFormat:@"com.zetLabs.%@",bundleAppName];
    NSURL *appDocDir = [appSupportURL URLByAppendingPathComponent:appSubfolder];
    
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:[appDocDir path] withIntermediateDirectories:YES attributes:nil error:&error]) {
        _lastError = error;
        NSLog(@"Error getting Application Documents Directory: %@, %@", error, [error userInfo]);
    }
    
    return appDocDir;
}


@end
