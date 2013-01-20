//
//  ModelDAO.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "ModelDAO.h"
#import "FixedData.h"
#import "ErrorManagerService.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
//---------------------------------------------------------------------------------------------------------------------



//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelDAO PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface ModelDAO ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelDAO implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation ModelDAO





//*********************************************************************************************************************
#pragma mark -
#pragma mark TESTING utility method
//---------------------------------------------------------------------------------------------------------------------





//*********************************************************************************************************************
#pragma mark -
#pragma mark Public CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) createInitialData:(NSManagedObjectContext *)moContext {
    
    if([FixedData initFixedData:moContext]){
        return [BaseCoreData saveMOContext:moContext];
    }
    
    return FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
// Diccionario con NSArray(MDataView) con grupos y puntos
+ (NSDictionary *) searchEntitiesWithFilter:(NSArray *)filteringGroups inContext:(NSManagedObjectContext *)moContext {
    
    NSArray *groupsInfo = [ModelDAO requestGroupsWithFilter:filteringGroups inContext:moContext];
    NSArray *collapsedGroups = [ModelDAO collapseGroupHierarchy:groupsInfo withFilter:filteringGroups inContext:moContext];
    
    // Crea un descriptor de ordenacion
    /*
     NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
     NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
     NSArray *sortedGroupsArray = [collapsedGroups sortedArrayUsingDescriptors:sortDescriptors];
     */
    NSArray *sortedGroupsArray = collapsedGroups;
    
    NSArray *points =[ModelDAO requestFirstLevelPointsWithFilter:filteringGroups];
    
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys: sortedGroupsArray, FOUND_GROUPS_KEY, points, FOUND_POINTS_KEY, nil];
    return result;
}




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CLASS methods
//---------------------------------------------------------------------------------------------------------------------
// Array de NSDictionary (group, count, treePath)
+ (NSArray *) requestGroupsWithFilter:(NSArray *)filteringGroups inContext:(NSManagedObjectContext *)moContext {
    
    
    NSError *error = nil;
    
    // Descarta grupos "padre" para el filtro
    NSArray *lastLevelGroups = [ModelDAO getLastLevelGroupsByTree:filteringGroups];
    
    // Compone la cadena de filtrado
    NSMutableString *filterStr = [NSMutableString string];
    for(int n=0;n<lastLevelGroups.count;n++) {
        MGroup *group = lastLevelGroups[n];
        if(n>0) {
            [filterStr appendString:@" AND "];
        }
        [filterStr appendFormat:@"(ANY point.assignments.group.treePath BEGINSWITH '%@#')",group.treePath];
    }
    
    // Filtro a aplicar a la busqueda
    NSPredicate *filterQuery = nil;
    if(filterStr.length>0) {
        filterQuery = [NSPredicate predicateWithFormat:filterStr];
    }
    
    // Propiedades de la entidad por las que agruparemos y que retornaremos
    NSPropertyDescription *grpPropDesc = [[[BaseCoreData entityByName:@"MAssignment"] propertiesByName] objectForKey:@"group"];
    
    NSExpressionDescription *treePathExprDesc = [[NSExpressionDescription alloc] init];
    [treePathExprDesc setExpression:[NSExpression expressionWithFormat:@"group.treePath"]];
    [treePathExprDesc setExpressionResultType:NSStringAttributeType];
    [treePathExprDesc setName:@"treePath"];
    
    // Expresion para contar elementos (OJO: Se debe hacer sobre un atributo que no sea un relationship)
    NSExpressionDescription *countExprDesc = [[NSExpressionDescription alloc] init];
    [countExprDesc setExpression:[NSExpression expressionWithFormat:@"etag.@count"]];
    [countExprDesc setExpressionResultType:NSInteger64AttributeType];
    [countExprDesc setName:@"count"];
    
    // Se crea la peticion indicando que sera un Diccionario (group, groupName, count)
    // y se establecen las propiedades adecuadas
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MAssignment"];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToGroupBy:[NSArray arrayWithObjects: grpPropDesc, treePathExprDesc, nil]];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:grpPropDesc, treePathExprDesc, countExprDesc, nil]];
    [request setPredicate:filterQuery];
    
    
    // Ejecuta la peticion
    NSArray *requestResults = [BaseCoreData.moContext executeFetchRequest:request error:&error];
    if (requestResults == nil) {
        [ErrorManagerService manageError:error compID:@"ModelDAO" messageWithFormat:@"Error searching MGroups that match filter"];
        return nil;
    }
    
    // retorna el resultado
    return requestResults;
}

