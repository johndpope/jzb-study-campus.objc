//
//  ModelService.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelService.h"




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface ModelService () 

@property (readonly, nonatomic, retain) NSEntityDescription * mapEntityDescription;
@property (readonly, nonatomic, retain) NSEntityDescription * categoryEntityDescription;
@property (readonly, nonatomic, retain) NSEntityDescription * pointEntityDescription;

@property (readonly, nonatomic, retain) NSManagedObjectModel * moModel;
@property (readonly, nonatomic, retain) NSPersistentStoreCoordinator * psCoordinator;

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation ModelService

NSManagedObjectContext * _moContext;
NSPersistentStoreCoordinator * _psCoordinator;
NSManagedObjectModel * _moModel;
NSEntityDescription *_mapEntityDescription;
NSEntityDescription *_categoryEntityDescription;
NSEntityDescription *_pointEntityDescription;



//=====================================================================================================================
#pragma mark - Inicizacion de la clase
//=====================================================================================================================



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



//=====================================================================================================================
#pragma mark - API publico de la clase
//=====================================================================================================================



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
    [_mapEntityDescription release];
    [_categoryEntityDescription release];
    [_pointEntityDescription release];
    
    _moContext = nil;
    _moModel = nil;
    _psCoordinator = nil;
    _mapEntityDescription = nil;
    _categoryEntityDescription = nil;
    _pointEntityDescription = nil;
}


