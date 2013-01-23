#import "MBaseEntity.h"
#import "GMTItem.h"
#import "GMPComparable.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface MBaseEntity () <GMPComparableLocal>


@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation MBaseEntity



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------



// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) wasSynchronizedValue {
    return ![self.gmID isEqualToString:GM_LOCAL_ID] && ![self.etag isEqualToString:GM_NO_SYNC_ETAG];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void) setName:(NSString *)name {

    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.name isEqual:name]) return;

    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:name];
    [self didChangeValueForKey:@"name"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setEtag:(NSString *)etag {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.etag isEqual:etag]) return;

    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"etag"];
    [self setPrimitiveEtag:etag];
    [self didChangeValueForKey:@"etag"];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void) setGmID:(NSString *)gmID {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.gmID isEqual:gmID]) return;
    
    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"gmID"];
    [self setPrimitiveGmID:gmID];
    [self didChangeValueForKey:@"gmID"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setUpdated_Date:(NSDate *)updated_Date {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.updated_Date isEqual:updated_Date]) return;
    
    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"updated_Date"];
    [self setPrimitiveUpdated_Date:updated_Date];
    [self didChangeValueForKey:@"updated_Date"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setPublished_Date:(NSDate *)published_Date {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.published_Date isEqual:published_Date]) return;
    
    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"published_Date"];
    [self setPrimitivePublished_Date:published_Date];
    [self didChangeValueForKey:@"published_Date"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setMarkedAsDeleted:(NSNumber *)markedAsDeleted {
    
    // Si el valor a establecer es igual al que tiene no hace nada
    if([self.markedAsDeleted isEqual:markedAsDeleted]) return;
    
    // Lo marca como modificado desde la ultima sincronizacion
    self.modifiedSinceLastSyncValue = true;
    
    // Establece el nuevo valor
    [self willChangeValueForKey:@"markedAsDeleted"];
    [self setPrimitiveMarkedAsDeleted:markedAsDeleted];
    [self didChangeValueForKey:@"markedAsDeleted"];
}




// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) resetEntityWithName:(NSString *)name {

    self.name = name;
    self.gmID = GM_LOCAL_ID;
    self.etag = GM_NO_SYNC_ETAG;
    self.markedAsDeletedValue = false;
    self.modifiedSinceLastSyncValue = true;
    self.published_Date = [NSDate date];
    self.updated_Date = self.published_Date;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) deleteEntity {
    self.markedAsDeletedValue = true;
    self.modifiedSinceLastSyncValue = true;
}


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------

@end
