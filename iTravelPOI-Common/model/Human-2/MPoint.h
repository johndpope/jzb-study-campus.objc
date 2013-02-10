#import "_MPoint.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface MPoint : _MPoint { }



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) emptyPointInMap:(MMap *)map;
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map;
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map withCategory:(MCategory *)category;

+ (NSArray *) pointsFromMap:(MMap *)map category:(MCategory *)cat error:(NSError **)err;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) setAsDeleted:(BOOL) value;
- (void) moveToIconHREF:(NSString *)iconHREF;
- (void) moveToCategory:(MCategory *)category;

@end
