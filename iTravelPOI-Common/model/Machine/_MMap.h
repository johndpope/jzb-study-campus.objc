// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MMap.h instead.

#import <CoreData/CoreData.h>
#import "MBaseEntity.h"

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

@class MCacheViewCount;
@class MPoint;




@interface MMapID : NSManagedObjectID {}
@end

@interface _MMap : MBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MMapID*)objectID;





@property (nonatomic, strong) NSString* summary;



//- (BOOL)validateSummary:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* viewCount;



//- (BOOL)validateViewCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *catViewCounts;

- (NSMutableSet*)catViewCountsSet;




@property (nonatomic, strong) NSSet *points;

- (NSMutableSet*)pointsSet;





@end

@interface _MMap (CoreDataGeneratedAccessors)

- (void)addCatViewCounts:(NSSet*)value_;
- (void)removeCatViewCounts:(NSSet*)value_;
- (void)addCatViewCountsObject:(MCacheViewCount*)value_;
- (void)removeCatViewCountsObject:(MCacheViewCount*)value_;

- (void)addPoints:(NSSet*)value_;
- (void)removePoints:(NSSet*)value_;
- (void)addPointsObject:(MPoint*)value_;
- (void)removePointsObject:(MPoint*)value_;

@end

@interface _MMap (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveSummary;
- (void)setPrimitiveSummary:(NSString*)value;




- (NSString*)primitiveViewCount;
- (void)setPrimitiveViewCount:(NSString*)value;





- (NSMutableSet*)primitiveCatViewCounts;
- (void)setPrimitiveCatViewCounts:(NSMutableSet*)value;



- (NSMutableSet*)primitivePoints;
- (void)setPrimitivePoints:(NSMutableSet*)value;


@end
