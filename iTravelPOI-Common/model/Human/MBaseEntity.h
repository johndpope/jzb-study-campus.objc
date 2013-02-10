//
//  MBaseEntity.h
//


#import "_MBaseEntity.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
#define URL_PARAM_ITP_INFO     @"itpInfo="
#define URL_PARAM_ITP_VAL_SEP  @"#"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MBaseEntity : _MBaseEntity


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) stringFromDate:(NSDate *)date;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) iconHREF;
- (void) updateDeleteMark:(BOOL) value;



//=====================================================================================================================
#pragma mark -
#pragma mark SUBCLASSES PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
#ifdef __MBaseEntity__SUBCLASSES__PROTECTED__

+ (void) _parseIconHREF:(NSString *)iconHREF baseURL:(NSString **)baseURL extraInfo:(NSString **)extraInfo;

- (void) _resetEntityWithName:(NSString *)name;
- (void) _updateIconHREF:(NSString *)iconHREF;
- (void) _updateIconBaseHREF:(NSString *)baseHREF iconExtraInfo:(NSString *)extraInfo;

#endif


@end
