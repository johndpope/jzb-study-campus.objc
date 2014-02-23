//
//  MBase.h
//


#import "_MBase.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
UIKIT_EXTERN NSString *const MBaseOrderNone;
UIKIT_EXTERN NSString *const MBaseOrderByNameAsc;
UIKIT_EXTERN NSString *const MBaseOrderByNameDes;
UIKIT_EXTERN NSString *const MBaseOrderByTCreationAsc;
UIKIT_EXTERN NSString *const MBaseOrderByTCreationDes;
UIKIT_EXTERN NSString *const MBaseOrderByTUpdateAsc;
UIKIT_EXTERN NSString *const MBaseOrderByTUpdateDes;
UIKIT_EXTERN NSString *const MBaseOrderByIconAsc;
UIKIT_EXTERN NSString *const MBaseOrderByIconDes;


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MBase : _MBase {}


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) stringFromDate:(NSDate *)date;
+ (NSMutableArray *) sortDescriptorsByOrder:(NSArray *)orderArray fieldName:(NSString *)name;
+ (NSMutableArray *) sortDescriptorsByOrder:(NSArray *)orderArray;


+ (NSArray *) allInContext:(NSManagedObjectContext *)moContext sortOrder:(NSArray *)sortOrder includeMarkedAsDeleted:(BOOL)withDeleted;
+ (NSArray *) allWithName:(NSString *)name  sortOrder:(NSArray *)sortOrder inContext:(NSManagedObjectContext *)moContext;
+ (NSArray *) allWithNameLike:(NSString *)name sortOrder:(NSArray *)sortOrder maxNumItems:(NSUInteger)maxNumItems inContext:(NSManagedObjectContext *)moContext;
+ (NSArray *) allWithIcon:(MIcon *)icon sortOrder:(NSArray *)sortOrder;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) deleteEntity;
- (BOOL) updateIcon:(MIcon *)icon;
- (BOOL) updateName:(NSString *)value;
- (void) markAsModified;


//=====================================================================================================================
#pragma mark -
#pragma mark SUBCLASSES PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
#ifdef __MBase__SUBCLASSES__PROTECTED__
+ (int64_t) _generateInternalID;
- (void) _resetEntityWithName:(NSString *)name icon:(MIcon *)icon;
- (void) _deleteEntity;
- (void) _markAsModified;


+ (NSArray *) _allWithPredicate:(NSPredicate *)predicate  sortOrder:(NSArray *)sortOrder inContext:(NSManagedObjectContext *)moContext;

+ (NSString *)    _myEntityName;
+ (NSPredicate *) _predicateAllInContextIncludeMarkedAsDeleted:(BOOL)withDeleted;
+ (NSPredicate *) _predicateAllWithName:(NSString *)name;
+ (NSPredicate *) _predicateAllWithNameLike:(NSString *)name;
+ (NSPredicate *) _predicateAllWithIcon:(MIcon *)icon;
#endif


@end
