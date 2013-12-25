//
//  MPoint.h
//


#import "_MPoint.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MPoint : _MPoint {}


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) emptyPointWithName:(NSString *)name inMap:(MMap *)map;
+ (NSArray *) allPointsInContext:(NSManagedObjectContext *)moContext includeMarkedAsDeleted:(BOOL)withDeleted;
+ (NSArray *) pointsTaggedWith:(NSSet *)tags inMap:(MMap *)map InContext:(NSManagedObjectContext *)moContext;
+ (NSArray *) pointsWithIcon:(MIcon *)icon;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) setLatitude:(double)lat longitude:(double)lng;

@end
