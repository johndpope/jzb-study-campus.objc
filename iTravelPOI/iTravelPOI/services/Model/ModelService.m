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


- (NSURL *) _applicationDocumentsDirectory;

- (NSSet *) __getAllCategorizedPoints:(MEMap *)map forCategories:(NSArray *)categories;
- (NSSet *) __getAllCategoriesForPoints:(NSSet *)points excludedCategories:(NSArray *)excludedCats inMap:(MEMap *)map;
- (NSSet *) __filterSubcategories:(NSSet *)categories;
- (NSSet *) __filterCategorizedPoints:(NSSet *)points forCategories:(NSSet *)categories;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation ModelService



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
- (void)dealloc {
    dispatch_release(_ModelServiceQueue);
    [_psCoordinator release];
    [_moModel release];
    
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
- (NSManagedObjectContext *) initContext {
    
    NSLog(@"ModelService - initContext");
    
    NSPersistentStoreCoordinator *coor = self.psCoordinator;
    if(coor!=nil) {
        NSManagedObjectContext * ctx = [[NSManagedObjectContext alloc] init];
        [ctx setPersistentStoreCoordinator:coor];
        return ctx;
    } else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSEntityDescription *) getEntityDescriptionForName:(NSString *)entityName {
    
    NSDictionary *entities = [self.moModel entitiesByName];
    
    NSEntityDescription *entity = [entities objectForKey:entityName];
    return entity;
}
//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getAllCategoriesInMap:(MEMap *)map orderBy:(SORTING_METHOD)orderBy {
    
    NSLog(@"ModelService - getAllCategoriesInMap");
    
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
    
    // Las ordena y retorna
    NSArray *sortedCategories = [[[map categories] allObjects] sortedArrayUsingComparator:comparator];
    return sortedCategories;
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) asyncGetUserMapList:(NSManagedObjectContext *)ctx orderBy:(SORTING_METHOD)orderBy sortOrder:(SORTING_ORDER)sortOrder callback:(TBlock_getUserMapListFinished) callbackBlock {
    
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
        NSArray *maps = [[ModelService sharedInstance] getUserMapList:ctx orderBy:orderBy sortOrder:sortOrder error:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(maps, error);
        });
    });
    
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) asyncGetFlatElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy callback:(TBlock_getElementListInMapFinished)callbackBlock {
    
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
        NSArray *elements = [[ModelService sharedInstance] getFlatElemensInMap:map forCategories:categories orderBy:orderBy error:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(elements, error);
        });
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) asyncGetCategorizedElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy callback:(TBlock_getElementListInMapFinished)callbackBlock {
    
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
        NSArray *elements = [[ModelService sharedInstance] getCategorizedElemensInMap:map forCategories:categories orderBy:orderBy error:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(elements, error);
        });
        
    });
    
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getUserMapList:(NSManagedObjectContext *)ctx orderBy:(SORTING_METHOD)orderBy  sortOrder:(SORTING_ORDER)sortOrder error:(NSError **)error {
    
    NSLog(@"ModelService - _getUserMapList");
    
    // Crea la peticion
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[MEMap mapEntity:ctx]];
    
    // Establece el predicado de busqueda
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(i_wasDeleted = 0)"];
    [request setPredicate:predicate];
    
    // Estable el orden del resultado
    NSSortDescriptor *sortDescriptor;
    switch (orderBy) {
        case SORT_BY_CREATING_DATE:
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ts_created" ascending:sortOrder];
            break;
            
        case SORT_BY_UPDATING_DATE:
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ts_updated" ascending:sortOrder];
            break;
            
        default:
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:sortOrder];
            break;
    }
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    
    
    // Realiza la busqueda
    NSError *_err = nil;
    NSArray *mapList = [ctx executeFetchRequest:request error:&_err];
    
    *error = _err;
    return mapList;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getFlatElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy error:(NSError **)error {
    
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
- (NSArray *) getCategorizedElemensInMap:(MEMap *)map forCategories:(NSArray *)categories orderBy:(SORTING_METHOD)orderBy error:(NSError **)error {
    
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
    NSSet *allFilteredPoints = [self __getAllCategorizedPoints:map forCategories:categories];
    NSSet *allCategoriesForPoints = [self __getAllCategoriesForPoints:allFilteredPoints excludedCategories:categories inMap:map];
    
    // Elimina las subcategorias y puntos que no deben aparecer a primer nivel
    NSSet *rootCats = [self __filterSubcategories:allCategoriesForPoints];
    NSSet *rooMEPoints = [self __filterCategorizedPoints:allFilteredPoints forCategories:rootCats];
    
    // Ordena los conjuntos de categorias y puntos resultantes segun lo indicado
    NSArray *sortedCats = [[rootCats allObjects] sortedArrayUsingComparator:comparator];
    NSArray *sortedPoints = [[rooMEPoints allObjects] sortedArrayUsingComparator:comparator];
    
    // Retorna la union de categorias y puntos
    NSMutableArray *allElements = [NSMutableArray array];
    [allElements addObjectsFromArray:sortedCats];
    [allElements addObjectsFromArray:sortedPoints];
    
    return allElements;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
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
// Retorna el conjunto de puntos que estan categorizados (jeraquicamente) por el filtro pasado
- (NSSet *) __getAllCategorizedPoints:(MEMap *)map forCategories:(NSArray *)categories {
    
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
- (NSSet *) __getAllCategoriesForPoints:(NSSet *)points excludedCategories:(NSArray *)excludedCats inMap:(MEMap *)map {
    
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
- (NSSet *) __filterSubcategories:(NSSet *)categories {
    
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
- (NSSet *) __filterCategorizedPoints:(NSSet *)points forCategories:(NSSet *)categories {
    
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
