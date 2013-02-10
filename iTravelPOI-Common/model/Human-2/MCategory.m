#import "MCategory.h"
#import "MMap.h"
#import "MPoint.h"
#import "GMTPoint.h"
#import "NSString+JavaStr.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface MCategory ()

+ (MCategory *) _emptyCategoryWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext;
+ (MCategory *) _searchCategoryForIconHREF:(NSString *)iconHREF inContext:(NSManagedObjectContext *)moContext error:(NSError **)err;

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation MCategory


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) _emptyCategoryWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {

    MCategory *Category = [MCategory insertInManagedObjectContext:moContext];
    [Category resetEntityWithName:name];
    return Category;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) _searchCategoryForIconHREF:(NSString *)iconHREF inContext:(NSManagedObjectContext *)moContext error:(NSError **)err {

    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];

    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"markedAsDeleted=NO AND iconHREF=%@", iconHREF];
    [request setPredicate:query];

    // Se ejecuta y retorna el resultado
    NSArray *array = [moContext executeFetchRequest:request error:err];

    if(array == nil || array.count == 0) {
        // el llamante tendra que hacer algo al respecto
        return nil;
    } else {
        MCategory *category = array[0];
        return category;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _categoryNameFromIconHREF:(NSString *)iconHREF {
    return @"vacio";
}

// ---------------------------------------------------------------------------------------------------------------------
+ (void) parseIconHREF:(NSString *)iconHREF baseURL:(NSString **)baseURL catPath:(NSString **)catPath {

    NSUInteger p1, p1_1;
    NSUInteger p2, p2_1;

    if(baseURL == nil && catPath == nil) return;

    p1 = [iconHREF indexOf:URL_PARAM_PCAT];
    if(p1 == NSNotFound) {
        p1 = iconHREF.length - URL_PARAM_PCAT.length;
        p2 = iconHREF.length;
        p1_1 = iconHREF.length;
        p2_1 = iconHREF.length;
    } else {
        p2 = [iconHREF indexOf:@"&" startIndex:p1];
        if(p2 == NSNotFound) {
            p2 = iconHREF.length;
            p1_1 = p1 - 1;
            p2_1 = p2;
        } else {
            p1_1 = p1;
            p2_1 = p2 + 1;
        }
    }


    if(baseURL != nil) {
        NSString *strBefore = [iconHREF subStrFrom:0 to:p1_1];
        NSString *strAfter = [iconHREF subStrFrom:p2_1];
        if([strBefore indexOf:@"?"] == NSNotFound) {
            *baseURL = [NSString stringWithFormat:@"%@%@?%@", strBefore, strAfter, URL_PARAM_PCAT];
        } else {
            *baseURL = [NSString stringWithFormat:@"%@%@&%@", strBefore, strAfter, URL_PARAM_PCAT];
        }
    }

    if(catPath != nil) {
        NSString *pcatValue = [iconHREF subStrFrom:p1 + URL_PARAM_PCAT.length to:p2];
        if(pcatValue == nil || pcatValue.length == 0) {
            pcatValue = [MCategory _categoryNameFromIconHREF:iconHREF];
        }
        if([pcatValue hasSuffix:CATPATH_SEP]) {
            *catPath = pcatValue;
        } else {
            *catPath = [NSString stringWithFormat:@"%@%@", pcatValue, CATPATH_SEP];
        }
    }
}

// ---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) categoryForIconHREF:(NSString *)iconHREF inContext:(NSManagedObjectContext *)moContext {

    NSError *localError = nil;


    MCategory *cat;

    // Parsea el iconHREF especificado
    NSString *baseURL = nil;
    NSString *catPath = nil;
    [MCategory parseIconHREF:iconHREF baseURL:&baseURL catPath:&catPath];

    // Busca a ver la categoria requerida ya existe. En cuyo caso la retorna
    NSString *normalizedHREF = [NSString stringWithFormat:@"%@%@", baseURL, catPath];
    cat = [MCategory _searchCategoryForIconHREF:normalizedHREF inContext:moContext error:&localError];
    if(cat != nil) {
        return cat;
    }



    // Itera el path de categorias "padre" para crear la ultima
    MCategory *parentCat = nil;
    NSMutableString *partialHREF = [NSMutableString stringWithString:baseURL];
    NSArray *catNames = [catPath componentsSeparatedByString:CATPATH_SEP];
    for(NSString *catName in catNames) {

        if(catName == nil || catName.length == 0) continue;

        [partialHREF appendString:catName];
        [partialHREF appendString:CATPATH_SEP];

        cat = [MCategory _searchCategoryForIconHREF:partialHREF inContext:moContext error:&localError];
        if(cat == nil) {
            cat = [MCategory _emptyCategoryWithName:catName inContext:moContext];
            cat.parent = parentCat;
            cat.iconHREF = [partialHREF copy];
        }
        parentCat = cat;
    }

    return cat;

}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) categoriesFromMap:(MMap *)map parentCategory:(MCategory *)parentCat error:(NSError **)err {

    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;

    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    NSString *queryString = @"parent=%@ AND SUBQUERY(self.mapViewCounts, $X, $X.viewCount>0 AND $X.map=%@).@count>0";
    NSPredicate *query = [NSPredicate predicateWithFormat:queryString, parentCat, map];
    [request setPredicate:query];

    
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    // Se ejecuta y retorna el resultado
    NSArray *array = [map.managedObjectContext executeFetchRequest:request error:err];
    return array;
}


// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
// ¿Que atributos tiene realmente esta entidad???? y como se establecen??? ---> Marcado para borrar???
// Sobre todo porque NO SE CREA, SE DERIVA DE LOS PUNTOS.
// CUANDO SE EDITA, REALMENTE SE ESTAN EDITANDO SUS PUNTOS!!!!!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) resetEntityWithName:(NSString *)name {

    [super resetEntityWithName:name];
    self.iconHREF = GM_DEFAULT_POINT_ICON_HREF;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) deletePointsWithMap:(MMap *)map {
    
    // Transmite el borrado a sus puntos y los de sus subcategorias
    for(MPoint *point in self.points.allObjects) {
        if(map==nil || [point.map.objectID isEqual:map.objectID]) {
            [point setAsDeleted:true];
        }
    }
    
    // Debe cambiar los puntos de sus subcategorias adecuando su iconHREF
    for(MCategory *subCat in self.subCategories) {
        [subCat deletePointsWithMap:map];
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) allSubcategories:(NSMutableArray *)cats {

    [cats addObjectsFromArray:self.subCategories.allObjects];
    for(MCategory *scat in self.subCategories) {
        [scat allSubcategories:cats];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) movePointsToCategoryWithIconHREF:(NSString *)iconHREF inMap:(MMap *)map {
    
    // Recopila todas las subcateforias
    // Se hace asi por si se moviese "hacia abajo". Lo que podría hacer un bucle infinito
    NSMutableArray *allSubCats = [NSMutableArray arrayWithObject:self];
    [self allSubcategories:allSubCats];

    // Comprueba donde se quiere mover
    MCategory *newCategory = [MCategory categoryForIconHREF:iconHREF inContext:self.managedObjectContext];
    if([self.objectID isEqual:newCategory.objectID]) return;
    

    // Cambia todos los puntos de cada categoria a la nueva categoria equivalente
    // Si se indica un mapa, se restringiran los puntos a los de ese mapa
    // Se están moviendo incluso los puntos borrados
    NSUInteger index = self.iconHREF.length;
    for(MCategory *cat in allSubCats) {
        
        NSString *newIconHREF = [NSString stringWithFormat:@"%@%@", newCategory.iconHREF, [cat.iconHREF subStrFrom:index]];
        MCategory *newSubCategory = [MCategory categoryForIconHREF:newIconHREF inContext:self.managedObjectContext];
        
        NSArray *allPoints = [NSArray arrayWithArray:cat.points.allObjects];
        for(MPoint *point in allPoints) {
            if(map==nil || [point.map.objectID isEqual:map.objectID]) {
                [point moveToCategory:newSubCategory];
            }
        }
        
    }
}


// ---------------------------------------------------------------------------------------------------------------------
- (void) setAsDeleted:(BOOL) value {
    
    // Si ya es igual no hace nada
    if(self.markedAsDeletedValue==value) return;
    
    // Si se esta borrando, eso implica borrar todos los puntos asociados
    if(value==true) {
        for(MPoint *point in self.points) {
            [point setAsDeleted:true];
        }
    }
    
    // Establece el nuevo valor llamando a su clase base
    [super setAsDeleted:value];
}

// ---------------------------------------------------------------------------------------------------------------------
- (MCacheViewCount *) viewCountForMap:(MMap *)map {

    // Si no hay mapa, no hay cuenta
    if(map==nil) {
        return nil;
    }
    
    // Busca la relacion existente previa con ese mapa
    for(MCacheViewCount *cacheViewCount in self.mapViewCounts) {
        if([cacheViewCount.map isEqual:map]) {
            return cacheViewCount;
        }
    }

    // En el caso de que sea la primera vez que se pide, crea dicha relacion
    MCacheViewCount *cacheViewCount = [MCacheViewCount cacheViewCountForMap:map category:self inContext:self.managedObjectContext];
    return cacheViewCount;

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) updateViewCount:(int) increment {

    MCategory *cat = self;
    while (cat != nil) {
        cat.viewCountValue += increment;
        cat = cat.parent;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) updateViewCountForMap:(MMap *)map increment:(int) increment {
    
    MCategory *cat = self;
    while (cat != nil) {;
        [cat viewCountForMap:map].viewCountValue += increment;
        cat = cat.parent;
    }
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
