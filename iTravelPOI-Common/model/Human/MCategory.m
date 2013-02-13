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
+ (MCategory *) categoryForIconHREF:(NSString *)iconHREF inContext:(NSManagedObjectContext *)moContext {
    
    // Parsea el iconHREF especificado
    NSString *baseURL = nil;
    NSString *extraInfo = nil;
    [MBaseEntity _parseIconHREF:iconHREF baseURL:&baseURL extraInfo:&extraInfo];
    return [MCategory categoryForIconBaseHREF:baseURL extraInfo:extraInfo inContext:moContext];
}

//---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) categoryForIconBaseHREF:(NSString *)baseHREF extraInfo:(NSString *)extraInfo inContext:(NSManagedObjectContext *)moContext {

    
    MCategory *cat;
    
    // Si no se ha puesto un nombre explicito a la categoria usara el del icono
    if(extraInfo==nil || extraInfo.length==0) {
        IconData *icon = [ImageManager iconDataForHREF:baseHREF];
        extraInfo = icon.shortName;
    }
    
    // Busca la categoria requerida por si ya existe. En cuyo caso la retorna
    cat = [MCategory _searchCategoryForIconBaseHREF:baseHREF extraInfo:extraInfo inContext:moContext];
    if(cat != nil) {
        return cat;
    }
    
    
    // Como no existe, itera el path de categorias "padre" para crear la ultima
    MCategory *parentCat = nil;
    NSMutableString *partialExtraInfo = [NSMutableString string];
    NSArray *catNames = [extraInfo componentsSeparatedByString:URL_PARAM_ITP_VAL_SEP];
    for(NSString *catName in catNames) {
        
        if(catName == nil || catName.length == 0) continue;
        
        [partialExtraInfo appendString:catName];
        [partialExtraInfo appendString:URL_PARAM_ITP_VAL_SEP];
        
        cat = [MCategory _searchCategoryForIconBaseHREF:baseHREF extraInfo:partialExtraInfo inContext:moContext];
        if(cat == nil) {
            cat = [MCategory _emptyCategoryWithName:catName inContext:moContext];
            cat.parent = parentCat;
            [cat _updateIconBaseHREF:baseHREF iconExtraInfo:[partialExtraInfo copy]];
        }
        parentCat = cat;
    }
    
    return cat;    
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) categoriesWithPointsInMap:(MMap *)map parentCategory:(MCategory *)parentCat {
    
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
    NSError *localError = nil;
    NSArray *array = [map.managedObjectContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:categoriesWithPointsInMap" messageWithFormat:@"Error fetching categories with points in map '%@' and parent category '%@%@'", map.name, parentCat.iconBaseHREF, parentCat.iconExtraInfo];
    }
    return array;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) updateDeleteMark:(BOOL) value {
    
    // Si se esta borrando, eso implica borrar todos los puntos asociados
    if(value==true) {
        for(MPoint *point in self.points) {
            [point updateDeleteMark:true];
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateViewCount:(int) increment {
    
    // Actualiza su cuenta y la de sus ancestros
    MCategory *cat = self;
    while (cat != nil) {
        cat.viewCountValue += increment;
        cat = cat.parent;
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
        if([viewCount.map.objectID isEqual:map.objectID]) {
            return viewCount;
        }
    }
    
    // En el caso de que sea la primera vez que se pide, crea dicha relacion
    RMCViewCount *viewCount = [RMCViewCount rmcViewCountForMap:map category:self];
    return viewCount;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateViewCountForMap:(MMap *)map increment:(int) increment {
    
    // Actualiza su cuenta y la de sus ancestros
    MCategory *cat = self;
    while (cat != nil) {
        RMCViewCount *rmcViewCount = [cat viewCountForMap:map];
        [rmcViewCount updateViewCount:increment];
        cat = cat.parent;
    }}

//---------------------------------------------------------------------------------------------------------------------
- (void) deletePointsInMap:(MMap *)map {
    
    // Transmite el borrado a sus puntos y los de sus subcategorias
    for(MPoint *point in self.points.allObjects) {
        if(map==nil || [point.map.objectID isEqual:map.objectID]) {
            [point updateDeleteMark:true];
        }
    }
    
    // Debe cambiar los puntos de sus subcategorias adecuando su iconHREF
    for(MCategory *subCat in self.subCategories) {
        [subCat deletePointsInMap:map];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) movePointsToCategory:(MCategory *)destCategory inMap:(MMap *)map {
    
    // Comprueba si se quiere mover a otra categoria diferente
    if([self.objectID isEqual:destCategory.objectID]) return;

    
    // Recopila todas las subcateforias
    // Se hace asi por si se moviese "hacia abajo". Lo que podría hacer un bucle infinito
    NSMutableArray *allSubCats = [NSMutableArray arrayWithObject:self];
    [self _allSubcategories:allSubCats];
    
    
    
    // Cambia todos los puntos de cada categoria a la nueva categoria equivalente
    // Si se indica un mapa, se restringiran los puntos a los de ese mapa
    // Se están moviendo incluso los puntos borrados
    NSUInteger index = self.iconExtraInfo.length;
    for(MCategory *cat in allSubCats) {
        
        NSString *newExtraInfo = [NSString stringWithFormat:@"%@%@", destCategory.iconExtraInfo, [cat.iconExtraInfo subStrFrom:index]];
        
        MCategory *newSubCategory = [MCategory categoryForIconBaseHREF:destCategory.iconBaseHREF
                                                             extraInfo:newExtraInfo
                                                             inContext:self.managedObjectContext];
        
        NSArray *allPoints = [NSArray arrayWithArray:cat.points.allObjects];
        for(MPoint *point in allPoints) {
            if(map==nil || [point.map.objectID isEqual:map.objectID]) {
                [point moveToCategory:newSubCategory];
            }
        }
        
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name {
    
    [super _resetEntityWithName:name];    
    // Lo deben establecer los puntos asociados
    [self _updateIconHREF:nil];
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) _searchCategoryForIconBaseHREF:(NSString *)baseHREF extraInfo:(NSString *)extraInfo inContext:(NSManagedObjectContext *)moContext {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"iconBaseHREF=%@ AND iconExtraInfo=%@", baseHREF, extraInfo];
    [request setPredicate:query];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:_searchCategoryForIconHREF" messageWithFormat:@"Error fetching categories with iconBaseHREF '%@' and extraInfo='%@'", baseHREF, extraInfo];
        return nil;
    }
    
    if(array.count == 0) {
        return nil;
    } else {
        if(array.count>1) {
            [ErrorManagerService manageError:nil compID:@"MCategory:_searchCategoryForIconHREF" messageWithFormat:@"Error, more than one result, fetching categories with iconHREF '%@' and extraInfo='%@'", baseHREF, extraInfo];
        }
        MCategory *category = array[0];
        return category;
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) _emptyCategoryWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {
    
    MCategory *Category = [MCategory insertInManagedObjectContext:moContext];
    [Category _resetEntityWithName:name];
    return Category;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _allSubcategories:(NSMutableArray *)cats {
    
    [cats addObjectsFromArray:self.subCategories.allObjects];
    for(MCategory *subCat in self.subCategories) {
        [subCat _allSubcategories:cats];
    }
}



@end
