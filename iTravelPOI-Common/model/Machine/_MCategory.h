//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MCategory.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MBaseEntity.h"


extern const struct MCategoryAttributes {
	__unsafe_unretained NSString *fullName;
	__unsafe_unretained NSString *iconBaseHREF;
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

@class RMCViewCount;
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








#ifndef __MCategory__PROTECTED__
@property (nonatomic, strong, readonly) NSString* fullName;
#else
@property (nonatomic, strong) NSString* fullName;
#endif






//- (BOOL)validateFullName:(id*)value_ error:(NSError**)error_;








#ifndef __MCategory__PROTECTED__
@property (nonatomic, strong, readonly) NSString* iconBaseHREF;
#else
@property (nonatomic, strong) NSString* iconBaseHREF;
#endif






//- (BOOL)validateIconBaseHREF:(id*)value_ error:(NSError**)error_;








#ifndef __MCategory__PROTECTED__
@property (nonatomic, strong, readonly) NSNumber* viewCount;
#else
@property (nonatomic, strong) NSNumber* viewCount;
#endif








#ifndef __MCategory__PROTECTED__
@property (readonly) int16_t viewCountValue;
- (int16_t)viewCountValue;
#else
@property int16_t viewCountValue;
- (int16_t)viewCountValue;
- (void)setViewCountValue:(int16_t)value_;
#endif





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


@interface _MCategory (MapViewCountsCoreDataGeneratedAccessors)
- (void)addMapViewCounts:(NSSet*)value_;
- (void)removeMapViewCounts:(NSSet*)value_;
- (void)addMapViewCountsObject:(RMCViewCount*)value_;
- (void)removeMapViewCountsObject:(RMCViewCount*)value_;
@end

@interface _MCategory (PointsCoreDataGeneratedAccessors)
- (void)addPoints:(NSSet*)value_;
- (void)removePoints:(NSSet*)value_;
- (void)addPointsObject:(MPoint*)value_;
- (void)removePointsObject:(MPoint*)value_;
@end

@interface _MCategory (SubCategoriesCoreDataGeneratedAccessors)
- (void)addSubCategories:(NSSet*)value_;
- (void)removeSubCategories:(NSSet*)value_;
- (void)addSubCategoriesObject:(MCategory*)value_;
- (void)removeSubCategoriesObject:(MCategory*)value_;
@end


@interface _MCategory (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveFullName;
- (void)setPrimitiveFullName:(NSString*)value;




- (NSString*)primitiveIconBaseHREF;
- (void)setPrimitiveIconBaseHREF:(NSString*)value;




- (NSNumber*)primitiveViewCount;
- (void)setPrimitiveViewCount:(NSNumber*)value;

- (int16_t)primitiveViewCountValue;
- (void)setPrimitiveViewCountValue:(int16_t)value_;





- (NSMutableSet*)primitiveMapViewCounts;
- (void)setPrimitiveMapViewCounts:(NSMutableSet*)value;



- (MCategory*)primitiveParent;
- (void)setPrimitiveParent:(MCategory*)value;



- (NSMutableSet*)primitivePoints;
- (void)setPrimitivePoints:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSubCategories;
- (void)setPrimitiveSubCategories:(NSMutableSet*)value;


@end