//---------------------------------------------------------------------------------------------------------------------
// Array de MDataView
+ (NSArray *) requestFirstLevelPointsWithFilter:(NSArray *)filteringGroups {
    
    
    NSError *error = nil;
    
    // No puede haber puntos no asignados a alguna categoria
    if(filteringGroups.count==0) {
        return [NSArray array];
    }
    
    // Descarta grupos "padre" para el filtro
    NSArray *lastLevelGroups = [ModelDAO getLastLevelGroupsByTree:filteringGroups];
    
    // Compone la cadena de filtrado
    NSMutableString *filterStr = [NSMutableString stringWithString:@"(group.treePath IN {"];
    for(MGroup *group in lastLevelGroups){
        [filterStr appendFormat:@"'%@',",group.treePath];
    }
    [filterStr appendString:@"''})"];
    
    for(MGroup *group in lastLevelGroups){
        [filterStr appendFormat:@" AND (ANY point.assignments.group.treePath BEGINSWITH '%@')",group.treePath];
    }
    
    // Filtro a aplicar a la busqueda
    NSPredicate *filterQuery = nil;
    if(filterStr.length>0) {
        filterQuery = [NSPredicate predicateWithFormat:filterStr];
    }
    
    // Propiedad de la entidad por la que agruparemos y que retornaremos
    NSPropertyDescription *pntPropDesc = [[[BaseCoreData entityByName:@"MAssignment"] propertiesByName] objectForKey:@"point"];
    
    // Se crea la peticion indicando que sera un Diccionario (group, groupName, count)
    // y se establecen las propiedades adecuadas
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MAssignment"];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:pntPropDesc, nil]];
    [request setPredicate:filterQuery];
    
    // Crea un descriptor de ordenacion
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"point.name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    
    // Ejecuta la peticion
    NSArray *requestResults = [BaseCoreData.moContext executeFetchRequest:request error:&error];
    if (requestResults == nil) {
        [ErrorManagerService manageError:error compID:@"ModelDAO" messageWithFormat:@"Error searching first level MPoints that match filter"];
        return nil;
    }
    
    // Retorna los ObjectID en MPoint
    NSMutableArray *results=[NSMutableArray arrayWithCapacity:requestResults.count];
    for(id value in requestResults) {
        
        NSManagedObjectID *moID = [value valueForKeyPath:@"point"];
        MDataView *info = [MDataView dataViewWithID:moID];
        [results addObject:info];
    }
    
    // retorna el resultado
    return results;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) getLastLevelGroupsByTree:(NSArray *)filteringGroups {
    
    NSMutableDictionary *groupsDict = [NSMutableDictionary dictionary];
    for(MGroup *group in filteringGroups) {
        
        MGroup *group2=[groupsDict objectForKey:group.treeUID];
        if(group2==nil || group2.treePath.length<group.treePath.length) {
            [groupsDict setObject:group forKey:group.treeUID];
        }
    }
    
    return [groupsDict allValues];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) collapseGroupHierarchy_method_2:(NSArray *)groupsDictArray withFilter:(NSArray *)filteringGroups {

    
    //-----------------------------------------------------------------------------
    // El resultado estara formado por los subgrupos de los ultimos niveles del
    // filtro y los raiz del resto de arboles que no esten en el filtro
    //-----------------------------------------------------------------------------
    
    // Genera el array de posibles resultados
    NSMutableArray *collapsedDataViews = [NSMutableArray array];
    
    // Acumula el numero de puntos de los subgrupos
    for(NSDictionary *dict in groupsDictArray) {
        
        NSString *treePath1 = [dict valueForKeyPath:@"treePath"];
        uint viewCount = ((NSNumber *)[dict valueForKeyPath:@"count"]).unsignedIntValue;
        
        BOOL found = FALSE;
        for(MDataView *dataView in collapsedDataViews) {
            
            NSString *treePath2 = dataView.data;
            if([treePath1 hasPrefix:treePath2]) {
                dataView.count+=viewCount;
                found=TRUE;
                break;
            }
        }
        
        if(!found) {
            
            NSManagedObjectID *groupID = [dict valueForKeyPath:@"group"];
            NSString *treePath = [dict valueForKeyPath:@"treePath"];
            uint viewCount = ((NSNumber *)[dict valueForKeyPath:@"count"]).unsignedIntValue;
            
            MDataView *dataView = [MDataView dataViewWithID:groupID count:viewCount];
            dataView.data = treePath;
            [collapsedDataViews addObject:dataView];
        }
    }
    
    return collapsedDataViews;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) collapseGroupHierarchy:(NSArray *)groupsDictArray withFilter:(NSArray *)filteringGroups inContext:(NSManagedObjectContext *)moContext {
    
    
    //-----------------------------------------------------------------------------
    // El resultado estara formado por los subgrupos de los ultimos niveles del
    // filtro y los raiz del resto de arboles que no esten en el filtro
    //-----------------------------------------------------------------------------
    
    NSMutableArray *subgroupsAndRoots = [NSMutableArray array];
    
    // Le añade los subgrupos de los grupos del ultimo nivel del filtro
    [subgroupsAndRoots addObjectsFromArray:[ModelDAO getChildrenFromLastLevelGroups:filteringGroups]];
    
    // Le añade los roots de los grupos listados excluyendo los de los grupos del filtro
    [subgroupsAndRoots addObjectsFromArray:[ModelDAO getRootsExcludingFilter:filteringGroups inContext:moContext]];
    
    // Ordena ahora los posibles resultados
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [subgroupsAndRoots sortUsingDescriptors:sortDescriptors];
    
    
    // Genera el array de posibles resultados
    NSMutableArray *collapsedDataViews = [NSMutableArray array];
    for(MGroup *group in subgroupsAndRoots) {
        MDataView *dataView = [MDataView dataViewWithID:group.objectID];
        dataView.data = group.treePath;
        [collapsedDataViews addObject:dataView];
    }
    
    // Acumula el numero de puntos de los subgrupos
    for(NSDictionary *dict in groupsDictArray) {
        
        NSString *treePath1 = [dict valueForKeyPath:@"treePath"];
        uint viewCount = ((NSNumber *)[dict valueForKeyPath:@"count"]).unsignedIntValue;
        
        for(MDataView *dataView in collapsedDataViews) {
            
            NSString *treePath2 = dataView.data;
            if([treePath1 hasPrefix:treePath2]) {
                dataView.count+=viewCount;
            }
        }
    }
    
    // Elimina del resultado los elementos con cuenta cero
    unsigned long groupSize = collapsedDataViews.count-1;
    for(long n=groupSize;n>=0;n--) {
        MDataView *dv = (MDataView *)collapsedDataViews[n];
        if(dv.count==0) {
            [collapsedDataViews removeObjectAtIndex:n];
        }
    }
    
    return collapsedDataViews;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) getChildrenFromLastLevelGroups:(NSArray *)groups {
    
    // Asume que no hay "hermanos" entre los nodos del mismo arbol dentro del filtro
    NSMutableDictionary *processedTrees = [NSMutableDictionary dictionary];
    for(MGroup *group in groups) {
        
        MGroup *grp2 = [processedTrees objectForKey:group.treeUID];
        if(grp2==nil || [grp2 isAncestorOf:group]){
            [processedTrees setObject:group forKey:group.treeUID];
        }
        
    }
    
    // Añade todos los subgrupos de los grupos encontrados
    NSMutableArray *allChildren = [NSMutableArray array];
    for(MGroup *group in processedTrees.allValues) {
        [allChildren addObjectsFromArray:group.subgroups.allObjects];
    }
    
    return allChildren;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) getRootsExcludingFilter:(NSArray *)filteringGroups inContext:(NSManagedObjectContext *)moContext {
    
    NSMutableArray *filteredRoots = [NSMutableArray arrayWithArray:[MGroup rootGroupsInContext:moContext]];
    
    // Quita los root de los que estarian en el filtro utilizado
    for(MGroup *group in filteringGroups) {
        [filteredRoots removeObject:group.root];
    }
    
    return filteredRoots;
}



@end
