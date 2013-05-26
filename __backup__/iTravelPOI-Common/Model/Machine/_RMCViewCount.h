//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RMCViewCount.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct RMCViewCountAttributes {
	__unsafe_unretained NSString *viewCount;
} RMCViewCountAttributes;

extern const struct RMCViewCountRelationships {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *map;
} RMCViewCountRelationships;

extern const struct RMCViewCountFetchedProperties {
} RMCViewCountFetchedProperties;

@class MCategory;
@class MMap;



@interface RMCViewCountID : NSManagedObjectID {}
@end

@interface _RMCViewCount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RMCViewCountID*)objectID;








#ifndef __RMCViewCount__PROTECTED__
@property (nonatomic, strong, readonly) NSNumber* viewCount;
#else
@property (nonatomic, strong) NSNumber* viewCount;
#endif








#ifndef __RMCViewCount__PROTECTED__
@property (readonly) int16_t viewCountValue;
- (int16_t)viewCountValue;
#else
@property int16_t viewCountValue;
- (int16_t)viewCountValue;
- (void)setViewCountValue:(int16_t)value_;
#endif





//- (BOOL)validateViewCount:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) MCategory *category;




//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;







@property (nonatomic, strong) MMap *map;




//- (BOOL)validateMap:(id*)value_ error:(NSError**)error_;





@end



@interface _RMCViewCount (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveViewCount;
- (void)setPrimitiveViewCount:(NSNumber*)value;

- (int16_t)primitiveViewCountValue;
- (void)setPrimitiveViewCountValue:(int16_t)value_;





- (MCategory*)primitiveCategory;
- (void)setPrimitiveCategory:(MCategory*)value;



- (MMap*)primitiveMap;
- (void)setPrimitiveMap:(MMap*)value;


@end
