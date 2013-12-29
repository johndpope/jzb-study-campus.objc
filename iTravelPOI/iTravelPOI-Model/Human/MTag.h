//
//  MTag.h
//


#import "_MTag.h"

@class MPoint;


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
+ (NSArray *) allTagsInContext:(NSManagedObjectContext *)moContext includeEmptyTags:(BOOL)emptyTags;

+ (NSArray *) tagsForPointsTaggedWith:(NSSet *)tags InContext:(NSManagedObjectContext *)moContext;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) tagPoint:(MPoint *)point;
- (void) untagPoint:(MPoint *)point;

- (void) tagChildTag:(MTag *)childTag;
- (void) untagChildTag:(MTag *)childTag;

- (BOOL) hasParentTags;
- (BOOL) anyIsParentTag:(NSSet *)tags;
- (BOOL) isDirectParentOfTag:(MTag *)childTag;
- (BOOL) isAncestorOfTag:(MTag *)childTag;

@end
