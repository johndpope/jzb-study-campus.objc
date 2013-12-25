//
//  MTag.h
//


#import "_MTag.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MTag : _MTag {}


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MTag *) tagByName:(NSString *)name inContext:(NSManagedObjectContext *)moContext;
+ (MTag *) tagFromIcon:(MIcon *)icon;
+ (NSArray *) tagsForPointsTaggedWith:(NSSet *)tags InContext:(NSManagedObjectContext *)moContext;
+ (NSArray *) allTagsInContext:(NSManagedObjectContext *)moContext includeEmptyTags:(BOOL)emptyTags;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------


@end
