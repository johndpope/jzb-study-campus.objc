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
    for(MTag *childTag in [self _allChildrenTags]) {
        // @TODO: Debe haber una busqueda mas eficiente de la relacion para no activar todos los elementos actualizar dos veces
        //        algo como buscar las relaciones RPointTag donde aparezca el punto y que SELF este en mi rChildrenTag

        [childTag untagPoint:point];
    }

    // Obtine/crea la relacion con el punto y la actualiza como directa
    RPointTag *rpt = [self _relationWithPoint:point mustCreate:TRUE];
    rpt.isDirectValue = TRUE;
    
    //Añade una relacion indirecta con ese punto a sus padres
    for(MTag *parentTag in [self _allParentTags]) {
        RPointTag *rpt2 = [parentTag _relationWithPoint:point mustCreate:TRUE];
        rpt2.isDirectValue = FALSE;
    }
    
    //***** GESTION DEL AUTO-TAG OTHERS ********************************************************
    if(self.otherPointsTag) {
        RPointTag *rpt2 = [self.otherPointsTag _relationWithPoint:point mustCreate:TRUE];
        rpt2.isDirectValue = FALSE;
    }

    
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
    for(MTag *parentTag in [self _allParentTags]) {
        // @TODO: Debe haber una busqueda mas eficiente de la relacion para no activar todos los elementos
        //        algo como buscar las relaciones RPointTag donde aparezca el punto y que el tag tenga a SELF en su rChildrenTag
        RPointTag *rpt2 = [self _relationWithPoint:point mustCreate:FALSE];
        rpt2.tag = nil;
        rpt2.point = nil;
        [rpt2.managedObjectContext deleteObject:rpt];
    }
    
    
    //***** GESTION DEL AUTO-TAG OTHERS ********************************************************
    if(self.otherPointsTag) {
        RPointTag *rpt2 = [self.otherPointsTag _relationWithPoint:point mustCreate:FALSE];
        rpt2.tag = nil;
        rpt2.point = nil;
        [rpt2.managedObjectContext deleteObject:rpt];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) tagChildTag:(MTag *)childTag {
    
    NSLog(@"tagChildTag tag: %@ - childTag: %@", self.name, childTag.name);
    
    // @TODO: Comprobar que funciona bien taggear un elemento que era un "nieto" (movimiento en el arbol)
    
    // Comprueba que no se ha creado un ciclo (taggear a alguien en la cadena de tag padres)
    NSSet *allParentTags = [self _allParentTags];
    if([allParentTags containsObject:childTag]) {
        NSAssert(TRUE, @"Child tag (%@) cannot be applied to parent/ancestor tag (%@)", self.name, childTag.name);
        return;
    }


    // Tampoco esta permitido taggearse a si mismo
    if([self.objectID isEqual:childTag.objectID]) {
        NSAssert(TRUE, @"Tag (%@) cannot be applied to itself (%@)", self.name, childTag.name);
        return;
    }
    
    // ESTE PUNTO DEBE SER EL PRIMERO porque afecta a la informacion de los padres (incluido este elemento)
    // Borra la relacion de sus hijos con este tag por si ese punto ya estaba taggeado mas abajo
    for(MTag *childTag2 in [self _allChildrenTags]){
        [childTag2 untagChildTag:childTag];
    }

    
    // Obtine la relacion con el subtag y la actualiza como directa
    RTagSubtag *rtst = [self _relationWithSubtag:childTag mustCreate:TRUE];
    rtst.isDirectValue = TRUE;
    

    // Añade una relacion indirecta con los puntos del nuevo subtag
    for (RPointTag *rpt in childTag.rPoints) {
        RPointTag *rpt2 = [self _relationWithPoint:rpt.point mustCreate:TRUE];
        rpt2.isDirectValue = FALSE;
    }
    
    // Añade una relacion indirecta con el subtag a sus padres
    for(MTag *parentTag in allParentTags) {
        
        RTagSubtag *rtst2 = [parentTag _relationWithSubtag:childTag mustCreate:TRUE];
        rtst2.isDirectValue = FALSE;
        
        // Ademas, tambien añade una relacion indirecta con los puntos del nuevo subtag
        for (RPointTag *rpt in childTag.rPoints) {
            RPointTag *rpt2 = [parentTag _relationWithPoint:rpt.point mustCreate:TRUE];
            rpt2.isDirectValue = FALSE;
        }
    }
    
    //***** GESTION DEL AUTO-TAG OTHERS ********************************************************
    if(!self.otherPointsTag && self.rPoints.count>0) {
        
        [self _createOtherPointsTag];
        for(RPointTag *rpt in self.rPoints) {
            if(rpt.isDirectValue) {
                RPointTag *rpt2 = [self.otherPointsTag _relationWithPoint:rpt.point mustCreate:TRUE];
                rpt2.isDirectValue = FALSE;
            }
        }
    }

}


