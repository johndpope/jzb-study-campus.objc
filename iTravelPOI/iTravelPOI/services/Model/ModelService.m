//
//  ModelService.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelService.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface ModelService () 

@property (nonatomic, readonly) NSManagedObjectModel * moModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator * psCoordinator;


- (NSURL *) _applicationDocumentsDirectory;


- (NSArray *) _getUserMapList:(NSError **)error;
- (NSArray *) _getFlatElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy error:(NSError **)error ;
- (NSArray *) _getCategorizedElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy error:(NSError **)error;

- (NSSet *) _getAllCategorizedPoints:(MEMap *)map forCategories:(NSArray *)categories;
- (NSSet *) _getAllCategoriesForPoints:(NSSet *)points excludedCategories:(NSArray *)excludedCats inMap:(MEMap *)map;
- (NSSet *) _filterSubcategories:(NSSet *)categories;
- (NSSet *) _filterCategorizedPoints:(NSSet *)points forCategories:(NSSet *)categories;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation ModelService

dispatch_queue_t _ModelServiceQueue;

NSManagedObjectContext * _moContext;
NSManagedObjectModel * _moModel;
NSPersistentStoreCoordinator * _psCoordinator;



//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        _ModelServiceQueue = dispatch_queue_create("ModelServiceAsyncQueue", NULL);
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [self doneCDStack];
    dispatch_release(_ModelServiceQueue);
    [super dealloc];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
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



//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
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
- (NSError *) commitChanges {
    
    NSLog(@"ModelService - commitChanges");
    
    NSError *error = nil;
    if(self.moContext!=nil && [self.moContext hasChanges]) {
        if(![self.moContext save:&error]){
            NSLog(@"ModelService - Error saving NSManagedContext: %@, %@", error, [error userInfo]);
        } 
    }
    
    return error;
    
}


