//
//  MBase.m
//

#define __MBase__IMPL__
#define __MBase__PROTECTED__

#import "MBase.h"
#import "MIcon.h"
#import "BenchMark.h"
#import "ErrorManagerService.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define M_DATE_FORMATTER  @"yyyy-MM-dd'T'HH:mm:ss'.'SSSS'Z'"

NSString *const MBaseOrderNone              = @"MBaseOrderNone";
NSString *const MBaseOrderByNameAsc         = @"MBaseOrderByNameAsc";
NSString *const MBaseOrderByNameDes         = @"MBaseOrderByNameDes";
NSString *const MBaseOrderByTCreationAsc    = @"MBaseOrderByTCreationAsc";
NSString *const MBaseOrderByTCreationDes    = @"MBaseOrderByTCreationAsc";
NSString *const MBaseOrderByTUpdateAsc      = @"MBaseOrderByTCreationAsc";
NSString *const MBaseOrderByTUpdateDes      = @"MBaseOrderByTUpdateDes";
NSString *const MBaseOrderByIconAsc         = @"MBaseOrderByIconAsc";
NSString *const MBaseOrderByIconDes         = @"MBaseOrderByIconDes";



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MBase ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MBase



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) stringFromDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:M_DATE_FORMATTER];
    // The Z at the end of your string represents Zulu which is UTC
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSMutableArray *) sortDescriptorsByOrder:(NSArray *)orderArray fieldName:(NSString *)fieldName {
    
    // Comprueba si no habia ningun criterio de busqueda
    if(orderArray.count == 0) return nil;
    
    // Crea el criterio de ordenacion
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    
    // Añade los criterios indicados
    for(NSString *order in orderArray) {
        
        if((order == MBaseOrderByNameAsc) || (order == MBaseOrderByNameDes)) {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[NSString stringWithFormat:@"%@name", fieldName] ascending:(order == MBaseOrderByNameAsc)];
            [sortDescriptors addObject:sortDescriptor];
        } else if((order == MBaseOrderByTCreationAsc) || (order == MBaseOrderByTCreationDes)) {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[NSString stringWithFormat:@"%@tCreation", fieldName] ascending:(order == MBaseOrderByTCreationAsc)];
            [sortDescriptors addObject:sortDescriptor];
        } else if((order == MBaseOrderByTUpdateAsc) || (order == MBaseOrderByTUpdateAsc)) {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[NSString stringWithFormat:@"%@tUpdate", fieldName] ascending:(order == MBaseOrderByTUpdateAsc)];
            [sortDescriptors addObject:sortDescriptor];
        } else if((order == MBaseOrderByIconAsc) || (order == MBaseOrderByIconAsc)) {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[NSString stringWithFormat:@"%@icon.name", fieldName] ascending:(order == MBaseOrderByIconAsc)];
            [sortDescriptors addObject:sortDescriptor];
        }
    }
    
    // Retorna el resultado
    return  sortDescriptors;}

//---------------------------------------------------------------------------------------------------------------------
+ (NSMutableArray *) sortDescriptorsByOrder:(NSArray *)orderArray {

    return [self sortDescriptorsByOrder:orderArray fieldName:@""];

}


