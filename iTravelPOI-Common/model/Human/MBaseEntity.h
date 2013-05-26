//
//  MBaseEntity.h
//


#import "_MBaseEntity.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
typedef enum {
    MET_NOTHING = 0,
    MET_MAP = 1,
    MET_POINT = 2,
    MET_CATEGORY = 3
} MODEL_ENTITY_TYPE;




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MBaseEntity : _MBaseEntity {}


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) stringFromDate:(NSDate *)date;
+ (int64_t) _generateInternalID;



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MODEL_ENTITY_TYPE) entityType;
- (JZImage *) entityImage;

- (void) markAsDeleted:(BOOL) value;
- (void) markAsModified;
- (BOOL) wasSynchronizedValue;



//=====================================================================================================================
#pragma mark -
#pragma mark SUBCLASSES PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
#ifdef __MBaseEntity__SUBCLASSES__PROTECTED__
- (void) _resetEntityWithName:(NSString *)name iconHref:(NSString *)iconHref;
- (void) _baseMarkAsDeleted:(BOOL) value;
- (void) _baseMarkAsModified;
#endif


//=====================================================================================================================
#pragma mark -
#pragma mark SYNCHRONIZATION PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
#ifdef __MBaseEntity__SYNCHRONIZATION__PROTECTED__
- (void) _updateBasicInfoWithGID:(NSString *)gID etag:(NSString *)etag creationTime:(NSDate *)creationTime updateTime:(NSDate *)updateTime;
- (void) _cleanMarkAsModified;
#endif



@end
