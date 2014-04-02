//
//  MMap.m
//

#define __MMap__IMPL__
#define __MMap__PROTECTED__
#define __MBase__SUBCLASSES__PROTECTED__
#define __MBaseSync__SUBCLASSES__PROTECTED__


#import "MMap.h"
#import "MPoint.h"
#import "MIcon.h"
#import "ErrorManagerService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define DEFAULT_MAP_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/flag.png"




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
+ (NSString *) _myEntityName {
    return @"MMap";
}

//---------------------------------------------------------------------------------------------------------------------
+ (MMap *) emptyMapWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {
    
    MMap *map = [MMap insertInManagedObjectContext:moContext];
    [map  _resetEntityWithName:name inContext:moContext];
    return map;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allMapsinContext:(NSManagedObjectContext *)moContext includeMarkedAsDeleted:(BOOL)withDeleted {
    
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
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MMap:allMapsInContext - Error fetching all maps in context [deleted=%d]",withDeleted];
    }
    return array;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) deleteEntity {
    
    self.summary = nil;
    [super deleteEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateSummary:(NSString *)value {
    
    if((value || self.summary) && ![self.summary isEqualToString:value]) {
        [self markAsModified];
        self.summary = value;
        return TRUE;
    }
    return FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted:(BOOL) value {

    [super markAsDeleted:value];

    // Marca todos sus puntos como borrados tambien
    if(value==TRUE) {
        for(MPoint *point in self.points) {
            [point markAsDeleted:value];
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger) pointsCount {
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MPoint"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"map=%@ AND markedAsDeleted=NO",self];
    [request setPredicate:query];

    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSInteger count = [self.managedObjectContext countForFetchRequest:request error:&localError];
    if(localError!=nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MMap:pointsCount - Error fetching point count in map"];
    }
    return count;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {
    
    [super _resetEntityWithName:name icon:[MIcon iconForHref:DEFAULT_MAP_ICON_HREF inContext:moContext]];
    //self.viewCountValue = 0;
    self.summary = @"";
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
