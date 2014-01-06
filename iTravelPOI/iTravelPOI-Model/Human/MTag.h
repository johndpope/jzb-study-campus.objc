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




//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) tagPoint:(MPoint *)point;
- (void) untagPoint:(MPoint *)point;

- (BOOL) isDescendantOfTag:(MTag *)parentTag;
- (BOOL) isAncestorOfTag:(MTag *)childTag;

- (BOOL) isRelativeOfTag:(MTag *)tag;
- (BOOL) isRelativeOfAnyTag:(id<NSFastEnumeration>)tags;

@end
