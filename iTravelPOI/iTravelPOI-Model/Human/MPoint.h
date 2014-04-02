//
//  MPoint.h
//

#import <MapKit/MapKit.h>
#import "_MPoint.h"


@class MMap;



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MPoint : _MPoint <MKAnnotation> {}


@property (readonly, nonatomic) NSSet               *directTags;
@property (readonly, nonatomic) NSSet               *directNoAutoTags;

@property (assign, nonatomic)   CLLocationDistance  viewDistance;
@property (strong, nonatomic)   NSString            *viewStringDistance;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MPoint *)  emptyPointWithName:(NSString *)name inMap:(MMap *)map;
+ (NSArray *) allWithMap:(MMap *)map sortOrder:(NSArray *)sortOrder;

+ (NSMutableSet *) allTagsFromPoints:(NSArray *)points;
+ (NSMutableSet *) allNonAutoTagsFromPoints:(NSArray *)points;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLatitude:(double)lat longitude:(double)lng;
- (BOOL) updateDesc:(NSString *)value;

- (void) removeAllNonAutoTags;

// With format: $[tag1, tag2, ...]$
- (NSString *) combinedDescAndTagsInfo;
- (void) updateFromCombinedDescAndTagsInfo:(NSString *)descAndTags;

@end
