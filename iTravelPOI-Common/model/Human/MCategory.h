//
//  MCategory.h
//


#import "_MCategory.h"
@class MMap;



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
#define CATEGORY_NAME_SEPARATOR @"."


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MCategory : _MCategory



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) categoryWithFullName:(NSString *)fullName inContext:(NSManagedObjectContext *)moContext;
+ (MCategory *) categoryWithName:(NSString *)name parentCategory:(MCategory *)parentCategory inContext:(NSManagedObjectContext *)moContext;

+ (NSArray *) allCategoriesInContext:(NSManagedObjectContext *)moContext includeMarkedAsDeleted:(BOOL)withDeleted;

+ (NSArray *) categoriesWithPointsInMap:(MMap *)map parentCategory:(MCategory *)parentCat;

+ (NSArray *) rootCategoriesWithPointsInMap:(MMap *)map;
+ (NSArray *) frequentRootCategoriesWithPointsNotInMap:(MMap *)map;
+ (NSArray *) otherRootCategoriesWithPointsNotInMap:(MMap *)map;

+ (void) purgeEmptyCategoriesInContext:(NSManagedObjectContext *)moContext;



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) allDescendantSorted:(BOOL)sorted selfIncluded:(BOOL)selfIncluded;
- (NSArray *) allInHierarchy;

- (BOOL) isRelatedTo:(MCategory *)cat;
- (BOOL) isDescendatOf:(MCategory *)cat;
- (MCategory *) rootParent;

- (void) transferTo:(MCategory *)destCategory inMap:(MMap *)map;

- (void) deletePointsInMap:(MMap *)map;

- (NSString *) strViewCount;
- (NSString *) strViewCountForMap:(MMap *)map;



//=====================================================================================================================
#pragma mark -
#pragma mark SUBCLASSES PROTECTED methods
//---------------------------------------------------------------------------------------------------------------------
#ifdef __MBaseEntity__SUBCLASSES__PROTECTED__
- (void) updateViewCount:(int)increment inMap:(MMap *)map;
#endif


@end
