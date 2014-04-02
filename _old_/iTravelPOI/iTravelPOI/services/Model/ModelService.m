//
//  ModelService.m
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelService.h"
#import "PersistenceManager.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelService PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface ModelService () 

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
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
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
- (NSError *) storeMap:(MEMap *)map {
    
    NSLog(@"ModelService - storeMap [%@]", map.name);
    
    if(![[PersistenceManager sharedInstance] saveMap:map]) {
        NSError *error = [PersistenceManager sharedInstance].lastError;
        NSLog(@"Error storing map data (%@): %@", map.name, error);
        return error;
    }
    
    // Notifica de cambios en el modelo
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelHasChangedNotification" object:nil userInfo:(NSDictionary *)nil];
    
    // Retorna sin error
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSError *) removeMap:(MEMap *)map {
    
    NSLog(@"ModelService - removeMap [%@]", map.name);
    
    if(![[PersistenceManager sharedInstance] removeMap:map]) {
        NSError *error = [PersistenceManager sharedInstance].lastError;
        NSLog(@"Error storing map data (%@): %@", map.name, error);
        return error;
    }
    
    // Notifica de cambios en el modelo
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModelHasChangedNotification" object:nil userInfo:(NSDictionary *)nil];
    
    // Retorna sin error
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSError *) loadMapData:(MEMap *)map {
    
    NSLog(@"ModelService - loadMapData");
    
    // Solo se la informacion del mapa si hace falta
    if(map.persistentID!=nil && !map.dataRead) {
        if(![[PersistenceManager sharedInstance] loadMapData:map]) {
            return [PersistenceManager sharedInstance].lastError;
        }
    }
    
    // No hubo errores
    return nil;
}


//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) asyncGetUserMapList:(TBlock_getUserMapListFinished) callbackBlock {
    
    NSLog(@"ModelService - Async - getUserMapListOrderBy");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(self.serviceQueue, ^(void){
        NSError *error = nil;
        NSArray *maps = [[ModelService sharedInstance] getUserMapList:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(maps, error);
        });
    });
    
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) asyncGetFlatElemensInMap:(MEMap *)map forCategories:(NSArray *)categories callback:(TBlock_getElementListInMapFinished) callbackBlock {
    
    NSLog(@"ModelService - Async - getFlatElemensInMap");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(self.serviceQueue, ^(void) {
        NSError *error = nil;
        NSArray *elements = [[ModelService sharedInstance] getFlatElemensInMap:map forCategories:categories error:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(elements, error);
        });
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (SRVC_ASYNCHRONOUS) asyncGetCategorizedElemensInMap:(MEMap *)map forCategories:(NSArray *)categories callback:(TBlock_getElementListInMapFinished) callbackBlock {
    
    NSLog(@"ModelService - Async - getCategorizedElemensInMap");
    
    // Si no hay nadie esperando no hacemos nada
    if(callbackBlock==nil) {
        return;
    }
    
    // Se apunta la cola en la que deberá dar la respuesta de callback
    dispatch_queue_t caller_queue = dispatch_get_current_queue();
    
    // Hacemos el trabajo en otro hilo porque podría ser pesado y así evitamos bloqueos del llamante (GUI)
    dispatch_async(self.serviceQueue, ^(void){
        NSError *error = nil;
        NSArray *elements = [[ModelService sharedInstance] getCategorizedElemensInMap:map forCategories:categories error:&error];
        
        // Avisamos al llamante de que ya se ha actualizado el mapa solicitado
        dispatch_async(caller_queue, ^(void){
            callbackBlock(elements, error);
        });
        
    });
    
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getUserMapList:(NSError * __autoreleasing *)error {
    
    NSLog(@"ModelService - _getUserMapList");
    
    // Lee los mapas del usuario
    *error = nil;
    NSArray *mapList = [[PersistenceManager sharedInstance] listMapHeaders];
    if(!mapList) {
        *error = [PersistenceManager sharedInstance].lastError;
    }
    
    return mapList;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getFlatElemensInMap:(MEMap *)map forCategories:(NSArray *)categories error:(NSError * __autoreleasing *)error {
    
    NSLog(@"ModelService - _getFlatElemensInMap");
    
    
    // Hay que leer los datos del mapa si no lo estaban ya
    *error = [self loadMapData:map];
    if(*error) {
        return nil;
    }
    
    
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
        
        // Los retorna
        return points;
        
    } else {
        
        // Actualiza la cuenta de los puntos de forma recursiva para todas las categorias y las ordena
        for(MECategory *cat in map.categories) {
            cat.t_displayCount = [[cat allRecursivePoints] count];
        }
        
        // Retorna la union de categorias y puntos
        NSMutableArray *allElements = [NSMutableArray array];
        [allElements addObjectsFromArray:[map.categories allObjects]];
        [allElements addObjectsFromArray:[map.points allObjects]];
        
        return allElements;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getCategorizedElemensInMap:(MEMap *)map forCategories:(NSArray *)categories error:(NSError * __autoreleasing *)error {
    
    NSLog(@"ModelService - _getCategorizedElemensInMap");
    
    
    // Hay que leer los datos del mapa si no lo estaban ya
    *error = [self loadMapData:map];
    if(*error) {
        return nil;
    }
    
    
    // Consigue el conjunto de puntos para el filtro y las categorias del este
    NSSet *allFilteredPoints = [self __getAllCategorizedPoints:map forCategories:categories];
    NSSet *allCategoriesForPoints = [self __getAllCategoriesForPoints:allFilteredPoints excludedCategories:categories inMap:map];
    
    // Elimina las subcategorias y puntos que no deben aparecer a primer nivel
    NSSet *rootCats = [self __filterSubcategories:allCategoriesForPoints];
    NSSet *rootPoints = [self __filterCategorizedPoints:allFilteredPoints forCategories:rootCats];
    
    // Retorna la union de categorias y puntos
    NSMutableArray *allElements = [NSMutableArray array];
    [allElements addObjectsFromArray:[rootCats allObjects]];
    [allElements addObjectsFromArray:[rootPoints allObjects]];
    
    return allElements;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
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