//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) getUserMapList:(TBlock_getUserMapListFinished) callbackBlock {
    
    NSLog(@"ModelService - Async - getUserMapList");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_ModelServiceQueue,^(void){
        NSError *error = nil;
        NSArray * maps = [[ModelService sharedInstance] _getUserMapList:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(maps, error);
        });
    });
    
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) getFlatElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy callback:(TBlock_getFlatElemensInMapFinished)callbackBlock {
    
    NSLog(@"ModelService - Async - getFlatElemensInMap");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_ModelServiceQueue,^(void) {
        
        NSError *error = nil;
        NSArray *elements = [[ModelService sharedInstance] _getFlatElemensInMap:map forCategories:categories orderBy:orderBy error:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(elements, error);
        });
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) getCategorizedElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy callback:(TBlock_getCategorizedElemensInMapFinished)callbackBlock {
    
    NSLog(@"ModelService - Async - getCategorizedElemensInMap");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(_ModelServiceQueue,^(void){
        NSError *error = nil;
        NSArray *elements = [[ModelService sharedInstance] _getCategorizedElemensInMap:map forCategories:categories orderBy:orderBy error:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(elements, error);
        });
        
    });
    
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
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



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (NSURL *) _applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _getUserMapList:(NSError **)error {
    
    NSLog(@"ModelService - _getUserMapList");
    
    // Crea la peticion
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[MEMap mapEntity]];
    
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
- (NSArray *) _getAllCategoriesInMap:(MEMap *)map error:(NSError **)error {
    
    NSLog(@"ModelService - _getAllCategoriesInMap");
    
    
    // Establece el predicado de busqueda para las entidades
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(map.GID = %@) AND (_i_wasDeleted = 0)", map.GID];
    
    // Estable el orden del resultado
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc]
                                         initWithKey:@"name" ascending:YES] autorelease];
    
    // Crea la peticion para categorias
    NSFetchRequest *requestCat = [[[NSFetchRequest alloc] init] autorelease];
    [requestCat setEntity:[MECategory categoryEntity]];
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
- (NSArray *) _getFlatElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy error:(NSError **)error {
    
    NSLog(@"ModelService - _getFlatElemensInMap");
    
    
    // Algoritmo de comparacion para ordenar los elementos segun se especifique
    NSComparator comparator = ^NSComparisonResult(id obj1, id obj2) {
        MEBaseEntity *e1 = obj1;
        MEBaseEntity *e2 = obj2;
        switch (orderBy) {
            case SORT_BY_CREATING_DATE:
                return [e1.ts_created compare:e2.ts_created];
                
            case SORT_BY_UPDATING_DATE:
                return [e1.ts_updated compare:e2.ts_updated];
                
            default:
                return [e1.name compare:e2.name];
        }
    };
    
    
    
    // Se retorna desde el mapa si no se han especificado categorias filtro
    if(categories!=nil && [categories count]>0) {
        
        // Se queda solo con los puntos que estan categorizados por el filtro
        NSMutableArray *points = [NSMutableArray array];
        for(MEPoint *point in map.points) {
            
            BOOL all = true;
            for(MECategory *cat in categories) {
                if(![cat recursiveContainsPoint:point]) {
                    all = false;
                    break;
                }
            }
            
            if(all) {
                [points addObject:point];
            }
            
        }
        
        // Los ordena y retorna
        NSArray *sortedPoints = [points sortedArrayUsingComparator:comparator];
        return sortedPoints;
        
    } else {
        
        // Actualiza la cuenta de los puntos de forma recursiva para todas las categorias y las ordena
        for(MECategory *cat in map.categories) {
            cat.t_displayCount = [[cat allRecursivePoints] count];
        }
        NSArray *sortedCategories = [[map.categories allObjects] sortedArrayUsingComparator:comparator];
        
        // Ordena todos los puntos del mapa segun hayan indicado
        NSArray *sortedPoints = [[map.points allObjects] sortedArrayUsingComparator:comparator];
        
        // Retorna la union de categorias y puntos
        NSMutableArray *allElements = [NSMutableArray array];
        [allElements addObjectsFromArray:sortedCategories];
        [allElements addObjectsFromArray:sortedPoints];
        
        return allElements;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _getCategorizedElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy error:(NSError **)error {
    
    NSLog(@"ModelService - _getCategorizedElemensInMap");
    
    
    // Algoritmo de comparacion para ordenar los elementos segun se especifique
    NSComparator comparator = ^NSComparisonResult(id obj1, id obj2) {
        MEBaseEntity *e1 = obj1;
        MEBaseEntity *e2 = obj2;
        switch (orderBy) {
            case SORT_BY_CREATING_DATE:
                return [e1.ts_created compare:e2.ts_created];
                
            case SORT_BY_UPDATING_DATE:
                return [e1.ts_updated compare:e2.ts_updated];
                
            default:
                return [e1.name compare:e2.name];
        }
    };
    
    
    // Consigue el conjunto de puntos para el filtro y las categorias del este
    NSSet *allFilteredPoints = [self _getAllCategorizedPoints:map forCategories:categories];
    NSSet *allCategoriesForPoints = [self _getAllCategoriesForPoints:allFilteredPoints excludedCategories:categories inMap:map];
    
    // Elimina las subcategorias y puntos que no deben aparecer a primer nivel
    NSSet *rootCats = [self _filterSubcategories:allCategoriesForPoints];
    NSSet *rooMEPoints = [self _filterCategorizedPoints:allFilteredPoints forCategories:rootCats];
    
    
    // Ordena los conjuntos de categorias y puntos resultantes segun lo indicado
    NSArray *sortedCats = [[rootCats allObjects] sortedArrayUsingComparator:comparator];
    NSArray *sortedPoints = [[rooMEPoints allObjects] sortedArrayUsingComparator:comparator];
    
    // Retorna la union de categorias y puntos
    NSMutableArray *allElements = [NSMutableArray array];
    [allElements addObjectsFromArray:sortedCats];
    [allElements addObjectsFromArray:sortedPoints];
    
    return allElements;
}

//---------------------------------------------------------------------------------------------------------------------
// Retorna el conjunto de puntos que estan categorizados (jeraquicamente) por el filtro pasado
- (NSSet *) _getAllCategorizedPoints:(MEMap *)map forCategories:(NSArray *)categories {
    
    // Si no hay categorias restringiendo los puntos retorna todos los del mapa
    if([categories count]==0) {
        return map.points;
    }
    else {
        // En otro caso, retorna todos los puntos de las categorias de forma recursiva
        // Pero solo aquellos que esten categorizados por la lista pasada
        NSMutableSet *set = [NSMutableSet set];
        
        [set unionSet:[[categories objectAtIndex:0] allRecursivePoints]];
        for(int n=1;n<[categories count];n++) {
            [set intersectSet:[[categories objectAtIndex:n] allRecursivePoints]];
        }
        
        return set;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
// Retorna el conjunto de categorias aplicadas al conjunto de puntos indicado
// Se filtran aquellas categorias que no estan relacionadas con el filtro
- (NSSet *) _getAllCategoriesForPoints:(NSSet *)points excludedCategories:(NSArray *)excludedCats inMap:(MEMap *)map {
    
    // Conjunto de categorias "padre" del filtro
    NSMutableSet *parentFilter = [NSMutableSet set];
    for(MECategory *cat in excludedCats) {
        [parentFilter unionSet:[cat allParentCategories]];
    }
    
    // Subcategorias del ultimo paso del filtro
    NSSet *lastFilterCategories = ((MECategory *)[excludedCats lastObject]).subcategories;
    
    // Calcula el conjunto resultante para cada punto con las categorias del mapa (jerarquico)
    NSMutableSet *set = [NSMutableSet set];
    for(MEPoint *point in points) {
        
        for(MECategory *cat in map.categories) {
            
            // Si categoriza (jerarquicamente) a ese punto lo podria añadir
            if([cat recursiveContainsPoint:point]) {
                
                // Evita categorias que compartan como "padre" a alguno de los del filtro
                // En puntos que tengan C1 y C2, con ambas con C0 como ancestro, si se va por C1 se filtra C2
                // Las categorias "hijas" del ultimo filtro siempre se añaden
                if([lastFilterCategories containsObject:cat] || ![[cat allParentCategories] intersectsSet:parentFilter]) {
                    [set addObject:cat];
                }
            }
            
        }
    }
    
    // Se eliminan las categorias del filtro
    [set minusSet:[NSSet setWithArray:excludedCats]];
    
    return  set;
}


//---------------------------------------------------------------------------------------------------------------------
// Se eliminan aquellas categorias que sean hijas (jerarquicamente) de alguna otra
// De paso, antes de añadirla al conjunto a retornar, le pone la cuenta de puntos a cero
- (NSSet *) _filterSubcategories:(NSSet *)categories {
    
    NSMutableSet *rootCats = [NSMutableSet set];
    for(MECategory *c1 in categories) {
        
        BOOL isSubCat = false;
        
        for(MECategory *c2 in categories) {
            if([c2 recursiveContainsSubCategory:c1]) {
                isSubCat = true;
                break;
            }
        }
        
        if(!isSubCat) {
            c1.t_displayCount = 0;
            [rootCats addObject:c1];
        }
    }
    
    return  rootCats;
}

//---------------------------------------------------------------------------------------------------------------------
// Elimina aquellos puntos que queden "dentro" de alguna categoria (filtrado a primer nivel)
// Actualiza la cuenta de las categorias que terminen "escondiendo" un punto
- (NSSet *) _filterCategorizedPoints:(NSSet *)points forCategories:(NSSet *)categories {
    
    NSMutableSet *rooMEPoints = [NSMutableSet set];
    
    for(MEPoint *point in points) {
        
        BOOL containedPoint = false;
        
        for(MECategory *cat in categories) {
            
            if([cat recursiveContainsPoint:point]) {
                containedPoint = true;
                cat.t_displayCount++;
            }
            
        }
        
        if(!containedPoint) {
            [rooMEPoints addObject:point];
        }
        
    }
    
    return  rooMEPoints;
}



@end
