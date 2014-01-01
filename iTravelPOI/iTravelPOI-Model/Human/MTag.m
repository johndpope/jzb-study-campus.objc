//
//  MTag.m
//

#define __MTag__IMPL__
#define __MTag__PROTECTED__
#define __MBase__SUBCLASSES__PROTECTED__
#define __MBaseSync__SUBCLASSES__PROTECTED__

#import "MTag.h"
#import "MPoint.h"
#import "RPointTag.h"
#import "MIcon.h"
#import "ErrorManagerService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define DEFAULT_TAG_ICON_HREF @"http://maps.gstatic.com/mapfiles/ms2/micons/flag.png"



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MTag ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MTag



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MTag *) tagWithFullName:(NSString *)name parentTag:(MTag *)parentTag inContext:(NSManagedObjectContext *)moContext {
    
    // Comprueba el nombre
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(!name || name.length==0) {
        return nil;
    }
    
    // Nombre completo basado en el nombre local y del padre
    NSString *fullName;
    
    if(parentTag!=nil) {
        fullName = [NSString stringWithFormat:@"%@%@%@", parentTag.name, TAG_NAME_SEPARATOR, name];
    } else {
        fullName = name;
    }
    
    // Retorna lo que encuentre con la información indicada
    return [MTag tagWithFullName:fullName inContext:moContext];
}

//---------------------------------------------------------------------------------------------------------------------
+ (MTag *) tagWithFullName:(NSString *)fullName inContext:(NSManagedObjectContext *)moContext {
    
    MTag *tag;
    
    // Busca el Tag requerido por si ya existe. En cuyo caso lo retorna
    tag = [MTag _searchTagWithFullName:fullName inContext:moContext];
    if(tag) {
        return tag;
    }
    
    // Como no existe, itera el path de categorias "padre" para crear la ultima
    MTag *parentTag = nil;
    NSMutableString *partialFullName = [NSMutableString string];
    NSArray *allShortTagNames = [fullName componentsSeparatedByString:TAG_NAME_SEPARATOR];
    for(NSString *tagShortName in allShortTagNames) {
        
        if(tagShortName==nil || tagShortName.length==0) continue;
        
        // Crea el nombre completo del tag
        if(partialFullName.length>0) {
            [partialFullName appendString:TAG_NAME_SEPARATOR];
        }
        [partialFullName appendString:tagShortName];
        
        // Si no existe ese nivel jerarquico de Tag lo crea
        tag = [MTag _searchTagWithFullName:partialFullName inContext:moContext];
        if(tag == nil) {
            tag = [MTag insertInManagedObjectContext:moContext];
            [tag _resetEntityWithFullName:partialFullName shortName:tagShortName parentTag:parentTag inContext:moContext];
        }
        
        // Establece la actual como padre de la siguiente
        parentTag = tag;
    }
    
    return tag;
}

//---------------------------------------------------------------------------------------------------------------------
+ (MTag *) _searchTagWithFullName:(NSString *)fullName inContext:(NSManagedObjectContext *)moContext {

    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MTag"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"name=%@", fullName];
    [request setPredicate:query];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MTag:_searchTagWithFullName - Error fetching tag in context [name=%@]", fullName];
    }

    // Retorna la primera ocurrencia
    if(array.count == 0) {
        return nil;
    } else {
        if(array.count>1) {
            [ErrorManagerService manageError:nil compID:@"Model" messageWithFormat:@"MTag:_searchTagWithFullName - Error, more than one result while fetching tag with FullName='%@'", fullName];
        }
        return array[0];
    }

}

//---------------------------------------------------------------------------------------------------------------------
+ (MTag *) tagFromIcon:(MIcon *)icon {
    
    // Se protege contra un filtro vacio
    if(!icon) {
        return nil;
    }
    
    MTag *tag = [MTag tagWithFullName:icon.name parentTag:nil inContext:icon.managedObjectContext];
    [tag updateIcon:icon];
    tag.isAutoTagValue = YES;
    return tag;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allTagsInContext:(NSManagedObjectContext *)moContext includeEmptyTags:(BOOL)emptyTags {
    
    NSDate *start = [NSDate date];
    NSLog(@"MTag - allTagsInContext - in");
    
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MTag"];
    
    // Se asigna una condicion de filtro
    if(!emptyTags) {
        NSPredicate *query = [NSPredicate predicateWithFormat:@"rPoints.@count>0"];
        [request setPredicate:query];
    }
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortAutoTagDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isAutoTag" ascending:TRUE];
    NSSortDescriptor *sortNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortAutoTagDescriptor,sortNameDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];

    //[request setRelationshipKeyPathsForPrefetching:@[@"descendants"]];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MTag:allTagsInContext - Error fetching all tags in context [emptyTags=%d]",emptyTags];
    }
    
    NSLog(@"MTag - allTagsInContext - out = %f",[start timeIntervalSinceNow]);
    
    return array;
}


