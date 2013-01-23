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
+ (MPoint *) emptyPointInMap:(MMap *)map inContext:(NSManagedObjectContext *)moContext;
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map inContext:(NSManagedObjectContext *)moContext;

+ (NSArray *) pointsFromMap:(MMap *)map category:(MCategory *)cat error:(NSError **)err;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------


@end
