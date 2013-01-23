#import "MPoint.h"
#import "GMTPoint.h"
#import "MMap.h"
#import "MCategory.h"
#import "MCacheViewCount.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface MPoint ()

// Private interface goes here.

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
+ (MPoint *) emptyPointInMap:(MMap *)map inContext:(NSManagedObjectContext *)moContext {
    return [MPoint emptyPointWithName:@"" inMap:map inContext:moContext];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map inContext:(NSManagedObjectContext *)moContext {

    MPoint *point = [MPoint insertInManagedObjectContext:moContext];
    point.map = map;
    [point resetEntityWithName:name];
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
- (void) setModifiedSinceLastSync:(NSNumber *)modifiedSinceLastSync {
    
    // Cada vez que se modifica un punto, tambien lo hace su mapa
    self.map.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"modifiedSinceLastSync"];
    [self setPrimitiveModifiedSinceLastSync:modifiedSinceLastSync];
    [self didChangeValueForKey:@"modifiedSinceLastSync"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setMarkedAsDeleted:(NSNumber *)markedAsDeleted {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.markedAsDeleted isEqual:markedAsDeleted]) return;
    
    // Anula las cuentas cacheadas
    [self.map resetViewCount];
    [self.category resetViewCount];
    [self.category resetViewCountForMap:self.map];
    
    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"markedAsDeleted"];
    [self setPrimitiveMarkedAsDeleted:markedAsDeleted];
    [self didChangeValueForKey:@"markedAsDeleted"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setMap:(MMap *)newMap {

    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.map.objectID isEqual:newMap.objectID]) return;
    
    // Anula las cuentas cacheadas de los valores actuales
    [self.map resetViewCount];
    [self.category resetViewCountForMap:self.map];

    // Marca el mapa actual como modificado desde la ultima sincronizacion
    self.map.modifiedSinceLastSyncValue = true;

    // Establece el nuevo valor
    [self willChangeValueForKey:@"map"];
    [self setPrimitiveMap:newMap];
    [self didChangeValueForKey:@"map"];

    // Anula las cuentas cacheadas de los valores establecidos
    [self.map resetViewCount];
    [self.category resetViewCountForMap:self.map];
    
    // Lo marca como modificado desde la ultima sincronizacion
    // Hay que hacerlo aqui despues de cambiar el valor del mapa referenciado
    self.modifiedSinceLastSyncValue = true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setCategory:(MCategory *)newCategory {

    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.category.objectID isEqual:newCategory.objectID]) return;

    // Anula las cuentas cacheadas de los valores actuales
    [self.category resetViewCountForMap:self.map];

    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;

    // Establece el nuevo valor
    [self willChangeValueForKey:@"category"];
    [self setPrimitiveCategory:newCategory];
    [self didChangeValueForKey:@"category"];

    // Anula las cuentas cacheadas de los valores establecidos
    [self.category resetViewCountForMap:self.map];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setIconHREF:(NSString *)value {

    // ==========================================================================================
    // Cambiar desde el interfaz, no desde el storage, el iconHREF implica recatalogar al punto
    // ==========================================================================================


    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.iconHREF isEqualToString:value]) return;

    // Asigna la nueva categoria acorde con el nuevo iconHREF
    NSError *err = nil;
    MCategory *pointCategory = [MCategory categoryForIconHREF:value inContext:self.managedObjectContext error:&err];

    if(pointCategory == nil) {
        // ¿que podemos hacer?
    } else {
        // Se asigna a la nueva categoria
        self.category = pointCategory;
        // Se asigna el iconHREF normalizado de la categoria
        value = pointCategory.iconHREF;
    }

    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;

    // Cambia el valor primitivo del atributo para que se almacene en el storage
    [self willChangeValueForKey:@"iconHREF"];
    [self setPrimitiveIconHREF:value];
    [self didChangeValueForKey:@"iconHREF"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setDescr:(NSString *)descr {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.descr isEqual:descr]) return;
    
    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"descr"];
    [self setPrimitiveDescr:descr];
    [self didChangeValueForKey:@"descr"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setLatitude:(NSNumber *)latitude {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.latitude isEqual:latitude]) return;
    
    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"latitude"];
    [self setPrimitiveLatitude:latitude];
    [self didChangeValueForKey:@"latitude"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setLongitude:(NSNumber *)longitude {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.longitude isEqual:longitude]) return;
    
    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"longitude"];
    [self setPrimitiveLongitude:longitude];
    [self didChangeValueForKey:@"longitude"];
}


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) resetEntityWithName:(NSString *)name {

    [super resetEntityWithName:name];
    self.descr = @"";
    self.iconHREF = GM_DEFAULT_POINT_ICON_HREF;
    self.latitudeValue = 0.0;
    self.longitudeValue = 0.0;
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
