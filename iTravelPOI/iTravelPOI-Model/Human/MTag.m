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
#import "RTagSubtag.h"
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
+ (MTag *) tagByName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {
    
    
    // Se protege contra un nombre vacio
    if(!name) {
        return nil;
    }
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MTag"];
    
    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"name=%@", name];
    [request setPredicate:query];
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MTag:tagByName - Error fetching tag in context [name=%@]", name];
    }

    
    // Si lo ha encontrado lo retorna, sino lo crea
    if(!array || array.count==0) {
        MTag *tag = [MTag insertInManagedObjectContext:moContext];
        [tag _resetEntityWithName:name inContext:moContext];
        return tag;
    } else {
        NSAssert(array.count==1, @"Shouldn't be more than one tag with the same name = '%@'", name);
        return array[0];
    }

}

//---------------------------------------------------------------------------------------------------------------------
+ (MTag *) tagFromIcon:(MIcon *)icon {
    
    // Se protege contra un filtro vacio
    if(!icon) {
        return nil;
    }
    
    MTag *tag = [MTag tagByName:icon.name inContext:icon.managedObjectContext];
    [tag updateIcon:icon];
    tag.isAutoTagValue = YES;
    return tag;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allTagsInContext:(NSManagedObjectContext *)moContext includeEmptyTags:(BOOL)emptyTags {
    
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
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MTag:allTagsInContext - Error fetching all tags in context [emptyTags=%d]",emptyTags];
    }
    return array;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) tagsForPointsTaggedWith:(NSSet *)tags InContext:(NSManagedObjectContext *)moContext {
 
    // Se protege contra un filtro vacio
    if(tags.count==0) {
        return [MTag allTagsInContext:moContext includeEmptyTags:NO];
    }
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MTag"];
    
    // Se asigna una condicion de filtro
    //    NSString *queryStr = @"markedAsDeleted=NO AND SUBQUERY(self.tags, $X, $X IN %@).@count>0";
    //    NSPredicate *query = [NSPredicate predicateWithFormat:queryStr, tags];
    NSString *queryStr = @"SUBQUERY(self.rPoints.point, $P, $P.markedAsDeleted=NO AND SUBQUERY($P.rTags.tag, $X, $X IN %@).@count>=%d).@count>0";
    NSPredicate *query = [NSPredicate predicateWithFormat:queryStr, tags, tags.count];
    [request setPredicate:query];
    
    // Se asigna el criterio de ordenacion
    NSSortDescriptor *sortAutoTagDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isAutoTag" ascending:TRUE];
    NSSortDescriptor *sortNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortAutoTagDescriptor,sortNameDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"MTag:tagsForPointsTaggedWith - Error fetching tags for points tagged in context [tags=%@]",tags];
    }
    return array;
}






