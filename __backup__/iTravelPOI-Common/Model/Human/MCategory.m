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
    NSString *fullName = nil;
    [MCategory _parseIconHREF:iconHREF baseURL:&baseURL fullName:&fullName];
    return [MCategory categoryForIconBaseHREF:baseURL fullName:fullName inContext:moContext];
}

//---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) categoryForIconBaseHREF:(NSString *)baseHREF fullName:(NSString *)fullName inContext:(NSManagedObjectContext *)moContext {
    
    
    MCategory *cat;
    
    // Si no se ha puesto un nombre explicito a la categoria usara el del icono
    if(fullName==nil || fullName.length==0) {
        IconData *icon = [ImageManager iconDataForHREF:baseHREF];
        fullName = icon.shortName;
    }
    
    // Busca la categoria requerida por si ya existe. En cuyo caso la retorna
    cat = [MCategory _searchCategoryForIconBaseHREF:baseHREF fullName:fullName inContext:moContext];
    if(cat != nil) {
        return cat;
    }
    
    
    // Como no existe, itera el path de categorias "padre" para crear la ultima
    MCategory *parentCat = nil;
    NSMutableString *partialFullName = [NSMutableString string];
    NSArray *catNames = [fullName componentsSeparatedByString:CAT_NAME_SEPARATOR];
    for(NSString *catName in catNames) {
        
        if(catName == nil || catName.length == 0) continue;
        
        [partialFullName appendString:catName];
        [partialFullName appendString:CAT_NAME_SEPARATOR];
        
        cat = [MCategory _searchCategoryForIconBaseHREF:baseHREF fullName:partialFullName inContext:moContext];
        if(cat == nil) {
            cat = [MCategory insertInManagedObjectContext:moContext];
            cat.name = catName;
            cat.fullName = [partialFullName copy];
            cat.parent = parentCat;
            cat.iconBaseHREF = baseHREF;
            cat.updated_date = [NSDate date];
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
        [ErrorManagerService manageError:localError compID:@"MCategory:categoriesWithPointsInMap" messageWithFormat:@"Error fetching categories with points in map '%@' and parent category '%@'-'%@'", map.name, parentCat.iconBaseHREF, parentCat.fullName];
    }
    return array;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (MAP_ENTITY_TYPE) entityType {
    return MET_CATEGORY;
}

//---------------------------------------------------------------------------------------------------------------------
- (JZImage *) entityImage {
    return [ImageManager iconDataForHREF:self.iconBaseHREF].image;
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
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) iconHREF {
    
    NSString *value;
    
    if([self.iconBaseHREF indexOf:@"?"]==NSNotFound){
        value = [NSString stringWithFormat:@"%@?%@%@", self.iconBaseHREF, URL_PARAM_CAT_INFO, self.fullName];
    } else {
        value = [NSString stringWithFormat:@"%@&%@%@", self.iconBaseHREF, URL_PARAM_CAT_INFO, self.fullName];
    }
    return value;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) pathName {

    NSString *value = [self.fullName subStrFrom:0 to:self.fullName.length-self.name.length-1];
    if([value hasSuffix:CAT_NAME_SEPARATOR]) {
        return [value subStrFrom:0 to:value.length-1];
    } else {
        return value;
    }
}


// ---------------------------------------------------------------------------------------------------------------------
- (void) xxx_updateDeleteMark:(BOOL) value {
    
    // Si se esta borrando, eso implica borrar todos los puntos asociados
    if(value==true) {
        for(MPoint *point in self.points) {
            //[point updateDeleteMark:true];
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



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) _searchCategoryForIconBaseHREF:(NSString *)baseHREF fullName:(NSString *)fullName inContext:(NSManagedObjectContext *)moContext {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCategory"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"iconBaseHREF=%@ AND fullName=%@", baseHREF, fullName];
    [request setPredicate:query];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MCategory:_searchCategoryForIconHREF" messageWithFormat:@"Error fetching categories with iconBaseHREF '%@' and fullName='%@'", baseHREF, fullName];
        return nil;
    }
    
    if(array.count == 0) {
        return nil;
    } else {
        if(array.count>1) {
            [ErrorManagerService manageError:nil compID:@"MCategory:_searchCategoryForIconHREF" messageWithFormat:@"Error, more than one result, fetching categories with iconHREF '%@' and fullName='%@'", baseHREF, fullName];
        }
        MCategory *category = array[0];
        return category;
    }
    
}


// ---------------------------------------------------------------------------------------------------------------------
+ (void) _parseIconHREF:(NSString *)iconHREF baseURL:(NSString **)baseURL fullName:(NSString **)fullName {
    
    NSUInteger p1, p1_1;
    NSUInteger p2, p2_1;
    
    
    p1 = [iconHREF indexOf:URL_PARAM_CAT_INFO];
    if(p1 == NSNotFound) {
        p1 = iconHREF.length - URL_PARAM_CAT_INFO.length;
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
    
    
    // Compone la parte del BaseURL
    NSString *strBefore = [iconHREF subStrFrom:0 to:p1_1];
    NSString *strAfter = [iconHREF subStrFrom:p2_1];
    *baseURL = [NSString stringWithFormat:@"%@%@", strBefore, strAfter];
    
    
    // Compone la parte del extraInfo
    NSString *infoValue = [iconHREF subStrFrom:p1 + URL_PARAM_CAT_INFO.length to:p2];
    if(infoValue == nil || infoValue.length == 0) {
        IconData *icon = [ImageManager iconDataForHREF:*baseURL];
        infoValue = icon.shortName;
    }
    if([infoValue hasSuffix:CAT_NAME_SEPARATOR]) {
        *fullName = infoValue;
    } else {
        *fullName = [NSString stringWithFormat:@"%@%@", infoValue, CAT_NAME_SEPARATOR];
    }
}



@end
