//
//  MBaseSync.m
//

#define __MBaseSync__IMPL__
#define __MBaseSync__PROTECTED__
#define __MBase__SUBCLASSES__PROTECTED__

#import "MBaseSync.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define LOCAL_MAP_ID    @"Local-Map-ID"
#define NO_SYNC_ETAG    @"No-Sycn-ETag"




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MBaseSync ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MBaseSync



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateName:(NSString *)value {
    
    BOOL result = [super updateName:value];
    if(result) [self markAsModified];
    return result;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateIcon:(MIcon *)icon {
    
    BOOL result = [super updateIcon:icon];
    if(result) [self markAsModified];
    return result;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateGID:(NSString *)gID andETag:(NSString *)etag {

    // Cogemos siempre los valores. El uso fuera de una sincronizacion
    self.gID = gID;
    self.etag = etag;
    [self markAsModified];
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsModified {
    [super markAsModified];
    self.modifiedSinceLastSyncValue = TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted:(BOOL) value {

    if(self.markedAsDeletedValue != value) {
        [self markAsModified];
        self.markedAsDeletedValue = value;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsSynchronized {
    self.modifiedSinceLastSyncValue = FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) wasSynchronizedValue {
    
    BOOL value = ![self.etag isEqualToString:NO_SYNC_ETAG];
    return value;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) deleteEntity {
    
    self.etag = nil;
    self.gID = nil;
    self.markedAsDeletedValue = TRUE;
    self.modifiedSinceLastSyncValue = TRUE;
    
    [super deleteEntity];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name icon:(MIcon *)icon {
    
    [super _resetEntityWithName:name icon:icon];

    self.gID = LOCAL_MAP_ID;
    self.etag = NO_SYNC_ETAG;

    // Se crea como no borrado
    self.markedAsDeletedValue = false;
    
    // Lo marca como modificado para que se sincronice como nuevo elemento
    self.modifiedSinceLastSyncValue = TRUE;
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
