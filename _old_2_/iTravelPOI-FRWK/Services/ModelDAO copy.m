//
//  ModelDAO.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "ModelDAO.h"
#import "BaseCoreData.h"


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
+ (void) createInitialData {

    MGroup *gmaps = [MGroup createGroupWithName:@"" parentGrp:nil];
    gmaps.fixed = TRUE;
    gmaps.gID = @"FIXED_GMAPS";
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSDictionary *) searchEntitiesWithFilter:(NSArray *)filteringGroups {
    
    NSArray *groups = [ModelDAO requestGroupsWithFilter:filteringGroups];
    NSArray *collapsedGroups = [ModelDAO collapseGroupHierarchy:groups withFilter:filteringGroups];
    

    // Crea un descriptor de ordenacion
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSArray *sortedArray = [collapsedGroups sortedArrayUsingDescriptors:sortDescriptors];

    
    NSMutableArray *groupAndCounts = [NSMutableArray array];
    for(MGroup *group in sortedArray) {
        [groupAndCounts addObject:[GroupAndCount withGroup:group]];
    }
    
    NSArray *points =[ModelDAO requestFirstLevelPointsWithFilter:filteringGroups];
    
    GroupsAndPoints *result= [GroupsAndPoints withGroupsAndCounts:groupAndCounts points:[NSMutableArray arrayWithArray:points]];
    
    return result;
}




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) requestGroupsWithFilter:(NSArray *)filteringGroups {
    
    
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
    
    // Propiedad de la entidad por la que agruparemos y que retornaremos
    NSPropertyDescription *grpPropDesc = [[[BaseCoreData entityByName:@"MAssignment"] propertiesByName] objectForKey:@"group"];
    
    // Expresion para contar elementos (OJO: Se debe hacer sobre un atributo que no sea un relationship)
    NSExpressionDescription *countExprDesc = [[NSExpressionDescription alloc] init];
    [countExprDesc setExpression:[NSExpression expressionWithFormat:@"etag.@count"]];
    [countExprDesc setExpressionResultType:NSInteger64AttributeType];
    [countExprDesc setName:@"count"];
    
    // Se crea la peticion indicando que sera un Diccionario (group, groupName, count)
    // y se establecen las propiedades adecuadas
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MAssignment"];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToGroupBy:[NSArray arrayWithObjects: grpPropDesc, nil]];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:grpPropDesc, countExprDesc, nil]];
    [request setPredicate:filterQuery];
    
    
    // Ejecuta la peticion
    NSArray *requestResults = [BaseCoreData.moContext executeFetchRequest:request error:&error];
    if (requestResults == nil) {
        BaseCoreData.lastError= error;
        NSLog(@"Error searching MGroups that match filter. Error = %@, %@", error, [error userInfo]);
        return nil;
    }
    
    // Convierte los ObjectID en MGroup actualizando su viewCount con el valor calculado
    NSMutableArray *results=[NSMutableArray arrayWithCapacity:requestResults.count];
    for(id value in requestResults) {
        NSManagedObjectID *moID = [value valueForKeyPath:@"group"];
        __weak MGroup *group=(MGroup *)[BaseCoreData.moContext existingObjectWithID:moID error:&error];
        if (group == nil) {
            BaseCoreData.lastError= error;
            NSLog(@"Error getting existing MGroup with a given ID that matched filter. Error = %@, %@", error, [error userInfo]);
            return nil;
        }
        group.viewCount = ((NSNumber *)[value valueForKeyPath:@"count"]).unsignedIntValue;
        [results addObject:group];
    }
    
    // retorna el resultado
    return results;
}

