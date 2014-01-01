//
//  MPoint.m
//

#define __MPoint__IMPL__
#define __MPoint__PROTECTED__
#define __MBase__SUBCLASSES__PROTECTED__
#define __MBaseSync__SUBCLASSES__PROTECTED__


#import "MPoint.h"
#import "MMap.h"
#import "MIcon.h"
#import "MTag.h"
#import "ErrorManagerService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
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
    [point _resetEntityWithName:name inContext:moContext];
    point.map = map;
    
    
    /////[point.map updateViewCount: UPD_POINT_ADDED];
    
    
    return point;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allPointsInContext:(NSManagedObjectContext *)moContext includeMarkedAsDeleted:(BOOL)withDeleted {
    
    NSDate *start = [NSDate date];
    NSLog(@"MPoint - allPointsInContext - in");

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
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MPoint:allPointsInContext - Error fetching all points in context [deleted=%d]",withDeleted];
    }

    NSLog(@"MPoint - allPointsInContext - out = %f",[start timeIntervalSinceNow]);
    
    return array;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) pointsTaggedWith:(NSSet *)tags inMap:(MMap *)map InContext:(NSManagedObjectContext *)moContext {
    
    NSDate *start = [NSDate date];
    NSLog(@"MPoint - pointsTaggedWith - in");

    
    // Se protege contra un filtro vacio
    if(tags.count==0) {
        if(map) {
            return [map.points allObjects];
        } else {
            return [MPoint allPointsInContext:moContext includeMarkedAsDeleted:NO];
        }
    }
    
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RPointTag"];
    
    // Crea los atributos de agrupacion y de cuenta
    NSExpressionDescription* expDesc = [[NSExpressionDescription alloc] init];
    [expDesc setName: @"tagCount"];
    [expDesc setExpressionResultType: NSInteger32AttributeType];
    [expDesc setExpression: [NSExpression expressionWithFormat:@"isDirect.@count"]];

    [request setPropertiesToGroupBy:[NSArray arrayWithObject:@"point"]];
    
    // Indica que se recojan ambos atributos como un diccionario
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"point", expDesc, nil]];
    [request setResultType:NSDictionaryResultType];
    
    // Se asigna una condicion de filtro
    NSString *queryStr = @"point.markedAsDeleted=NO AND tag IN %@";
    NSPredicate *query = [NSPredicate predicateWithFormat:queryStr, tags];
    [request setPredicate:query];
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"point.name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortNameDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MPoint:pointsTaggedWith - Error fetching tagged points in context [tags=%@]",tags];
    }
    
    // Del array debe filtrar aquellos cuya cuenta sea la del filtro
    NSMutableArray *array2 = [NSMutableArray array];
    for(NSDictionary *dict in array) {
        NSNumber *count2=[dict objectForKey:@"tagCount"];
        if(count2.intValue>=tags.count) {
            NSManagedObjectID *objID = [dict objectForKey:@"point"];
            MPoint *obj = (MPoint *)[moContext objectWithID:objID];
            [array2 addObject:obj];
        }
    }
    
    NSLog(@"MPoint - pointsTaggedWith - out = %f",[start timeIntervalSinceNow]);
    
    return array2;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) pointsWithIcon:(MIcon *)icon {
    
    // Se protege contra un filtro vacio
    if(!icon) {
        return nil;
    }

    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MPoint"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"markedAsDeleted=NO AND icon=%@", icon];
    [request setPredicate:query];
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [icon.managedObjectContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MPoint:pointsWithIcon - Error fetching points in context [icon=%@]",icon];
    }
    return array;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) updateIcon:(MIcon *)icon {
    
    // Si el icono previo era del tipo auto-tag desasigna del tag
    [self.icon.tag untagPoint:self];
    
    // Llama a la clase base para que actualice la informacion
    [super updateIcon:icon];

    // Si el nuevo icono es del tipo auto-tag se asigna al tag
    [self.icon.tag tagPoint:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) setLatitude:(double)lat longitude:(double)lng {
    
    // Ajusta los margenes
    lat = MAX(lat, -90.0);
    lat = MIN(lat, 90.0);
    lng = MAX(lng, -180.0);
    lng = MIN(lng, 180.0);
    
    // Si hay un cambio de coordenadas las establece
    if(self.latitudeValue!=lat || self.longitudeValue!=lng) {
        self.latitudeValue = lat;
        self.longitudeValue = lng;
        return TRUE;
    } else {
        return FALSE;
    }
}




//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {
    
    [super _resetEntityWithName:name icon:[MIcon iconForHref:DEFAULT_POINT_ICON_HREF inContext:moContext]];
    self.descr = @"";
    [self setLatitude:0.0 longitude:0.0];
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
