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
#import "BenchMark.h"




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
+ (NSString *) _myEntityName {
    return @"MTag";
}

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
    
    // Divide el nombre en tramos para normalizarlo
    NSArray *allShortTagNames = [fullName componentsSeparatedByString:TAG_NAME_SEPARATOR];
    NSMutableString *cleanFullName = [NSMutableString string];
    for(NSString *tagShortName in allShortTagNames) {

        NSString *trimmedShortName = [tagShortName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(trimmedShortName==nil || trimmedShortName.length==0) continue;
        
        // Crea el nombre completo del tag
        if(cleanFullName.length>0) {
            [cleanFullName appendFormat:@" %@ ",TAG_NAME_SEPARATOR];
        }
        [cleanFullName appendString:trimmedShortName];
    }

    // Comprueba el nombre
    if(cleanFullName.length==0) {
        return nil;
    }
    
    // Busca el Tag requerido por si ya existe. En cuyo caso lo retorna
    tag = [MTag _searchTagWithFullName:cleanFullName inContext:moContext];
    if(tag) {
        return tag;
    }
    
    // Como no existe, itera el path de categorias "padre" para crear la ultima
    MTag *parentTag = nil;
    NSMutableString *partialFullName = [NSMutableString string];
    for(NSString *tagShortName in allShortTagNames) {
        
        NSString *trimmedShortName = [tagShortName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(trimmedShortName==nil || trimmedShortName.length==0) continue;
        
        // Crea el nombre completo del tag
        if(partialFullName.length>0) {
            [partialFullName appendFormat:@" %@ ",TAG_NAME_SEPARATOR];
        }
        [partialFullName appendString:trimmedShortName];
        
        // Si no existe ese nivel jerarquico de Tag lo crea
        tag = [MTag _searchTagWithFullName:partialFullName inContext:moContext];
        if(tag == nil) {
            tag = [MTag insertInManagedObjectContext:moContext];
            [tag _resetEntityWithFullName:partialFullName shortName:trimmedShortName parentTag:parentTag inContext:moContext];
        }
        
        // Establece la actual como padre de la siguiente
        parentTag = tag;
    }
    
    return tag;
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
+ (NSMutableArray *) sortDescriptorsByOrder:(NSArray *)ordering {

    NSMutableArray *sortDescriptors = [super sortDescriptorsByOrder:ordering];

    // Añade el criterio de poner los AutoTags los ultimos
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isAutoTag" ascending:FALSE];
    [sortDescriptors addObject:sortDescriptor];
    
    // Retorna el conjunto
    return sortDescriptors;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSPredicate *) _predicateAllInContextIncludeMarkedAsDeleted:(BOOL)withDeleted {
    if(!withDeleted) {
        return [NSPredicate predicateWithFormat:@"rPoints.@count>0"];
    } else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSPredicate *) _predicateAllWithName:(NSString *)name {
    return [NSPredicate predicateWithFormat:@"name=%@ AND rPoints.@count>0", name];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSPredicate *) _predicateAllWithNameLike:(NSString *)name {
    return [NSPredicate predicateWithFormat:@"isAutoTag==NO AND name CONTAINS[cd] %@ AND rPoints.@count>0", name];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSPredicate *) _predicateAllWithIcon:(MIcon *)icon {
    return  [NSPredicate predicateWithFormat:@"icon=%@ AND rPoints.@count>0", icon];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) tagPoint:(MPoint *)point {

    NSLog(@"tagPoint: tagName: '%@' - pointName: '%@'", self.name, point.name);
    
    // ESTE PUNTO DEBE SER EL PRIMERO porque afecta a la informacion de los padres (incluido este elemento)
    // Y la borra de sus hijos por si ese punto ya estaba taggeado mas abajo
    for(MTag *childTag in self.descendants) {
        // @TODO: Debe haber una busqueda mas eficiente de la relacion para no activar todos los elementos actualizar dos veces
        //        algo como buscar las relaciones RPointTag donde aparezca el punto y que SELF este en mi rChildrenTag

        [childTag untagPoint:point];
    }

    // Obtine/crea la relacion con el punto y la actualiza como directa
    RPointTag *rpt = [self _getRelationWithPoint:point mustCreate:TRUE];
    [rpt updateIsDirect:TRUE];
    
    //Añade una relacion indirecta con ese punto a sus padres
    for(MTag *parentTag in self.ancestors) {
        RPointTag *rpt2 = [parentTag _getRelationWithPoint:point mustCreate:TRUE];
        [rpt2 updateIsDirect:FALSE];
    }
    
    //***** GESTION DEL AUTO-TAG OTHERS ********************************************************
    /*
    if(self.otherPointsTag) {
        RPointTag *rpt2 = [self.otherPointsTag _getRelationWithPoint:point mustCreate:TRUE];
        rpt2.isDirectValue = FALSE;
    }
     */

    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) untagPoint:(MPoint *)point {

    NSLog(@"untagPoint tag: %@ - point: %@", self.name, point.name);
    
    // Obtine la relacion con el punto
    RPointTag *rpt = [self _getRelationWithPoint:point mustCreate:FALSE];
    
    // Comprueba que realmenta habia una relacion, y era directa, con el punto
    if(!rpt || !rpt.isDirectValue) return;
    
    // Borra la relacion directa con ese punto
    [rpt deleteEntity];
    
    // Borra la relacion indecta con ese punto en los padres
    for(MTag *parentTag in self.ancestors) {
        // @TODO: Debe haber una busqueda mas eficiente de la relacion para no activar todos los elementos
        //        algo como buscar las relaciones RPointTag donde aparezca el punto y que el tag tenga a SELF en su rChildrenTag
        RPointTag *rpt2 = [self _getRelationWithPoint:point mustCreate:FALSE];
        [rpt2 deleteEntity];
    }
    
    
    
    //***** GESTION DEL AUTO-TAG OTHERS ********************************************************
    /*
    if(self.otherPointsTag) {
        RPointTag *rpt2 = [self.otherPointsTag _getRelationWithPoint:point mustCreate:FALSE];
        rpt2.tag = nil;
        rpt2.point = nil;
        [rpt2.managedObjectContext deleteObject:rpt];
    }
     */
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isDescendantOfTag:(MTag *)parentTag {

    return [self.ancestors containsObject:parentTag];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isAncestorOfTag:(MTag *)childTag {
    
    return [self.descendants containsObject:childTag];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isRelativeOfTag:(MTag *)tag {
    return self.tagTreeIDValue==tag.tagTreeIDValue;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isRelativeOfAnyTag:(id<NSFastEnumeration>)tags {
    
    for(MTag *tag in tags){
        if([self isRelativeOfTag:tag]) return TRUE;
    }
    return FALSE;
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
        self.tagTreeIDValue = parentTag.tagTreeIDValue;
    } else {
        self.tagTreeIDValue = [MBase _generateInternalID];
    }
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (RPointTag *) _getRelationWithPoint:(MPoint *)point mustCreate:(BOOL)mustCreate {
    
    for(RPointTag *rpt in self.rPoints) {
        if([rpt.point.objectID isEqual:point.objectID]) {
            return rpt;
        }
    }
    
    if(mustCreate) {
        RPointTag *rpt = [RPointTag relatePoint:point withTag:self isDirect:FALSE];
        return rpt;
    } else {
        return nil;
    }
}





@end
