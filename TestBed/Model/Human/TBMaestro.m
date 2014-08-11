//
//  TBMaestro.m
//

#define __TBMaestro__IMPL__
#define __TBMaestro__PROTECTED__

#import "TBMaestro.h"
#import "TBDetalle.h"
#import "BaseCoreDataService.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TBMaestro ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TBMaestro



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+(TBMaestro *) newWithoutContext {

    NSManagedObjectContext *moContext = [BaseCoreDataService moContext];
    NSManagedObjectContext *childContext =[BaseCoreDataService childContextASyncFor:moContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TBMaestro" inManagedObjectContext:childContext];
    TBMaestro *maestro = (TBMaestro *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:childContext];
    return maestro;
}

//---------------------------------------------------------------------------------------------------------------------
+(void) dumpAllInfoInContext:(NSManagedObjectContext *)moContext {

    NSLog(@"***** Retrieving all info from storage *****");
    NSArray *maestros = [TBMaestro findByName:nil inContext:moContext];
    
    NSLog(@"***** Printing retrieved info *****");
    for(TBMaestro *maestro in maestros) {
        NSLog(@"  --> %@",maestro);
    }
    NSLog(@"***** DONE! *****");
}

//---------------------------------------------------------------------------------------------------------------------
+(NSArray *) findByName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TBMaestro"];
    
    // Se asigna una condicion de filtro
    if(name.length > 0) {
        NSPredicate *query = [NSPredicate predicateWithFormat:@"nombre = %@", name];
        [request setPredicate:query];
    }
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nombre" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        NSLog(@"TBMaestro - Error fetching all entities in context with name=%@",name);
    }
    
    return array;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) dump {
    
    NSLog(@"TBMaestro - nombre: %@",self.nombre);
    NSLog(@"  Detalles[%d]:",self.detalles.count);
    for(TBDetalle *detalle in self.detalles) {
        NSLog(@"    TBDetalle - nombre: %@",detalle.nombre);
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (TBDetalle *) newDetalle {

    //NSManagedObjectContext *moContext = [BaseCoreDataService moContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TBDetalle" inManagedObjectContext:self.managedObjectContext];
    TBDetalle *detalle = (TBDetalle *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    detalle.maestro = self;
    return detalle;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
