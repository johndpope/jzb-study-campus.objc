#import "_MCacheViewCount.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC CONSTANTS and C-Methods definitions
// *********************************************************************************************************************



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface MCacheViewCount : _MCacheViewCount



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MCacheViewCount *) cacheViewCountForMap:(MMap *)map category:(MCategory *)category inContext:(NSManagedObjectContext *)moContext;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------


@end
