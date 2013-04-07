//
//  MCategory.h
//


#import "_MCategory.h"
@class MMap;



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
#define CAT_NAME_SEPARATOR  @"#"
#define URL_PARAM_CAT_INFO  @"catInfo="



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
+ (MCategory *) categoryForIconBaseHREF:(NSString *)baseHREF fullName:(NSString *)fullName inContext:(NSManagedObjectContext *)moContext;

+ (NSArray *) categoriesWithPointsInMap:(MMap *)map parentCategory:(MCategory *)parentCat;



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) iconHREF;
- (NSString *) pathName;

- (void) updateViewCount:(int) increment;

- (RMCViewCount *) viewCountForMap:(MMap *)map;
- (void) updateViewCountForMap:(MMap *)map increment:(int) increment;

- (void) deletePointsInMap:(MMap *)map;


@end