//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) tagsForPointsTaggedWith:(NSSet *)tags InContext:(NSManagedObjectContext *)moContext {
    
    NSDate *start = [NSDate date];
    NSLog(@"MTag - tagsForPointsTaggedWith - in");
    
    // Se protege contra un filtro vacio
    if(tags.count==0) {
        return [MTag allTagsInContext:moContext includeEmptyTags:NO];
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
    
    // Se asigna el criterio de ordenacion ===> NO TIENE SENTIDO. SE PIERDE CON EL NSSET
    NSSortDescriptor *sortNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"point.name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortNameDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MPoint:pointsTaggedWith - Error fetching tagged points in context [tags=%@]",tags];
    }
    
    NSLog(@"MTag - tagsForPointsTaggedWith - 1 = %f",[start timeIntervalSinceNow]);
    
    // Del array debe filtrar aquellos cuya cuenta sea la del filtro
    NSMutableSet *allTags = [NSMutableSet set];
    for(NSDictionary *dict in array) {
        NSNumber *count2=[dict objectForKey:@"tagCount"];
        if(count2.intValue>=tags.count) {
            NSManagedObjectID *objID = [dict objectForKey:@"point"];
            MPoint *obj = (MPoint *)[moContext objectWithID:objID];
            [allTags unionSet:[obj.rTags valueForKey:@"tag"]];
        }
    }
    
    // Ordena el set
    array = [allTags sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"isAutoTag" ascending:TRUE], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE]]];
    
    // Pasa el set a Array de nuevo
    //    array = [allTags allObjects];
    
    NSLog(@"MTag - tagsForPointsTaggedWith - out = %f",[start timeIntervalSinceNow]);
    
    return array;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) tagPoint:(MPoint *)point {

    NSLog(@"tagPoint tag: %@ - point: %@", self.name, point.name);
    
    // ESTE PUNTO DEBE SER EL PRIMERO porque afecta a la informacion de los padres (incluido este elemento)
    // Y la borra de sus hijos por si ese punto ya estaba taggeado mas abajo
    for(MTag *childTag in self.descendants) {
        // @TODO: Debe haber una busqueda mas eficiente de la relacion para no activar todos los elementos actualizar dos veces
        //        algo como buscar las relaciones RPointTag donde aparezca el punto y que SELF este en mi rChildrenTag

        [childTag untagPoint:point];
    }

    // Obtine/crea la relacion con el punto y la actualiza como directa
    RPointTag *rpt = [self _relationWithPoint:point mustCreate:TRUE];
    rpt.isDirectValue = TRUE;
    
    //Añade una relacion indirecta con ese punto a sus padres
    for(MTag *parentTag in self.ancestors) {
        RPointTag *rpt2 = [parentTag _relationWithPoint:point mustCreate:TRUE];
        rpt2.isDirectValue = FALSE;
    }
    
    //***** GESTION DEL AUTO-TAG OTHERS ********************************************************
    /*
    if(self.otherPointsTag) {
        RPointTag *rpt2 = [self.otherPointsTag _relationWithPoint:point mustCreate:TRUE];
        rpt2.isDirectValue = FALSE;
    }
     */

    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) untagPoint:(MPoint *)point {

    NSLog(@"untagPoint tag: %@ - point: %@", self.name, point.name);
    
    // Obtine la relacion con el punto
    RPointTag *rpt = [self _relationWithPoint:point mustCreate:FALSE];
    
    // Comprueba que realmenta habia una relacion, y era directa, con el punto
    if(!rpt || !rpt.isDirectValue) return;
    
    // Borra la relacion directa con ese punto
    rpt.tag = nil;
    rpt.point = nil;
    [rpt.managedObjectContext deleteObject:rpt];
    
    // Borra la relacion indecta con ese punto en los padres
    for(MTag *parentTag in self.ancestors) {
        // @TODO: Debe haber una busqueda mas eficiente de la relacion para no activar todos los elementos
        //        algo como buscar las relaciones RPointTag donde aparezca el punto y que el tag tenga a SELF en su rChildrenTag
        RPointTag *rpt2 = [self _relationWithPoint:point mustCreate:FALSE];
        rpt2.tag = nil;
        rpt2.point = nil;
        [rpt2.managedObjectContext deleteObject:rpt];
    }
    
    
    
    //***** GESTION DEL AUTO-TAG OTHERS ********************************************************
    /*
    if(self.otherPointsTag) {
        RPointTag *rpt2 = [self.otherPointsTag _relationWithPoint:point mustCreate:FALSE];
        rpt2.tag = nil;
        rpt2.point = nil;
        [rpt2.managedObjectContext deleteObject:rpt];
    }
     */
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isAncestorOfTag:(MTag *)childTag {
    
    return [self.descendants containsObject:childTag];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithFullName:(NSString *)fullName shortName:(NSString *)shortName parentTag:(MTag *)parentTag inContext:(NSManagedObjectContext *)moContext {
    
    [super _resetEntityWithName:fullName icon:[MIcon iconForHref:DEFAULT_TAG_ICON_HREF inContext:moContext]];
    self.shortName = shortName;
    self.isAutoTagValue = NO;
    self.parent = parentTag;
    if(parentTag) {
        [self addAncestorsObject:parentTag];
        for(MTag *ancestor in parentTag.ancestors) {
            [self addAncestorsObject:ancestor];
        }
    }
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (RPointTag *) _relationWithPoint:(MPoint *)point mustCreate:(BOOL)mustCreate {
    
    for(RPointTag *rpt in self.rPoints) {
        if([rpt.point.objectID isEqual:point.objectID]) {
            return rpt;
        }
    }
    
    if(mustCreate) {
        RPointTag *rpt = [RPointTag insertInManagedObjectContext:point.managedObjectContext];
        rpt.tag = self;
        rpt.point = point;
        return rpt;
    } else {
        return nil;
    }
}





@end
