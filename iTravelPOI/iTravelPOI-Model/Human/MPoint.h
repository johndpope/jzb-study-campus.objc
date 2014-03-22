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


@property (nonatomic, readonly) NSSet *directTags; 
@property (nonatomic, readonly) NSSet *directNoAutoTags;

@property (nonatomic, assign)   CLLocationDistance   viewDistance;
@property (nonatomic, strong)   NSString            *viewStringDistance;


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

@end
