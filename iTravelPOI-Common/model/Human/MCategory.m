//
//  MCategory.m
//

#define __MCategory__IMPL__
#define __MCategory__PROTECTED__
#define __MBaseEntity__SUBCLASSES__PROTECTED__

#import "MCategory.h"
#import "MMap.h"
#import "MPoint.h"
#import "RMCViewCount.h"
#import "ErrorManagerService.h"
#import "NSString+JavaStr.h"
#import "ImageManager.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define DEFAULT_CATEGORY_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/flag.png"




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MCategory ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MCategory



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) categoryWithFullName:(NSString *)fullName inContext:(NSManagedObjectContext *)moContext {

    
    MCategory *cat;
    
    // Busca la categoria requerida por si ya existe. En cuyo caso la retorna
    cat = [MCategory _searchCategoryForFullName:fullName inContext:moContext];
    if(cat != nil) {
        return cat;
    }

    // Como no existe, itera el path de categorias "padre" para crear la ultima
    MCategory *parentCat = nil;
    NSMutableString *partialFullName = [NSMutableString string];
    NSArray *allShortCatNames = [fullName componentsSeparatedByString:CATEGORY_NAME_SEPARATOR];
    for(NSString *catShortName in allShortCatNames) {
        
        if(catShortName==nil || catShortName.length==0) continue;
        
        // Crea el nombre completo de la cateogria
        if(partialFullName.length>0) {
            [partialFullName appendString:CATEGORY_NAME_SEPARATOR];
        }
        [partialFullName appendString:catShortName];
        
        // Si no existe ese nivel jerarquico de categoria lo crea
        cat = [MCategory _searchCategoryForFullName:partialFullName inContext:moContext];
        if(cat == nil) {
            cat = [MCategory insertInManagedObjectContext:moContext];
            [cat _resetEntityWithShortName:catShortName fullName:partialFullName parent:parentCat];
        }
        
        // Establece la actual como padre de la siguiente
        parentCat = cat;
    }

    return cat;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allCategoriesInContext:(NSManagedObjectContext *)moContext includeMarkedAsDeleted:(BOOL)withDeleted {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    if(withDeleted == NO) {
        NSPredicate *query = [NSPredicate predicateWithFormat:@"markedAsDeleted=NO"];
        [request setPredicate:query];
    }
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:allCategoriesInContext" messageWithFormat:@"Error fetching all categories in context [deleted=%d]",withDeleted];
    }
    return array;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) categoriesWithPointsInMap:(MMap *)map parentCategory:(MCategory *)parentCat {

    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    NSString *queryString = @"parent=%@ AND SUBQUERY(self.mapViewCounts, $X, $X.viewCount>0 AND $X.map=%@).@count>0";
    NSPredicate *query = [NSPredicate predicateWithFormat:queryString, parentCat, map];
    [request setPredicate:query];
    
    
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [map.managedObjectContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:categoriesWithPointsInMap" messageWithFormat:@"Error fetching categories with points in map '%@' and parent category '%@'", map.name, parentCat.fullName];
    }
    return array;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) rootCategoriesWithPointsInMap:(MMap *)map {

    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    NSString *queryString = @"parent=nil AND SUBQUERY(self.mapViewCounts, $X, $X.map=%@).@count>0";
    NSPredicate *query = [NSPredicate predicateWithFormat:queryString, map];
    [request setPredicate:query];
    
    
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [map.managedObjectContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:rootCategoriesWithPointsInMap" messageWithFormat:@"Error fetching root categories with points in map '%@'", map.name];
    }
    return array;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) frequentRootCategoriesWithPointsNotInMap:(MMap *)map {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    NSString *queryString = @"parent=nil AND SUBQUERY(self.mapViewCounts, $X, $X.map==%@).@count==0 AND SUBQUERY(self.mapViewCounts, $X, $X.map!=%@).@count>1";
    NSPredicate *query = [NSPredicate predicateWithFormat:queryString, map, map];
    [request setPredicate:query];
    
    
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [map.managedObjectContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:frequentRootCategoriesWithPointsNotInMap" messageWithFormat:@"Error fetching frequent root categories with points not in map '%@'", map.name];
    }
    return array;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) otherRootCategoriesWithPointsNotInMap:(MMap *)map {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    NSString *queryString = @"parent=nil AND SUBQUERY(self.mapViewCounts, $X, $X.map==%@).@count==0 AND SUBQUERY(self.mapViewCounts, $X, $X.map!=%@).@count==1";
    NSPredicate *query = [NSPredicate predicateWithFormat:queryString, map, map];
    [request setPredicate:query];
    
    
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [map.managedObjectContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:otherRootCategoriesWithPointsNotInMap" messageWithFormat:@"Error fetching other root categories with points not in map '%@'", map.name];
    }
    return array;
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) purgeEmptyCategoriesInContext:(NSManagedObjectContext *)moContext {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query1 = [NSPredicate predicateWithFormat:@"points.@count==0 AND subCategories.@count==0"];
    [request1 setPredicate:query1];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request1 error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:purgeEmptyCategoriesInContext" messageWithFormat:@"Error purging categories. Getting empty subcategories"];
    }
    
    // Para cada categoria encontrada la borra e itera con su padre por si tambien este deviese ser eliminado
    for(MCategory *cat in array) {
        MCategory *iterCat = cat;
        while(iterCat!=nil && iterCat.points.count==0 && iterCat.subCategories.count==0) {
            iterCat = cat.parent;
            [moContext deleteObject:cat];
        }
    }
    
    
    // Crea la peticion de busqueda
    NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"RMCViewCount"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query2 = [NSPredicate predicateWithFormat:@"viewCount==0"];
    [request2 setPredicate:query2];
    
    // Se ejecuta y retorna el resultado
    localError = nil;
    array = [moContext executeFetchRequest:request2 error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:purgeEmptyCategoriesInContext" messageWithFormat:@"Error purging categories. Getting empty map counts"];
    }
    
    // Para cada relacion de categoria con mapa encontrada la borra
    for(RMCViewCount *rmc in array) {
        [moContext deleteObject:rmc];
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) allInHierarchy {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    NSString *queryString = @"hierarchyID=%@";
    NSPredicate *query = [NSPredicate predicateWithFormat:queryString, self.hierarchyID];
    [request setPredicate:query];
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:allInHierarchy" messageWithFormat:@"Error fetching all descendant categories for '%@' ", self.fullName];
    }
    return array;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) transferTo:(MCategory *)destCategory inMap:(MMap *)map {
    
    // Primero chequea que se esta cambiando de categoria
    if(self.internalIDValue!=destCategory.internalIDValue) {
        
        // Se prohibe mover "hacia abajo", a un descendiente mio
        if([destCategory isDescendatOf:self]) {
            return;
        }
        
        // Realmente lo que se va a hacer es mover sus puntos (para el mapa indicado)
        for(MPoint *point in self.points.allObjects) {
            if(map==nil || point.map.internalIDValue==map.internalIDValue) {
                [point addToCategory:destCategory];
                [point removeFromCategory:self];
            }
        }
        
        // De forma recursiva con sus subcategorias
        for(MCategory *subCat in self.subCategories) {
            NSString *subCatFullName = [NSString stringWithFormat:@"%@%@%@", destCategory.fullName, CATEGORY_NAME_SEPARATOR, subCat.name];
            MCategory *destSubCat = [MCategory categoryWithFullName:subCatFullName inContext:self.managedObjectContext];
            if(destSubCat.isInserted) {
                destSubCat.iconHREF = subCat.iconHREF;
            }
            [subCat transferTo:destSubCat inMap:map];
        }
    }
}


