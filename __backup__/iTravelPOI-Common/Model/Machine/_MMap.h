//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MMap.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MMapBaseEntity.h"


extern const struct MMapAttributes {
	__unsafe_unretained NSString *summary;
	__unsafe_unretained NSString *viewCount;
} MMapAttributes;

extern const struct MMapRelationships {
	__unsafe_unretained NSString *catViewCounts;
	__unsafe_unretained NSString *points;
} MMapRelationships;

extern const struct MMapFetchedProperties {
} MMapFetchedProperties;

@class RMCViewCount;
@class MPoint;




@interface MMapID : NSManagedObjectID {}
@end

@interface _MMap : MMapBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MMapID*)objectID;








@property (nonatomic, strong) NSString* summary;






//- (BOOL)validateSummary:(id*)value_ error:(NSError**)error_;








#ifndef __MMap__PROTECTED__
@property (nonatomic, strong, readonly) NSNumber* viewCount;
#else
@property (nonatomic, strong) NSNumber* viewCount;
#endif








#ifndef __MMap__PROTECTED__
@property (readonly) int16_t viewCountValue;
- (int16_t)viewCountValue;
#else
@property int16_t viewCountValue;
- (int16_t)viewCountValue;
- (void)setViewCountValue:(int16_t)value_;
#endif





//- (BOOL)validateViewCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *catViewCounts;

- (NSMutableSet*)catViewCountsSet;




@property (nonatomic, strong) NSSet *points;

- (NSMutableSet*)pointsSet;





@end


@interface _MMap (CatViewCountsCoreDataGeneratedAccessors)
- (void)addCatViewCounts:(NSSet*)value_;
- (void)removeCatViewCounts:(NSSet*)value_;
- (void)addCatViewCountsObject:(RMCViewCount*)value_;
- (void)removeCatViewCountsObject:(RMCViewCount*)value_;
@end

@interface _MMap (PointsCoreDataGeneratedAccessors)
- (void)addPoints:(NSSet*)value_;
- (void)removePoints:(NSSet*)value_;
- (void)addPointsObject:(MPoint*)value_;
- (void)removePointsObject:(MPoint*)value_;
@end


@interface _MMap (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveSummary;
- (void)setPrimitiveSummary:(NSString*)value;




- (NSNumber*)primitiveViewCount;
- (void)setPrimitiveViewCount:(NSNumber*)value;

- (int16_t)primitiveViewCountValue;
- (void)setPrimitiveViewCountValue:(int16_t)value_;





- (NSMutableSet*)primitiveCatViewCounts;
- (void)setPrimitiveCatViewCounts:(NSMutableSet*)value;



- (NSMutableSet*)primitivePoints;
- (void)setPrimitivePoints:(NSMutableSet*)value;


@end
