// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MCategory.h instead.

#import <CoreData/CoreData.h>
#import "MBaseEntity.h"

extern const struct MCategoryAttributes {
	__unsafe_unretained NSString *iconHREF;
	__unsafe_unretained NSString *viewCount;
} MCategoryAttributes;

extern const struct MCategoryRelationships {
	__unsafe_unretained NSString *mapViewCounts;
	__unsafe_unretained NSString *parent;
	__unsafe_unretained NSString *points;
	__unsafe_unretained NSString *subCategories;
} MCategoryRelationships;

extern const struct MCategoryFetchedProperties {
} MCategoryFetchedProperties;

@class MCacheViewCount;
@class MCategory;
@class MPoint;
@class MCategory;




@interface MCategoryID : NSManagedObjectID {}
@end

@interface _MCategory : MBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MCategoryID*)objectID;





@property (nonatomic, strong) NSString* iconHREF;



//- (BOOL)validateIconHREF:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* viewCount;



//- (BOOL)validateViewCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *mapViewCounts;

- (NSMutableSet*)mapViewCountsSet;




@property (nonatomic, strong) MCategory *parent;

//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *points;

- (NSMutableSet*)pointsSet;




@property (nonatomic, strong) NSSet *subCategories;

- (NSMutableSet*)subCategoriesSet;





@end

@interface _MCategory (CoreDataGeneratedAccessors)

- (void)addMapViewCounts:(NSSet*)value_;
- (void)removeMapViewCounts:(NSSet*)value_;
- (void)addMapViewCountsObject:(MCacheViewCount*)value_;
- (void)removeMapViewCountsObject:(MCacheViewCount*)value_;

- (void)addPoints:(NSSet*)value_;
- (void)removePoints:(NSSet*)value_;
- (void)addPointsObject:(MPoint*)value_;
- (void)removePointsObject:(MPoint*)value_;

- (void)addSubCategories:(NSSet*)value_;
- (void)removeSubCategories:(NSSet*)value_;
- (void)addSubCategoriesObject:(MCategory*)value_;
- (void)removeSubCategoriesObject:(MCategory*)value_;

@end

@interface _MCategory (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveIconHREF;
- (void)setPrimitiveIconHREF:(NSString*)value;




- (NSString*)primitiveViewCount;
- (void)setPrimitiveViewCount:(NSString*)value;





- (NSMutableSet*)primitiveMapViewCounts;
- (void)setPrimitiveMapViewCounts:(NSMutableSet*)value;



- (MCategory*)primitiveParent;
- (void)setPrimitiveParent:(MCategory*)value;



- (NSMutableSet*)primitivePoints;
- (void)setPrimitivePoints:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSubCategories;
- (void)setPrimitiveSubCategories:(NSMutableSet*)value;


@end
