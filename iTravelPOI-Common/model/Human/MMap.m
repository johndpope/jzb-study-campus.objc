#import "MMap.h"
#import "MPoint.h"
#import "MCacheViewCount.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface MMap ()

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation MMap



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MMap *) emptyMapInContext:(NSManagedObjectContext *)moContext {
    return [MMap emptyMapWithName:@"" inContext:moContext];
}

// ---------------------------------------------------------------------------------------------------------------------
+ (MMap *) emptyMapWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {

    MMap *map = [MMap insertInManagedObjectContext:moContext];
    [map resetEntityWithName:name];
    return map;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allMapsInContext:(NSManagedObjectContext *)moContext includeMarkedAsDeleted:(BOOL)withDeleted error:(NSError **)err {

    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;

    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MMap"];

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
    NSArray *array = [moContext executeFetchRequest:request error:err];
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
    self.summary = @"";
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) updateViewCount:(int) increment {
    self.viewCountValue += increment;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setAsDeleted:(BOOL)value {
    
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


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
