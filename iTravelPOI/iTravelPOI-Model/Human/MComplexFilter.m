//
//  MComplexFilter.m
//

#define __MComplexFilter__IMPL__
#define __MComplexFilter__PROTECTED__

#import "MComplexFilter.h"
#import "ErrorManagerService.h"
#import "BenchMark.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MComplexFilter ()

// Redefine las propiedades como de escritura
@property (nonatomic, strong)           NSManagedObjectContext  *moContext;

@property (nonatomic, strong)           NSArray                 *pointList;
@property (nonatomic, strong)           NSSet                   *tagList;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MComplexFilter


// Cambios en estas propiedades afectan a los valores almacenados en otras
@synthesize filterMap = _filterMap;
@synthesize filterTags = _filterTags;
@synthesize pointOrder = _pointOrder;

// Estas propiedades tienen un comportamiento perezoso (no se calculan hasta que no se leen)
@synthesize pointList = _wpointList;
@synthesize tagList = _wtagList;




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MComplexFilter *) filterWithContext:(NSManagedObjectContext *)moContext {

    MComplexFilter *me = [[MComplexFilter alloc] init];
    me.moContext = moContext;
    me.pointOrder = @[MBaseOrderByNameAsc];
    return me;
}





//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setFilterMap:(MMap *)map {
    
    // Un cambio en el filtro implica invalidar los elmentos que tenia cargados
    if((_filterMap || map) && ![_filterMap.objectID isEqual:map.objectID]) {
        [self reset];
        _filterMap = map;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setFilterTags:(NSSet *)tags {
    
    // Un cambio en el filtro implica invalidar los elmentos que tenia cargados
    if((_filterTags || tags) && ![_filterTags isEqualToSet:tags]) {
        [self reset];
        _filterTags = tags;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setPointOrder:(NSArray *)order {
    
    // Un cambio en el filtro implica reordenar los elmentos que tenia cargados
    if((_pointOrder || order) && ![_pointOrder isEqualToArray:order]) {

        _pointOrder = order;
        
        // si ya hay elementos cargados hace la ordenacion en memoria
        if(_wpointList.count>0) {
            _wpointList = [self _reSortPoints:[NSMutableArray arrayWithArray:_wpointList]];
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) pointList {
    
    if(!_wpointList) {
        [self _retrievePointsFromStorage];
    }
    return _wpointList;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) tagList {
    
    if(!_wtagList) {
        [self _retrieveTagsFromStorage];
    }
    return _wtagList;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) reset {
    _wpointList = nil;
    _wtagList = nil;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _retrievePointsFromStorage {
    
    
    BenchMark *benchMark = [BenchMark benchMarkLogging:@"MComplexFilter:_retrievePointsFromStorage"];
    
    
    // Ejecuta dependiendo de las condiciones de filtrado
    if(!self.filterMap && self.filterTags.count==0) {
        
        // No hay filtro alguno. Se recuperan todos
        _wpointList = [MPoint allInContext:self.moContext sortOrder:self.pointOrder includeMarkedAsDeleted:FALSE];
        
    } else if(self.filterMap && self.filterTags.count==0) {
        
        // Solo se filtra por mapa
        _wpointList = [MPoint allWithMap:self.filterMap sortOrder:self.pointOrder];
        
    } else {
        
        // Ordena por TAGGING (teniendo en cuenta el mapa)
        [self _retrievePointsWithTagging];
    }
    
    [benchMark logTotalTime:@"All filtered points properly fectched (count=%ld)",_wpointList.count];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _retrieveTagsFromStorage {

    BenchMark *benchMark = [BenchMark benchMarkLogging:@"MComplexFilter:_retrieveTagsFromStorage"];

    if(!self.filterMap && self.filterTags.count==0) {

        // Si no hay filtro es mas rapido sacar los tags sin iterar los puntos
        NSArray *allTags = [MTag allInContext:self.moContext sortOrder:@[MBaseOrderNone] includeMarkedAsDeleted:FALSE];
        _wtagList = [NSSet setWithArray:allTags];
        
    } else {
        
        // Saca los tags de los puntos
        _wtagList = [MPoint allTagsFromPoints:self.pointList];
    }
    
    [benchMark logTotalTime:@"All filtered tags properly fectched (count=%ld)",_wtagList.count];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _retrievePointsWithTagging {
    
    BenchMark *benchMark = [BenchMark benchMarkLogging:@"MComplexFilter:_retrievePointsWithTags"];
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RPointTag"];
    
    // Crea los atributos de agrupacion y de cuenta
    NSExpressionDescription* expDesc = [[NSExpressionDescription alloc] init];
    [expDesc setName: @"tagCount"];
    [expDesc setExpressionResultType: NSInteger32AttributeType];
    [expDesc setExpression: [NSExpression expressionWithFormat:@"isDirect.@count"]];
    
    [request setPropertiesToGroupBy:[NSArray arrayWithObject:@"point"]];
    
    // Indica que se recojan ambos atributos como un diccionario
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"point", expDesc, nil]];
    [request setResultType:NSDictionaryResultType];
    
    // Se asigna una condicion de filtro dependiendo de si hay un filtro sobre el mapa
    if(self.filterMap) {
        NSString *queryStr = @"point.map=%@ AND tag IN %@";
        NSPredicate *query = [NSPredicate predicateWithFormat:queryStr, self.filterMap, self.filterTags];
        [request setPredicate:query];
    } else {
        NSString *queryStr = @"tag IN %@";
        NSPredicate *query = [NSPredicate predicateWithFormat:queryStr, self.filterTags];
        [request setPredicate:query];
    }
    
    // Se asigna el criterio de ordenacion
    [request setSortDescriptors:[MBase sortDescriptorsByOrder:self.pointOrder fieldName:@"point."]];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [self.moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MComplexFilter:_retrieveTaggedPoints - Error fetching tagged points in context [tags=%@]",self.filterTags];
    }
    
    
    [benchMark logTotalTime:@"All filtered points by TAGGING, without removing invalid counts, has been fetched (count=%ld)",array.count];
    
    
    // @TODO: O la query retorna los puntos ordenados, o hay que hacerlo aqui.
    
    
    // Del array debe filtrar aquellos cuya cuenta sea la del filtro
    NSMutableArray *array2 = [NSMutableArray array];
    NSUInteger COUNT = self.filterTags.count;
    for(NSDictionary *dict in array) {
        NSNumber *count2=[dict objectForKey:@"tagCount"];
        if(count2.intValue>=COUNT) {
            NSManagedObjectID *objID = [dict objectForKey:@"point"];
            MPoint *obj = (MPoint *)[self.moContext objectWithID:objID];
            [array2 addObject:obj];
        }
    }
    
    
    [benchMark logTotalTime:@"All filtered points by TAGGING properly fectched (count=%ld)",array2.count];
    
    _wpointList = array2;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSMutableArray *) _reSortPoints:(NSMutableArray *)pointsToSort {
    
    BenchMark *benchMark = [BenchMark benchMarkLogging:@"MComplexFilter:_reSortPoints"];
    
    // Crea el criterio de ordenacion
    NSArray *sortDescriptors = [MBase sortDescriptorsByOrder:self.pointOrder];
    
    // Filtra con los criterios indicados
    [pointsToSort sortUsingDescriptors:sortDescriptors];
    
    [benchMark logTotalTime:@"All points have been re sorted in memory (count=%ld)",pointsToSort.count];
    
    return  pointsToSort;
}



@end