//---------------------------------------------------------------------------------------------------------------------
- (MCategory *) transferToParent:(MCategory *)destParent inMap:(MMap *)map {

    // Primero chequea que se esta cambiando de categoria padre (la primera parte es para nil=nil)
    if(self.parent.internalIDValue!=destParent.internalIDValue) {
        
        
        // Se prohibe mover "hacia abajo", a un descendiente mio
        if([destParent isDescendatOf:self]) {
            return self;
        }
        
        // Busca a su equivalente "movido" en el padre destino
        NSString *destFullName;
        if(destParent==nil) {
            // Se esta convirtiendo esta categoria como raiz
            destFullName = self.name;
        } else {
            destFullName = [NSString stringWithFormat:@"%@%@%@", destParent.fullName,CATEGORY_NAME_SEPARATOR,self.name];
        }
        MCategory *destMe = [MCategory categoryWithFullName:destFullName inContext:self.managedObjectContext];
        if(destMe.isInserted) {
            destMe.iconHREF = self.iconHREF;
        }
        
        // Realmente lo que se va a hacer es mover sus puntos (para el mapa indicado)
        for(MPoint *point in self.points.allObjects) {
            if(map==nil || point.map.internalIDValue==map.internalIDValue) {
                [point addToCategory:destMe];
                [point removeFromCategory:self];
            }
        }
        
        // De forma recursiva con sus subcategorias
        for(MCategory *subCat in self.subCategories) {
            [subCat transferToParent:destMe inMap:map];
        }
        
        // Retorna su "destino"
        return destMe;
        
    } else {
        
        // Como no hay cambio se retorna a si mismo
        return self;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (MODEL_ENTITY_TYPE) entityType {
    return MET_CATEGORY;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted:(BOOL) value {

    // REALMENTE NO SE BORRAN LAS CATEGORIAS.
    // SE TRANSMITE ESA INDICACION A SUS PUNTOS Y LOS DE SUS SUBCATEGORIAS
    for(MPoint *point in self.points) {
        [point markAsDeleted:value];
    }
    
    for(MCategory *subCat in self.subCategories) {
        [subCat markAsDeleted:value];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsModified {
    
    // Traspasa el cambio a sus puntos
    for(MPoint *point in self.points) {
            [point markAsModified];
    }
    
    // A sus subcategorias
    for(MCategory *subCat in self.subCategories) {
        [subCat markAsModified];
    }
    
    // Establece el nuevo valor llamando a su clase base
    [super _baseMarkAsModified];
}

//---------------------------------------------------------------------------------------------------------------------
- (MCategory *) rootParent {

    MCategory *cat = self;
    while(cat.parent!=nil) {
        cat = cat.parent;
    }
    return cat;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isRelatedTo:(MCategory *)cat {

    return self.hierarchyIDValue == cat.hierarchyIDValue;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isDescendatOf:(MCategory *)cat {
    if(self.hierarchyIDValue!=cat.hierarchyIDValue) {
        return FALSE;
    } else {
        NSString *prefixFullname = [NSString stringWithFormat:@"%@%@", cat.fullName, CATEGORY_NAME_SEPARATOR];
        return [self.fullName hasPrefix:prefixFullname];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) deletePointsInMap:(MMap *)map {
    
    // Transmite el borrado a sus puntos y los de sus subcategorias
    for(MPoint *point in self.points) {
        if(point.map.internalIDValue==map.internalIDValue) {
            [point markAsDeleted:true];
        }
    }
    
    for(MCategory *subCat in self.subCategories) {
        [subCat deletePointsInMap:map];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) strViewCount {
    return [NSString stringWithFormat:@"%03d", self.viewCountValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) strViewCountForMap:(MMap *)map {
    RMCViewCount *viewCountForMap = [self viewCountForMap:map];
    return [NSString stringWithFormat:@"%03d", viewCountForMap.viewCountValue];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithShortName:(NSString *)shortName fullName:(NSString *)fullName parent:(MCategory *)parent {
    
    [super _resetEntityWithName:[shortName copy] iconHref:DEFAULT_CATEGORY_ICON_HREF];
    self.fullName = [fullName copy];
    self.viewCountValue = 0;
    if(parent) {
        self.parent = parent;
        self.hierarchyID = parent.hierarchyID;
        self.iconHREF = parent.iconHREF;
    } else {
        self.parent = nil;
        self.hierarchyIDValue = [MCategory _generateInternalID];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateViewCount:(int)increment inMap:(MMap *)map {
    
    // Actualiza su cuenta y la de sus ancestros
    MCategory *cat = self;
    while (cat != nil) {
        cat.viewCountValue += increment;
        assert(cat.viewCountValue>=0);
        if(map) {
            RMCViewCount *rmcViewCount = [cat viewCountForMap:map];
            [rmcViewCount updateViewCount:increment];
        }
        cat = cat.parent;
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) _searchCategoryForFullName:(NSString *)fullName inContext:(NSManagedObjectContext *)moContext {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"fullName=%@", fullName];
    [request setPredicate:query];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:_searchCategoryForIconHREF" messageWithFormat:@"Error fetching categories with FullName='%@'", fullName];
        return nil;
    }
    
    if(array.count == 0) {
        return nil;
    } else {
        if(array.count>1) {
            [ErrorManagerService manageError:nil compID:@"MCategory:_searchCategoryForIconHREF" messageWithFormat:@"Error, more than one result, fetching categories with FullName='%@'", fullName];
        }
        MCategory *category = array[0];
        return category;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (RMCViewCount *) viewCountForMap:(MMap *)map {
    
    // Si no hay mapa, no hay cuenta
    if(map==nil) {
        return nil;
    }
    
    // Busca la relacion existente previa con ese mapa
    for(RMCViewCount *viewCount in self.mapViewCounts) {
        if(viewCount.map.internalIDValue==map.internalIDValue) {
            return viewCount;
        }
    }
    
    // En el caso de que sea la primera vez que se pide, crea dicha relacion
    RMCViewCount *viewCount = [RMCViewCount rmcViewCountForMap:map category:self];
    return viewCount;
}



@end