//---------------------------------------------------------------------------------------------------------------------
- (void) untagChildTag:(MTag *)childTag {
    
    NSLog(@"untagChildTag tag: %@ - childTag: %@", self.name, childTag.name);
    
    // Obtine la relacion con el subtag
    RTagSubtag *rtst = [self _relationWithSubtag:childTag mustCreate:FALSE];
    
    // Comprueba que realmenta habia una relacion, y era directa, con el subtag
    if(!rtst || !rtst.isDirectValue) return;
    
    
    // Borra la relacion directa con ese subtag
    rtst.parentTag = nil;
    rtst.childTag = nil;
    [rtst.managedObjectContext deleteObject:rtst];
    
    // Borra la relacion indecta con ese subtag en los padres
    for(MTag *parentTag in [self _allParentTags]) {
        RTagSubtag *rtst2 = [parentTag _relationWithSubtag:childTag mustCreate:FALSE];
        rtst2.parentTag = nil;
        rtst2.childTag = nil;
        [rtst2.managedObjectContext deleteObject:rtst];
    }
    
    
    //***** GESTION DEL AUTO-TAG OTHERS ********************************************************
    if(self.rChildrenTags.count==0 && self.otherPointsTag) {
        
        [self _deleteOtherPointsTag];
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
- (BOOL) isAncestorOfTag:(MTag *)childTag {
    
    for(RTagSubtag *rtst in self.rChildrenTags) {
        if([rtst.childTag.objectID isEqual:childTag.objectID]) {
            return TRUE;
        }
    }
    
    //***** GESTION DEL AUTO-TAG OTHERS ********************************************************
    if([childTag.objectID isEqual:self.otherPointsTag.objectID]) {
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
    
    //***** GESTION DEL AUTO-TAG OTHERS ********************************************************
    if([childTag.objectID isEqual:self.otherPointsTag.objectID]) {
        return TRUE;
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

//---------------------------------------------------------------------------------------------------------------------
- (RTagSubtag *) _relationWithSubtag:(MTag *)childTag mustCreate:(BOOL)mustCreate {
    
    for(RTagSubtag *rtst in self.rChildrenTags) {
        if([rtst.childTag.objectID isEqual:childTag.objectID]) {
            return rtst;
        }
    }
    
    if(mustCreate) {
        RTagSubtag *rtst = [RTagSubtag insertInManagedObjectContext:childTag.managedObjectContext];
        rtst.parentTag = self;
        rtst.childTag = childTag;
        return rtst;
    } else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _createOtherPointsTag {
    
    MTag *otherPointsTag = [MTag tagByName:[NSString stringWithFormat:@"#%@#Others", self.name] inContext:self.managedObjectContext];
    otherPointsTag.shortName = @"Others";
    otherPointsTag.isAutoTagValue = TRUE;
    self.otherPointsTag = otherPointsTag;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _deleteOtherPointsTag {
    
    [self.otherPointsTag.managedObjectContext deleteObject:self.otherPointsTag];
    self.otherPointsTag = nil;
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



@end