//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) _myEntityName {
    @throw [NSException exceptionWithName:@"AbstractMethodException" reason:@"Abstract class method '_myEntityName' must be implemented by subclass" userInfo:nil];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) _allWithPredicate:(NSPredicate *)predicate  sortOrder:(NSArray *)sortOrder inContext:(NSManagedObjectContext *)moContext {
    
    BenchMark *benchMark = [BenchMark benchMarkLogging:@"Mbase:allWithPredicate"];
    
    // Se protege contra un filtro vacio
    if(!predicate) {
        [benchMark logTotalTime:@"Returning nil because name was empty"];
        return nil;
    }
    
    
    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self _myEntityName]];
    
    // Se asigna una condicion de filtro
    if(predicate) {
        [request setPredicate:predicate];
    }
    
    // Se asigna el criterio de ordenacion
    NSArray *sortDescriptors = [self sortDescriptorsByOrder:sortOrder];
    [request setSortDescriptors:sortDescriptors];
    
    // Se ejecuta y retorna el resultado
    NSError *localError = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&localError];
    if(array==nil) {
        [ErrorManagerService manageError:localError compID:@"Model" messageWithFormat:@"Mbase:_allItemsWithPredicate - Error fetching items in context [predicate=%@]",predicate];
    }
    
    [benchMark logTotalTime:@"All items (with predicate) in context has been fetched (count=%ld)",array.count];
    
    return array;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSPredicate *) _predicateAllInContextIncludeMarkedAsDeleted:(BOOL)withDeleted {
    if(!withDeleted) {
        return [NSPredicate predicateWithFormat:@"markedAsDeleted=NO"];
    } else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSPredicate *) _predicateAllWithName:(NSString *)name {
    return [NSPredicate predicateWithFormat:@"markedAsDeleted=NO AND name=%@", name];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSPredicate *) _predicateAllWithNameLike:(NSString *)name {
    return [NSPredicate predicateWithFormat:@"markedAsDeleted=NO AND name CONTAINS[cd] %@", name];
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSPredicate *) _predicateAllWithIcon:(MIcon *)icon {
    return  [NSPredicate predicateWithFormat:@"markedAsDeleted=NO AND icon=%@", icon];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allInContext:(NSManagedObjectContext *)moContext sortOrder:(NSArray *)sortOrder includeMarkedAsDeleted:(BOOL)withDeleted {

    DDLogVerbose(@"Starting: MBase:allInContext ----------------------------------------");
    NSPredicate *query = [self _predicateAllInContextIncludeMarkedAsDeleted:withDeleted];
    return [self _allWithPredicate:query sortOrder:sortOrder inContext:moContext];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allWithName:(NSString *)name  sortOrder:(NSArray *)sortOrder inContext:(NSManagedObjectContext *)moContext {
    
    DDLogVerbose(@"Starting: MBase:allWithName ----------------------------------------");
    
    // Se protege contra un filtro vacio
    if(!name) {
        DDLogVerbose(@"Returning nil because name was empty");
        return nil;
    }
    NSPredicate *query = [self _predicateAllWithName:name];
    return [self _allWithPredicate:query sortOrder:sortOrder inContext:moContext];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allWithNameLike:(NSString *)name sortOrder:(NSArray *)sortOrder maxNumItems:(NSUInteger)maxNumItems inContext:(NSManagedObjectContext *)moContext {
    
    DDLogVerbose(@"Starting: MBase:allWithNameLike ----------------------------------------");
    
    // Se protege contra un filtro vacio
    if(!name) {
        DDLogVerbose(@"Returning nil because name was empty");
        return nil;
    }
    NSPredicate *query = [self _predicateAllWithNameLike:name];
    return [self _allWithPredicate:query sortOrder:sortOrder inContext:moContext];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) allWithIcon:(MIcon *)icon sortOrder:(NSArray *)sortOrder {

    
    DDLogVerbose(@"Starting: MBase:allWithIcon ----------------------------------------");

    // Se protege contra un filtro vacio
    if(!icon) {
        DDLogVerbose(@"Returning nil because icon was empty");
        return nil;
    }
    NSPredicate *query = [self _predicateAllWithIcon:icon];
    return [self _allWithPredicate:query sortOrder:sortOrder inContext:icon.managedObjectContext];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) deleteEntity {
    @throw [NSException exceptionWithName:@"AbstractMethodException" reason:@"Abstract method 'deleteEntity' must be implemented by subclass" userInfo:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateName:(NSString *)value {
    
    if((value || self.name) && ![self.name isEqualToString:value]) {
        self.name = value;
        return TRUE;
    }
    return FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateIcon:(MIcon *)icon {
    
    if((icon || self.icon) && ![self.icon isEqual:icon]) {
        self.icon = icon;
        return TRUE;
    }
    return FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsModified {
    @throw [NSException exceptionWithName:@"AbstractMethodException" reason:@"Abstract method 'markAsModified' must be implemented by subclass" userInfo:nil];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
// ---------------------------------------------------------------------------------------------------------------------
+ (int64_t) _generateInternalID {
    
    static int64_t s_idCounter = 0;
    
    @synchronized([MBase class]) {
        // La primera vez comienza en un numero aleatorio
        if(s_idCounter==0) {
            srand((unsigned)time(0L));
            s_idCounter = ((int64_t)rand())<<48;
        }
        
        // Incrementa la cuenta
        s_idCounter = 0x7FFF000000000000  & ( s_idCounter + 0x0001000000000000);
        
        // El identificador es una mezcla de numero aleatorio y la hora actual
        int64_t newID = s_idCounter | (((int64_t)time(0L)) & 0x0000FFFFFFFFFFFF);
        
        return newID;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name icon:(MIcon *)icon {
    
    NSDate *now = [NSDate date];
    
    self.tCreation = now;
    self.tUpdate = now;
    
    self.name = [name copy];
    [self updateIcon:icon];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _deleteEntity {
    self.name = nil;
    self.icon = nil;
    [self.managedObjectContext deleteObject:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _markAsModified {
    
    self.tUpdate = [NSDate date];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