//---------------------------------------------------------------------------------------------------------------------
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
        BaseCoreData.lastError= error;
        NSLog(@"Error searching first level MPoints that match filter. Error = %@, %@", error, [error userInfo]);
        return nil;
    }
    
    // Retorna los ObjectID en MPoint
    NSMutableArray *results=[NSMutableArray arrayWithCapacity:requestResults.count];
    for(id value in requestResults) {
        NSManagedObjectID *moID = [value valueForKeyPath:@"point"];
        [results addObject:moID];
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
+ (NSArray *) collapseGroupHierarchy:(NSArray *)groupsArray withFilter:(NSArray *)filteringGroups {
    
    
    //-----------------------------------------------------------------------------
    // Primero prepara la lista de grupos a procesar teniendo en cuenta
    // grupos hijos de ultimo nivel del filtro y grupos raiz
    //-----------------------------------------------------------------------------
    
    // Construye un SET con los grupos listados
    NSMutableSet *setGroupsWithRoots = [NSMutableSet setWithArray:groupsArray];
    
    // Le añade los subgrupos de los grupos del ultimo nivel del filtro
    [setGroupsWithRoots addObjectsFromArray:[ModelDAO getChildrenFromLastLevelGroups:filteringGroups]];
    
    // Le añade los roots de los grupos listados excluyendo los de los grupos del filtro
    [setGroupsWithRoots addObjectsFromArray:[ModelDAO getRootsFromGroups:groupsArray withoutFilterRoots:filteringGroups]];
    
    // Quita los grupos contenidos en el filtro
    [setGroupsWithRoots minusSet:[NSSet setWithArray:filteringGroups]];
    
    NSMutableSet *addedGroups = [NSMutableSet setWithSet:setGroupsWithRoots];
    [addedGroups minusSet:[NSSet setWithArray:groupsArray]];
    for(MGroup *group in addedGroups) {
        group.viewCount = 0;
    }
    
    
    //-----------------------------------------------------------------------------
    // Aplana los grupos dejando sólo los de mayor nivel
    //-----------------------------------------------------------------------------
    
#define GROUP_ALREADY_PROCESSED -1
    
    // Busca los grupos padre acumulando en ellos la cuenta de los puntos
    // Para ello los compara entre si
    NSArray *groupsWithRoots = setGroupsWithRoots.allObjects;
    NSMutableArray *collapsedGroups = [NSMutableArray new];
    for(int n=0;n<groupsWithRoots.count;n++) {
        
        BOOL isAncestor = true;
        
        // Se salta grupos ya procesados en una comparacion anterior
        MGroup *grp1 = [groupsWithRoots objectAtIndex:n];
        if(grp1.viewCount==GROUP_ALREADY_PROCESSED) {
            continue;
        }
        
        
        for(int m=n+1;m<groupsWithRoots.count;m++) {
            
            MGroup *grp2 = [groupsWithRoots objectAtIndex:m];
            
            // Chequea la relacion de descendencia de los dos puntos
            if([grp2 isAncestorOf:grp1]) {
                grp2.viewCount+=grp1.viewCount;
                grp1.viewCount=0;
                isAncestor = false;
                break;
            } else {
                // (Ojo: podrian ser "hermanos")
                if([grp1 isAncestorOf:grp2]) {
                    grp1.viewCount+=grp2.viewCount;
                    grp2.viewCount=GROUP_ALREADY_PROCESSED;
                }
            }
        }
        
        // Añade los grupos padre
        if(isAncestor) {
            [collapsedGroups addObject:grp1];
        }
    }
    
    // Se podrían haber quedado nodos hijo del filtro sin puntos asignados
    NSMutableArray *groupsWithoutPoints = [NSMutableArray array];
    for(MGroup *group in collapsedGroups) {
        if(group.viewCount<=0) {
            [groupsWithoutPoints addObject:group];
        }
    }
    [collapsedGroups removeObjectsInArray:groupsWithoutPoints];
    
    // Retorna el resultado
    return collapsedGroups;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) getChildrenFromLastLevelGroups:(NSArray *)groups {
    
    // Asume que no hay "hermanos" entre los nodos del mismo arbol
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
+ (NSArray *) getRootsFromGroups:(NSArray *)groupsArray withoutFilterRoots:(NSArray *)filteringGroups {
    
    NSMutableDictionary *processedTrees = [NSMutableDictionary dictionary];
    
    // Añade los root de los grupos encontrados
    for(MGroup *group in groupsArray) {
        if([processedTrees objectForKey:group.treeUID]==nil) {
            [processedTrees setObject:group.root forKey:group.treeUID];
        }
    }
    
    // Quita los root de los que estarian en el filtro utilizado
    for(MGroup *group in filteringGroups) {
        [processedTrees removeObjectForKey:group.treeUID];
    }
    
    return processedTrees.allValues;
}






@end
