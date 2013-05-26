//
//  MMapBaseEntity.m
//

#define __MMapBaseEntity__IMPL__
#define __MMapBaseEntity__PROTECTED__
#define __MMapBaseEntity__SUBCLASSES__PROTECTED__

#import "MMapBaseEntity.h"
#import "NSString+JavaStr.h"
#import "ImageManager.h"
#import "GMTItem.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define M_DATE_FORMATTER @"yyyy-MM-dd'T'HH:mm:ss'.'SSSS'Z'"




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MMapBaseEntity ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MMapBaseEntity



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
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) wasSynchronizedValue {
    return ![self.gmID isEqualToString:GM_LOCAL_ID] && ![self.etag isEqualToString:GM_NO_SYNC_ETAG];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateDeleteMark:(BOOL) value {
    @throw [NSException exceptionWithName:@"AbstractMethodException" reason:@"Abstract method must be implemented by subclass" userInfo:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) updateModifiedMark {
    self.modifiedSinceLastSyncValue = true;
    self.updated_date = [NSDate date];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Protected methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _resetEntityWithName:(NSString *)name {
    
    self.name = name;
    self.gmID = GM_LOCAL_ID;
    self.etag = GM_NO_SYNC_ETAG;
    self.markedAsDeletedValue = false;
    self.modifiedSinceLastSyncValue = true;
    self.published_date = [NSDate date];
    self.updated_date = self.published_date;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _baseUpdateDeleteMark:(BOOL) value {
    self.markedAsDeletedValue = value;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------




@end
