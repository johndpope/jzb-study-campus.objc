//
//  MPoint.m
//

#define __MPoint__IMPL__
#define __MPoint__PROTECTED__
#define __MBaseEntity__SUBCLASSES__PROTECTED__
#define __MBaseGMSync__SUBCLASSES__PROTECTED__

#import "MPoint.h"
#import "MMap.h"
#import "MCategory.h"
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
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map withCategory:(MCategory *)category {
    
    NSManagedObjectContext *moContext = map.managedObjectContext;
    
    
    MPoint *point = [MPoint insertInManagedObjectContext:moContext];
    
    [point _resetEntityWithName:name];
    
    point.map = map;
    
    if(category!=nil) {
        point.category = (MCategory *)[moContext objectWithID:category.objectID];
    } else {
        point.category = [MCategory categoryForIconBaseHREF:DEFAULT_POINT_ICON_HREF extraInfo:nil inContext:moContext];
    }
    [point _updateIconBaseHREF:point.category.iconBaseHREF iconExtraInfo:point.category.iconExtraInfo];
    
    [point.map updateViewCount: UPD_POINT_ADDED];
    [point.category updateViewCount: UPD_POINT_ADDED];
    [point.category updateViewCountForMap:map increment:UPD_POINT_ADDED];
    
    return point;
}

// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) pointsInMap:(MMap *)map category:(MCategory *)cat {
        
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
    NSError *localError = nil;
    NSArray *array = [map.managedObjectContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"MPoint:pointsInMap" messageWithFormat:@"Error fetching points in map '%@' with category '%@%@'", map.name, cat.iconBaseHREF, cat.iconExtraInfo];
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
//---------------------------------------------------------------------------------------------------------------------
- (void) updateDeleteMark:(BOOL) value {
    
    // Si ya es igual no hace nada
    if(self.markedAsDeletedValue==value) return;
    
    // Ajusta la cuenta de puntos visibles en su mapa y categoria
    int increment = value ? UPD_POINT_REMOVED : UPD_POINT_ADDED;
    [self.map updateViewCount:increment];
    [self.category updateViewCount: increment];
    [self.category updateViewCountForMap:self.map increment:increment];
    
    // Establece el nuevo valor llamando a su clase base
    [super _baseUpdateDeleteMark:value];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) moveToCategory:(MCategory *)category {
    
    // Si ya es igual no hace nada
    if([self.category.objectID isEqual:category.objectID]) return;
    
    
    // Descuenta de la actual si no estaba marcado como borrado
    if(!self.markedAsDeletedValue) {
        [self.category updateViewCount: UPD_POINT_REMOVED];
        [self.category updateViewCountForMap:self.map increment:UPD_POINT_REMOVED];
    }
    
    self.category = category;
    [self _updateIconBaseHREF:category.iconBaseHREF iconExtraInfo:category.iconExtraInfo];
    
    // añade a la nueva si no estaba marcado como borrado
    if(!self.markedAsDeletedValue) {
        [self.category updateViewCount: UPD_POINT_ADDED];
        [self.category updateViewCountForMap:self.map increment:UPD_POINT_ADDED];
    }
}




//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name {
    
    [super _resetEntityWithName:name];
        
    [self _updateIconHREF:nil];
    self.descr = @"";
    self.latitudeValue = 0.0;
    self.longitudeValue = 0.0;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------



@end
