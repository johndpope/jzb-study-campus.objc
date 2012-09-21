//
//  ModelService.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelService.h"


#define CD_MODEL_NAME @"CDTest"
#define CD_SLQLITE_FNAME @"CDTest.sqlite"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface ModelService () {
@private
    NSManagedObjectContext * _moContext;
    NSManagedObjectContext * _moTmpContext;
    NSPersistentStoreCoordinator * _psCoordinator;
    NSManagedObjectModel * _moModel;
}
    @property (readonly, nonatomic, retain) NSManagedObjectModel * moModel;
    @property (readonly, nonatomic, retain) NSPersistentStoreCoordinator * psCoordinator;
@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation ModelService


//---------------------------------------------------------------------------------------------------------------------
+ (ModelService *)sharedInstance {
	static ModelService *_globalInstance;
	static dispatch_once_t _predicate;
	dispatch_once(&_predicate, ^{
        NSLog(@"Creating sharedInstance");
        _globalInstance = [[self alloc] init];
    });
	return _globalInstance;
}


//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [self doneCDStack];
    [super dealloc];
}



//---------------------------------------------------------------------------------------------------------------------
- (void) initCDStack {

    NSLog(@"initCDStack");

    [self moContext];
    [self moTmpContext];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) doneCDStack {
    
    NSLog(@"doneCDStack");

    [_moContext release];
    [_moTmpContext release];
    [_moModel release];
    [_psCoordinator release];
    _moContext = nil;
    _moModel = nil;
    _psCoordinator = nil;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) saveContext {
    
    NSError *error = nil;
    if(self.moContext!=nil) {
        if([self.moContext hasChanges] && ![self.moContext save:&error]){
            NSLog(@"Error saving NSManagedContext: %@, %@", error, [error userInfo]);
        }
    }
    
}


//---------------------------------------------------------------------------------------------------------------------
- (NSURL *) _applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
}


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
- (NSManagedObjectContext *) moTmpContext {
    
    if(_moTmpContext!=nil) {
        return _moTmpContext;
    }
    
    NSLog(@"Creating moTmpContext");
    
    NSPersistentStoreCoordinator *coor = self.psCoordinator;
    if(coor!=nil) {
        _moTmpContext = [[NSManagedObjectContext alloc] init];
        [_moTmpContext setPersistentStoreCoordinator:coor];
        return _moTmpContext;
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

        NSURL *storeURL =  [[self _applicationDocumentsDirectory ] URLByAppendingPathComponent:CD_SLQLITE_FNAME];
        NSLog(@"storeURL = %@",storeURL);
            
        
        _psCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
        if(_psCoordinator!=nil) {
            NSError *error = nil;
            if(![_psCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
                NSLog(@"Error creating NSPersistentStoreCoordinator: %@, %@", error, [error userInfo]);
                [_psCoordinator release];
                _psCoordinator = nil;
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

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:CD_MODEL_NAME withExtension:@"momd"];
    _moModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    if(_moModel==nil) {
        NSLog(@"Error creating the NSManagedObjectModel");
    }
    
    return _moModel;
}

@end
