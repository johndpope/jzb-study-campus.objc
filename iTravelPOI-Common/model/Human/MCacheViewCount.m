#import "MCacheViewCount.h"
#import "MMap.h"
#import "MCategory.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface MCacheViewCount ()

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation MCacheViewCount


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MCacheViewCount *) cacheViewCountForMap:(MMap *)map category:(MCategory *)category inContext:(NSManagedObjectContext *)moContext {

    MCacheViewCount *cacheMC = [MCacheViewCount insertInManagedObjectContext:moContext];
    cacheMC.map = map;
    cacheMC.category = category;

    return cacheMC;
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) resetViewCount {
    self.viewCount = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) updateViewCount {

    NSError *err = nil;

    // Crea la peticion de busqueda
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MPoint"];

    // Se asigna una condicion de filtro
    NSPredicate *query = [NSPredicate predicateWithFormat:@"(markedAsDeleted=NO) AND (map=%@) AND (category.iconHREF BEGINSWITH %@)", self.map, self.category.iconHREF];
    [request setPredicate:query];

    // Se ejecuta y retorna el resultado
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];

    // Actualiza la cuenta
    self.viewCount = [NSString stringWithFormat:@"%03ld", count];
    NSLog(@"UPDATED viewCount map=%@ - cat=%@ -> %@", self.map.name, self.category.name, self.viewCount);

    return self.viewCount;
}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------


@end
