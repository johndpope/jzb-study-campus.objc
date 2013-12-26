//
//  MTag.m
//

#define __MTag__IMPL__
#define __MTag__PROTECTED__
#define __MBase__SUBCLASSES__PROTECTED__
#define __MBaseSync__SUBCLASSES__PROTECTED__

#import "MTag.h"
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
    NSString *queryStr = @"SUBQUERY(self.points, $P, $P.markedAsDeleted=NO AND SUBQUERY($P.tags, $X, $X IN %@).@count>=%d).@count>0";
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

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allTagsInContext:(NSManagedObjectContext *)moContext includeEmptyTags:(BOOL)emptyTags {

    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MTag"];
    
    // Se asigna una condicion de filtro
    if(!emptyTags) {
        NSPredicate *query = [NSPredicate predicateWithFormat:@"points.@count>0"];
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




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------




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
