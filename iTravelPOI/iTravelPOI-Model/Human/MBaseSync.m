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
- (void) markAsDeleted:(BOOL) value {
    @throw [NSException exceptionWithName:@"AbstractMethodException" reason:@"Abstract method 'markAsDeleted' must be implemented by subclass" userInfo:nil];
}

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


//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _deleteEntity {
    
    self.etag = nil;
    self.gID = nil;
    self.markedAsDeletedValue = TRUE;
    self.modifiedSinceLastSyncValue = FALSE;

    [super _deleteEntity];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _updateBasicInfoWithGID:(NSString *)gID etag:(NSString *)etag creationTime:(NSDate *)creationTime updateTime:(NSDate *)updateTime {
    
}

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

//---------------------------------------------------------------------------------------------------------------------
- (void) _markAsDeleted:(BOOL) value {
    
    if(self.markedAsDeletedValue != value) {
        self.markedAsDeletedValue = value;
        [self markAsModified];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _unmarkAsModified {
    self.modifiedSinceLastSyncValue = FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _markAsModified {
    
    [super _markAsModified];
    self.modifiedSinceLastSyncValue = TRUE;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