//---------------------------------------------------------------------------------------------------------------------
- (NSError *) saveContext {
    
    NSLog(@"ModelService - saveContext");
    
    NSError *error = nil;
    if(self.moContext!=nil && [self.moContext hasChanges]) {
        if(![self.moContext save:&error]){
            NSLog(@"ModelService - Error saving NSManagedContext: %@, %@", error, [error userInfo]);
            return error;
        } 
    }
    
    return nil;
    
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
- (NSArray *)getUserMapList:(NSError **)error {
    
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

//---------------------------------------------------------------------------------------------------------------------
// Ordena la lista de categorias poniendo primero a quien es subcategoria de otro y deja al final a las "padre"
- (NSArray *)sortCategoriesCategorized:(NSSet *)categories {
    
    NSMutableArray *sortedList = [NSMutableArray array];
    NSMutableArray *originalList = [NSMutableArray arrayWithArray:[categories allObjects]];
    
    while([originalList count] > 0) {
        
        TCategory *cat1 = [originalList objectAtIndex:0];
        [originalList removeObjectAtIndex:0];
        
        BOOL addThisCat = true;
        for(TCategory *cat2 in originalList) {
            if([cat1 recursiveContainsSubCategory:cat2]) {
                addThisCat = false;
                break;
            }
        }
        
        if (addThisCat) {
            // La saca y la da por ordenada
            [sortedList addObject:cat1];
        } else {
            // La retorna para procesarla de nuevo contra el resto de categorias
            [originalList addObject:cat1];
        }
        
    }
    
    // Retorna la lista ordenada por categorizacion
    return [[sortedList copy] autorelease];
}


//---------------------------------------------------------------------------------------------------------------------
- (NSArray *)getAllCategoriesInMap:(TMap *)map error:(NSError **)error {
    
    NSLog(@"ModelService - getAllCategoriesInMap");
    
    
    // Establece el predicado de busqueda para las entidades
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(map.GID = %@) AND (_i_wasDeleted = 0)", map.GID];
    
    // Estable el orden del resultado
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc]
                                         initWithKey:@"name" ascending:YES] autorelease];
    
    // Crea la peticion para categorias
    NSFetchRequest *requestCat = [[[NSFetchRequest alloc] init] autorelease];
    [requestCat setEntity:self.categoryEntityDescription];
    [requestCat setPredicate:predicate];
    [requestCat setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    // Realiza la busqueda de las categorias
    NSError *_err = nil;
    NSArray *cats = [self.moContext executeFetchRequest:requestCat error:&_err];
    *error = _err;
    if(_err) {
        return nil;
    }
    
    return cats;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *)getFlatElemensInMap:(TMap *)map forCategory:(TCategory *)cat orderBy:(SORTING_METHOD)orderBy error:(NSError **)error {
    
    NSLog(@"ModelService - getFlatElemensInMap");
    
    
    if(cat!=nil) {
        
        NSComparator comparator = ^NSComparisonResult(id obj1, id obj2) {
            TBaseEntity *e1 = obj1;
            TBaseEntity *e2 = obj2;
            switch (orderBy) {
                case SORT_BY_CREATING_DATE:
                    return [e1.ts_created compare:e2.ts_created];
                    
                case SORT_BY_UPDATING_DATE:
                    return [e1.ts_updated compare:e2.ts_updated];
                    
                default:
                    return [e1.name compare:e2.name];
            }
        };
        
        NSArray *scats = [[cat.subcategories allObjects] sortedArrayUsingComparator:comparator];
        NSArray *points = [[cat.points allObjects] sortedArrayUsingComparator:comparator];

        NSMutableArray *allElements = [NSMutableArray array];
        [allElements addObjectsFromArray:scats];
        [allElements addObjectsFromArray:points];
        
        return [[allElements copy] autorelease];
        
    } else {
        
        NSError *_err = nil;
        
        
        
        // Establece el predicado de busqueda para las entidades
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(map.GID = %@) AND (_i_wasDeleted = 0)", map.GID];
        
        // Estable el orden del resultado
        NSSortDescriptor *sortDescriptor;
        switch (orderBy) {
            case SORT_BY_CREATING_DATE:
                sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"ts_created" ascending:YES] autorelease];
                break;
                
            case SORT_BY_UPDATING_DATE:
                sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"ts_updated" ascending:YES] autorelease];
                break;

            default:
                sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
                break;
        }
        
        // Crea la peticion para categorias
        NSFetchRequest *requestCat = [[[NSFetchRequest alloc] init] autorelease];
        [requestCat setEntity:self.categoryEntityDescription];
        [requestCat setPredicate:predicate];
        [requestCat setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        // Crea la peticion para puntos
        NSFetchRequest *requestPoint = [[[NSFetchRequest alloc] init] autorelease];
        [requestPoint setEntity:self.pointEntityDescription];
        [requestPoint setPredicate:predicate];
        [requestPoint setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        
        // Realiza la busqueda de los puntos
        NSArray *points = [self.moContext executeFetchRequest:requestPoint error:&_err];
        *error = _err;
        if(_err) {
            return nil;
        }
        
        
        // Realiza la busqueda de las categorias
        NSArray *cats = [self.moContext executeFetchRequest:requestCat error:&_err];
        *error = _err;
        if(_err) {
            return nil;
        }
        for(TCategory *cat in cats) {
            cat.t_displayCount = [cat.points count];
        }
        
        NSMutableArray *allElements = [NSMutableArray array];
        [allElements addObjectsFromArray:cats];
        [allElements addObjectsFromArray:points];
        
        return [[allElements copy] autorelease];
    }
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



//=====================================================================================================================
#pragma mark - Metodos privados de la clase
//=====================================================================================================================



//---------------------------------------------------------------------------------------------------------------------
- (NSEntityDescription *) mapEntityDescription {
    if(_mapEntityDescription==nil) {
        _mapEntityDescription = [NSEntityDescription
                                 entityForName:@"TMap" inManagedObjectContext:self.moContext];
    }
    return _mapEntityDescription;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSEntityDescription *) categoryEntityDescription {
    if(_categoryEntityDescription==nil) {
        _categoryEntityDescription = [NSEntityDescription
                                      entityForName:@"TCategory" inManagedObjectContext:self.moContext];
    }
    return _categoryEntityDescription;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSEntityDescription *) pointEntityDescription {
    if(_pointEntityDescription==nil) {
        _pointEntityDescription = [NSEntityDescription
                                   entityForName:@"TPoint" inManagedObjectContext:self.moContext];
    }
    return _pointEntityDescription;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSURL *) _applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
