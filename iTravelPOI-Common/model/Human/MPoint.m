//
//  MPoint.m
//

#define __MPoint__IMPL__
#define __MPoint__PROTECTED__
#define __MBaseEntity__SUBCLASSES__PROTECTED__

#import "MPoint.h"
#import "MMap.h"
#import "MCategory.h"
#import "MMapThumbnail.h"
#import "ErrorManagerService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define UPD_POINT_ADDED   +1
#define UPD_POINT_REMOVED -1
#define DEFAULT_POINT_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png"




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MPoint ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MPoint



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map  {
    
    NSManagedObjectContext *moContext = map.managedObjectContext;
    
    
    MPoint *point = [MPoint insertInManagedObjectContext:moContext];
    point.thumbnail = [MMapThumbnail emptyThumnailInContext:moContext];
    
    [point _resetEntityWithName:name];
    point.map = map;
    
    
    [point.map updateViewCount: UPD_POINT_ADDED];
    
    
    return point;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allPointsInContext:(NSManagedObjectContext *)moContext includeMarkedAsDeleted:(BOOL)withDeleted {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MPoint"];
    
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
        [ErrorManagerService manageError:localError compID:@"MPoint:allPointsInContext" messageWithFormat:@"Error fetching all points in context [deleted=%d]",withDeleted];
    }
    return array;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) pointsInMap:(MMap *)map andCategory:(MCategory *)cat {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MPoint"];
    
    
    // Se asigna una condicion de filtro
    NSString *queryStr;
    if(cat==nil) {
        queryStr = @"markedAsDeleted=NO AND map=%@ AND categories.@count=0";
    } else {
        queryStr = @"markedAsDeleted=NO AND map=%@ AND %@ IN categories";
    }
    NSPredicate *query = [NSPredicate predicateWithFormat:queryStr, map, cat];
    [request setPredicate:query];
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"iconHREF" ascending:TRUE];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [map.managedObjectContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MPoint:pointsInMap" messageWithFormat:@"Error fetching points in map '%@' with category '%@'", map.name, cat.fullName];
    }
    return array;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (MODEL_ENTITY_TYPE) entityType {
    return MET_POINT;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted:(BOOL) value {
    
    // Si ya es igual no hace nada
    if(self.markedAsDeletedValue==value) return;
    
    // Ajusta la cuenta de puntos visibles en su mapa y categorias
    int increment = value ? UPD_POINT_REMOVED : UPD_POINT_ADDED;
    [self.map updateViewCount:increment];
    for(MCategory *cat in self.categories) {
        [cat updateViewCount:increment inMap:self.map];
    }
    
    // Establece el nuevo valor llamando a su clase base
    [super _baseMarkAsDeleted:value];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) markAsModified {
    
    // Cuando se modifica un punto se debe modificar tambien su mapa
    [self.map markAsModified];
    
    // Establece el nuevo valor llamando a su clase base
    [super _baseMarkAsModified];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) setLatitude:(double)lat longitude:(double)lng {
    
    // Si hay un cambio de coordenadas las establece
    if(self.latitudeValue!=lat || self.longitudeValue!=lng) {
        self.latitudeValue = lat;
        self.longitudeValue = lng;
        return TRUE;
    } else {
        return FALSE;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) addToCategory:(MCategory *)category {
    
    // Chequea que no este vacia
    if(!category) return;
    
    
    // Solo puede estar asignado a una subcategoria dada dentro de una jerarquia
    for(MCategory *cat in [self.categories copy]) {
        
        // Si ya estaba asignado a esa categoria termina
        if(cat.internalIDValue==category.internalIDValue) {
            return;
        }
        
        // Si estaba asigando a una categoria de la "familia" se desasigna de ella antes de seguir
        if([cat isRelatedTo:category]) {
            [self removeFromCategory:cat];
        }
    }
    
    // Se añade a la nueva y ajusta su cuenta
    [category addPointsObject:self];
    [category updateViewCount:UPD_POINT_ADDED inMap:self.map];
    
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) removeFromCategory:(MCategory *)category {
    
    // Chequea que no este vacia
    if(!category) return;

    // Primero tenemos que ver que ya estaba asignado
    // De ser asi se borra y ajusta la cuenta
    for(MCategory *cat in [self.categories copy]) {
        if(cat.internalIDValue==category.internalIDValue) {
            [cat removePointsObject:self];
            [cat updateViewCount:UPD_POINT_REMOVED inMap:self.map];
            break;
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) replaceCategories:(NSArray *)categories {
    
    // Elimina las que tenia el punto y que no estan en la nueva coleccion
    for(MCategory *cat in [self.categories copy]) {
        if(![categories containsObject:cat]) {
            [self removeFromCategory:cat];
        }
    }
    
    // Añade las que solo estan en la nueva coleccion
    for(MCategory *cat in categories) {
        if(![self.categories containsObject:cat]) {
            [self addToCategory:cat];
        }
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name {
    
    [super _resetEntityWithName:name iconHref:DEFAULT_POINT_ICON_HREF];
        
    self.descr = @"";
    self.latitudeValue = 0.0;
    self.longitudeValue = 0.0;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------



@end
