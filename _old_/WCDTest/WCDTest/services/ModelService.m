//
//  ModelService.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelService.h"


#define CD_MODEL_NAME @"WCDTest"
#define CD_SLQLITE_FNAME @"WCDTest.sqlite"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface ModelService () {
@private
    NSManagedObjectContext * _moContext;
    NSPersistentStoreCoordinator * _psCoordinator;
    NSManagedObjectModel * _moModel;
    NSEntityDescription *_mapEntityDescription;
    
}

@property (readonly, nonatomic, retain) NSEntityDescription * mapEntityDescription;
@property (readonly, nonatomic, retain) NSManagedObjectModel * moModel;
@property (readonly, nonatomic, retain) NSPersistentStoreCoordinator * psCoordinator;

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation ModelService



//---------------------------------------------------------------------------------------------------------------------
+ (ModelService *)sharedInstance {
    
	static ModelService *_globalModelInstance = nil;
	static dispatch_once_t _predicate;
	dispatch_once(&_predicate, ^{
        NSLog(@"ModelService - Creating sharedInstance");
        _globalModelInstance = [[self alloc] init];
    });
	return _globalModelInstance;
    
}


//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [self doneCDStack];
    [super dealloc];
}



//---------------------------------------------------------------------------------------------------------------------
- (void) initCDStack {
    
    NSLog(@"ModelService - initCDStack");
    
    [self moContext];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) doneCDStack {
    
    NSLog(@"ModelService - doneCDStack");
    
    [_moContext release];
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
            NSLog(@"ModelService - Error saving NSManagedContext: %@, %@", error, [error userInfo]);
        }
    }
    
}



//---------------------------------------------------------------------------------------------------------------------
- (NSArray *)getUserMapList:(NSError * __autoreleasing *)error {
    
    NSLog(@"ModelService - getUserMapList");

    // Crea la peticion
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:self.mapEntityDescription];
    
    // Establece el predicado de busqueda
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(_i_wasDeleted = 0)"];
    [request setPredicate:predicate];
    
    // Estable el orden del resultado
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];

    // Realiza la busqueda
    NSError *_err = nil;
    NSArray *mapList = [self.moContext executeFetchRequest:request error:&_err];
    
    *error = _err;
    return mapList;
}


/***
 NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
 [request setEntity:entityDescription];
 
 // Set example predicate and sort orderings...
 NSNumber *minimumSalary = ...;
 NSPredicate *predicate = [NSPredicate predicateWithFormat:
 @"(lastName LIKE[c] 'Worsley') AND (salary > %@)", minimumSalary];
 [request setPredicate:predicate];
 
 NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
 initWithKey:@"firstName" ascending:YES];
 [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
 [sortDescriptor release];
 
 NSError *error = nil;
 NSArray *array = [moc executeFetchRequest:request error:&error];

 ***/

//---------------------------------------------------------------------------------------------------------------------
- (NSEntityDescription *) mapEntityDescription {
    if(_mapEntityDescription==nil) {
        _mapEntityDescription = [NSEntityDescription
                                 entityForName:@"TMap" inManagedObjectContext:self.moContext];
    }
    return _mapEntityDescription;
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
    
    NSLog(@"ModelService - Creating moContext");
    
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
    
    NSLog(@"ModelService - Creating psCoordinator");
    
    NSManagedObjectModel * model = self.moModel;
    if(model!=nil) {
        
        NSURL *storeURL =  [[self _applicationDocumentsDirectory ] URLByAppendingPathComponent:CD_SLQLITE_FNAME];
        NSLog(@"ModelService - storeURL = %@",storeURL);
        
        
        _psCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
        if(_psCoordinator!=nil) {
            NSError *error = nil;
            if(![_psCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
                NSLog(@"ModelService - Error creating NSPersistentStoreCoordinator: %@, %@", error, [error userInfo]);
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
    
    NSLog(@"ModelService - Creating moModel");
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:CD_MODEL_NAME withExtension:@"momd"];
    _moModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    if(_moModel==nil) {
        NSLog(@"ModelService - Error creating the NSManagedObjectModel");
    }
    
    return _moModel;
}

@end
