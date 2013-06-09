//
//  MPoint.h
//


#import "_MPoint.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MPoint : _MPoint



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map;
+ (NSArray *) allPointsInContext:(NSManagedObjectContext *)moContext includeMarkedAsDeleted:(BOOL)withDeleted;

+ (NSArray *) pointsInMap:(MMap *)map andCategoryRecursive:(MCategory *)cat;
+ (NSArray *) pointsInMap:(MMap *)map andCategory:(MCategory *)cat;



// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) setLatitude:(double)lat longitude:(double)lng;
- (void) addToCategory:(MCategory *)category;
- (void) removeFromCategory:(MCategory *)category;
- (void) replaceCategories:(NSArray *)categories;


@end
