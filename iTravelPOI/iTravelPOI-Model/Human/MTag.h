//
//  MTag.h
//


#import "_MTag.h"

@class MPoint;


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
#define TAG_NAME_SEPARATOR @"|"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MTag : _MTag {}


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MTag *) tagWithFullName:(NSString *)name parentTag:(MTag *)parentTag inContext:(NSManagedObjectContext *)moContext;
+ (MTag *) tagWithFullName:(NSString *)fullName inContext:(NSManagedObjectContext *)moContext;
+ (MTag *) tagFromIcon:(MIcon *)icon;
+ (NSArray *) allTagsInContext:(NSManagedObjectContext *)moContext includeEmptyTags:(BOOL)emptyTags;

+ (NSArray *) tagsForPointsTaggedWith:(NSSet *)tags InContext:(NSManagedObjectContext *)moContext;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) tagPoint:(MPoint *)point;
- (void) untagPoint:(MPoint *)point;

- (BOOL) isAncestorOfTag:(MTag *)childTag;

@end
