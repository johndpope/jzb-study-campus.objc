#import "MPoint.h"
#import "GMTPoint.h"
#import "MMap.h"
#import "MCategory.h"
#import "MCacheViewCount.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MPoint ()

// Private interface goes here.

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
+ (MPoint *) emptyPointInMap:(MMap *) map inContext:(NSManagedObjectContext *) moContext {
    return [MPoint emptyPointWithName:@"" inMap:map inContext:moContext];
}

//---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *) map inContext:(NSManagedObjectContext *) moContext {

    MPoint *point = [MPoint insertInManagedObjectContext:moContext];
    point.map = map;
    [point resetEntityWithName:name];
    return point;
}

//---------------------------------------------------------------------------------------------------------------------
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


//=====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setMap:(MMap *) newMap {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.map isEqual:newMap]) return;

    // Anula las cuentas cacheadas de los valores actuales
    [self.map resetViewCount];
    [self.category resetViewCountForMap:self.map];

    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"map"];
    [self setPrimitiveMap:newMap];
    [self didChangeValueForKey:@"map"];
    
    // Anula las cuentas cacheadas de los valores establecidos
    [self.map resetViewCount];
    [self.category resetViewCountForMap:self.map];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setCategory:(MCategory *)newCategory {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.category isEqual:newCategory]) return;
    
    // Anula las cuentas cacheadas de los valores actuales
    [self.category resetViewCountForMap:self.map];
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"category"];
    [self setPrimitiveCategory:newCategory];
    [self didChangeValueForKey:@"category"];
    
    // Anula las cuentas cacheadas de los valores establecidos
    [self.category resetViewCountForMap:self.map];

}

//---------------------------------------------------------------------------------------------------------------------
- (void) setMarkedAsDeleted:(NSNumber *)markedAsDeleted {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.markedAsDeleted isEqual:markedAsDeleted]) return;

    // Anula las cuentas cacheadas
    [self.map resetViewCount];
    [self.category resetViewCountForMap:self.map];
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"markedAsDeleted"];
    [self setPrimitiveMarkedAsDeleted:markedAsDeleted];
    [self didChangeValueForKey:@"markedAsDeleted"];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setIconHREF:(NSString *) value {
    
    // ==========================================================================================
    // Cambiar desde el interfaz, no desde el storage, el iconHREF implica recatalogar al punto
    // ==========================================================================================

    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.iconHREF isEqualToString:value]) return;

    // Asigna la nueva categoria acorde con el nuevo iconHREF
    NSError *err = nil;
    MCategory *pointCategory = [MCategory categoryForIconHREF:value inContext:self.managedObjectContext error:&err];
    
    if(pointCategory==nil) {
        //¿que podemos hacer?
    } else {
        // Se asigna a la nueva categoria
        self.category = pointCategory;
        // Se asigna el iconHREF normalizado de la categoria
        value = pointCategory.iconHREF;
    }
    
    
    // Cambia el valor primitivo del atributo para que se almacene en el storage
    [self willChangeValueForKey:@"iconHREF"];
    [self setPrimitiveIconHREF:value];
    [self didChangeValueForKey:@"iconHREF"];

}



//=====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) resetEntityWithName:(NSString *)name {
    
    [super resetEntityWithName:name];
    self.descr = @"";
    self.iconHREF = GM_DEFAULT_POINT_ICON_HREF;
    self.latitudeValue = 0.0;
    self.longitudeValue = 0.0;
}



//=====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------


@end
