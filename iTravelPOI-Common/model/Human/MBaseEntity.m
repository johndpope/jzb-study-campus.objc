//
//  MBaseEntity.m
//

#define __MBaseEntity__IMPL__
#define __MBaseEntity__PROTECTED__

#import "MBaseEntity.h"
#import "ImageManager.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define M_DATE_FORMATTER @"yyyy-MM-dd'T'HH:mm:ss'.'SSSS'Z'"
#define GM_LOCAL_ID      @"LocalGMap-ID"
#define GM_NO_SYNC_ETAG  @"No-Sycn-ETag"




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MBaseEntity ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MBaseEntity



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




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (MODEL_ENTITY_TYPE) entityType {
    @throw [NSException exceptionWithName:@"AbstractMethodException" reason:@"Abstract method must be implemented by subclass" userInfo:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (JZImage *) entityImage {
    return [ImageManager iconDataForHREF:self.iconHREF].image;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) wasSynchronizedValue {
    return ![self.gID isEqualToString:GM_LOCAL_ID] && ![self.etag isEqualToString:GM_NO_SYNC_ETAG];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsDeleted:(BOOL) value {
    @throw [NSException exceptionWithName:@"AbstractMethodException" reason:@"Abstract method must be implemented by subclass" userInfo:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) markAsModified {
    @throw [NSException exceptionWithName:@"AbstractMethodException" reason:@"Abstract method must be implemented by subclass" userInfo:nil];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
// ---------------------------------------------------------------------------------------------------------------------
+ (int64_t) _generateInternalID {
    
    static int64_t s_idCounter = 0;
    
    @synchronized([MBaseEntity class]) {
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
- (void) _updateBasicInfoWithGID:(NSString *)gID etag:(NSString *)etag creationTime:(NSDate *)creationTime updateTime:(NSDate *)updateTime {
    
    self.gID = gID;
    self.etag = etag;
    self.creationTime = creationTime;
    self.updateTime = updateTime;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name iconHref:(NSString *)iconHref {

    NSDate *now = [NSDate date];
    
    self.internalIDValue = [MBaseEntity _generateInternalID];
    [self _updateBasicInfoWithGID:GM_LOCAL_ID etag:GM_NO_SYNC_ETAG creationTime:now updateTime:now];
    self.name = [name copy];
    self.iconHREF = [iconHref copy];
    self.markedAsDeletedValue = false;
    
    // Lo marca como midificado para que se sincronice como nuevo elemento
    self.modifiedSinceLastSyncValue = true;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _baseMarkAsDeleted:(BOOL) value {
    
    if(self.markedAsDeletedValue != value) {
        self.markedAsDeletedValue = value;
        [self markAsModified];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _cleanMarkAsModified {
    self.markedAsDeletedValue = FALSE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _baseMarkAsModified {
    
    self.modifiedSinceLastSyncValue = TRUE;
    self.updateTime = [NSDate date];
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------




@end