//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (RPointTag *) _relationWithPoint:(MPoint *)point mustCreate:(BOOL)mustCreate isDirect:(BOOL)isDirect {
    
    for(RPointTag *rpt in self.rPoints) {
        if([rpt.point.objectID isEqual:point.objectID]) {
            return rpt;
        }
    }
    
    if(mustCreate) {
        RPointTag *rpt = [RPointTag insertInManagedObjectContext:point.managedObjectContext];
        rpt.tag = self;
        rpt.point = point;
        rpt.isDirectValue = isDirect;
        return rpt;
    } else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (RTagSubtag *) _relationWithSubtag:(MTag *)childTag mustCreate:(BOOL)mustCreate isDirect:(BOOL)isDirect {
    
    for(RTagSubtag *rtst in self.rChildrenTags) {
        if([rtst.childTag.objectID isEqual:childTag.objectID]) {
            return rtst;
        }
    }
    
    if(mustCreate) {
        RTagSubtag *rtst = [RTagSubtag insertInManagedObjectContext:childTag.managedObjectContext];
        rtst.parentTag = self;
        rtst.childTag = childTag;
        rtst.isDirectValue = isDirect;
        return rtst;
    } else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) _allParentTags {
    
    NSMutableSet *allParents = [NSMutableSet set];
    for(RTagSubtag *rtag in self.rParentTags) {
        [allParents addObject:rtag.parentTag];
        [allParents addObjectsFromArray:[[rtag.parentTag _allParentTags] allObjects]];
    }
    return allParents;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) _allChildrenTags {
    
    NSMutableSet *allChildren = [NSMutableSet set];
    for(RTagSubtag *rtag in self.rChildrenTags) {
        [allChildren addObject:rtag.childTag];
        [allChildren addObjectsFromArray:[[rtag.childTag _allChildrenTags] allObjects]];
    }
    return allChildren;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) tagPoint:(MPoint *)point {

    NSLog(@"tagPoint tag: %@ - point: %@", self.name, point.name);
    [self _tagPoint:point direct:TRUE];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _tagPoint:(MPoint *)point direct:(BOOL)direct {
    
    // Obtine la relacion con el punto
    RPointTag *rpt = [self _relationWithPoint:point mustCreate:TRUE isDirect:TRUE];

    // Actualiza el tipo de relacion
    rpt.isDirectValue = direct;
    
    // Si la relacion es directa, añade una relacion indirecta con el punto a sus padres y la borra de sus hijos
    if(direct) {
        // Primero el borrado porque sino quedaria elimado a adicion previa
        for(MTag *childTag in [self _allChildrenTags]){
            [childTag untagPoint:point];
        }
        for(MTag *parentTag in [self _allParentTags]) {
            [self _relationWithPoint:point mustCreate:TRUE isDirect:FALSE];
            [parentTag _tagPoint:point direct:FALSE];
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) untagPoint:(MPoint *)point {

    NSLog(@"untagPoint tag: %@ - point: %@", self.name, point.name);
    [self _untagPoint:point forceDelete:FALSE];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _untagPoint:(MPoint *)point forceDelete:(BOOL)forceDelete {
    
    // Obtine la relacion con el punto
    RPointTag *rpt = [self _relationWithPoint:point mustCreate:FALSE];
    
    // Comprueba que realmenta habia una relacion con el punto
    // El borrado dependera de si se esta forzando o si la relacion es directa
    if(!rpt || !(rpt.isDirectValue || forceDelete)) return;
    
    // Borra la relacion directa con ese punto
    [self removeRPointsObject:rpt];
    [rpt.managedObjectContext deleteObject:rpt];
    
    // Borra la relacion indecta con ese punto en los padres
    for(MTag *parentTag in [self _allParentTags]) {
        [parentTag _untagPoint:point forceDelete:TRUE];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) tagChildTag:(MTag *)childTag {
    NSLog(@"tagChildTag tag: %@ - childTag: %@", self.name, childTag.name);
    [self _tagChildTag:childTag direct:TRUE];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _tagChildTag:(MTag *)childTag direct:(BOOL)direct {
    
    // @TODO: Comprobar que funciona bien taggear un elemento que era un "nieto" (movimiento en el arbol)

    // Comprueba que no se ha creado un ciclo (taggear a alguien en la cadena de tag padres)
    NSSet *allParentTags = [self _allParentTags];
    if([allParentTags containsObject:childTag]) {
        NSAssert(TRUE, @"Child tag (%@) cannot be applied to parent/ancestor tag (%@)", self.name, childTag.name);
        return;
    }
    
    // Obtine la relacion con el subtag
    RTagSubtag *rtst = [self _relationWithSubtag:childTag mustCreate:TRUE];
    
    // Actualiza el tipo de relacion
    rtst.isDirectValue = direct;

    // Si la relacion es directa, añade una relacion indirecta con el subtag a sus padres y la borra de sus hijos
    // Adicionalmente, añade una relacion indirecta con los puntos del nuevo subtag (a el y a sus padres)
    if(direct) {
        // Primero el borrado porque sino quedaria elimado a adicion previa
        for(MTag *childTag in [self _allChildrenTags]){
            [childTag untagChildTag:childTag];
        }
        for(MTag *parentTag in [self _allParentTags]) {
            [parentTag _tagChildTag:childTag direct:FALSE];
            for (RPointTag *rpt in childTag.rPoints) {
                [parentTag _tagPoint:rpt.point direct:FALSE];
            }
        }
        for (RPointTag *rpt in childTag.rPoints) {
            [self _tagPoint:rpt.point direct:FALSE];
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) untagChildTag:(MTag *)childTag {
    NSLog(@"untagChildTag tag: %@ - childTag: %@", self.name, childTag.name);
    [self _untagChildTag:childTag forceDelete:FALSE];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _untagChildTag:(MTag *)childTag  forceDelete:(BOOL)forceDelete {

    // Obtine la relacion con el subtag
    RTagSubtag *rtst = [self _relationWithSubtag:childTag mustCreate:FALSE];
    
    // Comprueba que realmenta habia una relacion con el tag
    // El borrado dependera de si se esta forzando o si la relacion es directa
    if(!rtst || !(rtst.isDirectValue || forceDelete)) return;
    
    
    // Borra la relacion directa con ese subtag
    [self removeRChildrenTagsObject:rtst];
    [rtst.managedObjectContext deleteObject:rtst];
    
    // Borra la relacion indecta con ese punto en los padres
    for(MTag *parentTag in [self _allParentTags]) {
        [parentTag _untagChildTag:childTag forceDelete:TRUE];
    }

}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) hasParentTags {
    return self.rParentTags.count>0;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) anyIsParentTag:(NSSet *)tags {
    
    for(RTagSubtag *rtst in self.rParentTags) {
        if([tags containsObject:rtst.parentTag])
            return TRUE;
    }
    return FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isDirectParentOfTag:(MTag *)childTag {

    for(RTagSubtag *rtst in self.rChildrenTags) {
        if(rtst.isDirectValue && [rtst.childTag.objectID isEqual:childTag.objectID]) {
            return TRUE;
        }
    }
    return FALSE;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {
    
    [super _resetEntityWithName:name icon:[MIcon iconForHref:DEFAULT_TAG_ICON_HREF inContext:moContext]];
    self.isAutoTagValue = NO;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
