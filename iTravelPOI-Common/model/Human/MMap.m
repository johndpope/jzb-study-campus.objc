#import "MMap.h"
#import "MPoint.h"
#import "MCacheViewCount.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MMap ()

@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MMap



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MMap *) emptyMapInContext:(NSManagedObjectContext *) moContext {
    return [MMap emptyMapWithName:@"" inContext:moContext];
}

//---------------------------------------------------------------------------------------------------------------------
+ (MMap *) emptyMapWithName:(NSString *)name inContext:(NSManagedObjectContext *) moContext {

    MMap *map = [MMap insertInManagedObjectContext:moContext];
    [map resetEntityWithName:name];
    return map;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allMapsInContext:(NSManagedObjectContext *) moContext includeMarkedAsDeleted:(BOOL)withDeleted error:(NSError **)err {

    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;

    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MMap"];
    
    // Se asigna una condicion de filtro
    if(withDeleted==NO) {
        NSPredicate *query = [NSPredicate predicateWithFormat:@"markedAsDeleted=NO"];
        [request setPredicate:query];
    }

    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    // Se ejecuta y retorna el resultado
    NSArray *array = [moContext executeFetchRequest:request error:err];
    return array;
}

//=====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setMarkedAsDeleted:(NSNumber *)markedAsDeleted {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.markedAsDeleted isEqual:markedAsDeleted]) return;

    // Si se esta borrando, eso implica borrar todos los puntos del mapa
    if(markedAsDeleted.boolValue) {
        for(MPoint *point in self.points) {
            point.markedAsDeleted = markedAsDeleted;
        }
    }
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"markedAsDeleted"];
    [self setPrimitiveMarkedAsDeleted:markedAsDeleted];
    [self didChangeValueForKey:@"markedAsDeleted"];
}


//=====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (void) resetEntityWithName:(NSString *)name {

    [super resetEntityWithName:name];
    self.summary=@"";
}

//---------------------------------------------------------------------------------------------------------------------
- (void) resetViewCount {
    self.viewCount = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) updateViewCount {
    
    NSError *err = nil;
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MPoint"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"(markedAsDeleted=NO) AND (map=%@)",self];
    [request setPredicate:query];
    
    // Se ejecuta y retorna el resultado
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];

    // Actualiza la cuenta
    self.viewCount = [NSString stringWithFormat:@"%03ld", count];
    return self.viewCount;
}


//=====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------


@end
