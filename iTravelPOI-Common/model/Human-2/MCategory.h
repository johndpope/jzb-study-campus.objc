#import "_MCategory.h"
#import "MMap.h"
#import "MCacheViewCount.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC CONSTANTS and C-Methods definitions
// *********************************************************************************************************************
#define URL_PARAM_PCAT @"pcat="
#define CATPATH_SEP @"#"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface MCategory : _MCategory


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (void) parseIconHREF:(NSString *)iconHREF baseURL:(NSString **)baseURL catPath:(NSString **)catPath;

+ (MCategory *) categoryForIconHREF:(NSString *)iconHREF inContext:(NSManagedObjectContext *)moContext;
+ (NSArray *) categoriesFromMap:(MMap *)map parentCategory:(MCategory *)pCat error:(NSError **)err;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) deletePointsWithMap:(MMap *)map;
- (void) movePointsToCategoryWithIconHREF:(NSString *)iconHREF inMap:(MMap *)map;
- (MCacheViewCount *) viewCountForMap:(MMap *)map;

- (void) setAsDeleted:(BOOL) value;
- (void) updateViewCount:(int) increment;
- (void) updateViewCountForMap:(MMap *)map increment:(int) increment;



@end
