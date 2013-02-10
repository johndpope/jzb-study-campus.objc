//
//  MCategory.h
//


#import "_MCategory.h"
@class MMap;



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
#define CATPATH_SEP @"#"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MCategory : _MCategory



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MCategory *) categoryForIconHREF:(NSString *)iconHREF inContext:(NSManagedObjectContext *)moContext;
+ (MCategory *) categoryForIconBaseHREF:(NSString *)baseHREF extraInfo:(NSString *)extraInfo inContext:(NSManagedObjectContext *)moContext;

+ (NSArray *) categoriesWithPointsInMap:(MMap *)map parentCategory:(MCategory *)parentCat;



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) updateViewCount:(int) increment;

- (RMCViewCount *) viewCountForMap:(MMap *)map;
- (void) updateViewCountForMap:(MMap *)map increment:(int) increment;

- (void) deletePointsInMap:(MMap *)map;

- (void) movePointsToCategory:(MCategory *)destCategory inMap:(MMap *)map;


@end
