#import "_MMap.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface MMap : _MMap


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MMap *) emptyMapInContext:(NSManagedObjectContext *)moContext;
+ (MMap *) emptyMapWithName:(NSString *)name inContext:(NSManagedObjectContext *)moContext;


+ (NSArray *) allMapsInContext:(NSManagedObjectContext *)moContext includeMarkedAsDeleted:(BOOL)withDeleted error:(NSError **)err;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) setAsDeleted:(BOOL)value;
- (void) updateViewCount:(int) increment;


@end
