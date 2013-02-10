#define __MPoint__PROTECTED__
#import "MPoint.h"


#import "GMTPoint.h"
#import "MMap.h"
#import "MCategory.h"
#import "MCacheViewCount.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************
#define UPD_POINT_ADDED   +1
#define UPD_POINT_REMOVED -1


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface MPoint ()


@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation MPoint


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) emptyPointInMap:(MMap *)map {

    MCategory *cat = [MCategory categoryForIconHREF:GM_DEFAULT_POINT_ICON_HREF inContext:map.managedObjectContext];
    return [MPoint emptyPointWithName:@"" inMap:map withCategory:cat];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map {

    MCategory *cat = [MCategory categoryForIconHREF:GM_DEFAULT_POINT_ICON_HREF inContext:map.managedObjectContext];
    return [MPoint emptyPointWithName:name inMap:map withCategory:cat];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map withCategory:(MCategory *)category {

    MPoint *point = [MPoint insertInManagedObjectContext:map.managedObjectContext];
    [point resetEntityWithName:name];
    
    point.map = map;
    
    if(category!=nil) {
        point.category = category;
    } else {
        point.category = [MCategory categoryForIconHREF:GM_DEFAULT_POINT_ICON_HREF inContext:point.managedObjectContext];
    }
    point.iconHREF = point.category.iconHREF;
    
    [point.map updateViewCount: UPD_POINT_ADDED];
    [point.category updateViewCount: UPD_POINT_ADDED];
    [point.category updateViewCountForMap:map increment:UPD_POINT_ADDED];
    
    return point;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) pointsFromMap:(MMap *)map category:(MCategory *)cat error:(NSError **)err {

    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;

    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MPoint"];


    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"markedAsDeleted=NO AND map=%@ AND category=%@", map, cat];
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



// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) resetEntityWithName:(NSString *)name {

    [super resetEntityWithName:name];
    self.descr = @"";
    self.latitudeValue = 0.0;
    self.longitudeValue = 0.0;

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) moveToIconHREF:(NSString *)iconHREF {

    [self moveToCategory: [MCategory categoryForIconHREF:iconHREF inContext:self.managedObjectContext]];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) moveToCategory:(MCategory *)category {
    
    // Si ya es igual no hace nada
    if([self.category.objectID isEqual:category.objectID]) return;
    
    
    // Descuenta de la actual
    [self.category updateViewCount: UPD_POINT_REMOVED];
    [self.category updateViewCountForMap:self.map increment:UPD_POINT_REMOVED];
    
    self.category = category;
    self.iconHREF = category.iconHREF;
    
    // añade a la nueva
    [self.category updateViewCount: UPD_POINT_ADDED];
    [self.category updateViewCountForMap:self.map increment:UPD_POINT_ADDED];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setAsDeleted:(BOOL)value {
    
    // Si ya es igual no hace nada
    if(self.markedAsDeletedValue==value) return;

    // Ajusta la cuenta de puntos visibles en su mapa y categoria
    int increment = value ? UPD_POINT_REMOVED : UPD_POINT_ADDED;
    [self.map updateViewCount:increment];
    [self.category updateViewCount: increment];
    [self.category updateViewCountForMap:self.map increment:increment];

    // Establece el nuevo valor llamando a su clase base
    [super setAsDeleted:value];
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
