// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MCacheViewCount.h instead.
#import <CoreData/CoreData.h>


extern const struct MCacheViewCountAttributes {
	__unsafe_unretained NSString *viewCount;
} MCacheViewCountAttributes;

extern const struct MCacheViewCountRelationships {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *map;
} MCacheViewCountRelationships;

extern const struct MCacheViewCountFetchedProperties {
} MCacheViewCountFetchedProperties;

@class MCategory;
@class MMap;



@interface MCacheViewCountID : NSManagedObjectID {}
@end

@interface _MCacheViewCount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MCacheViewCountID*)objectID;








@property (nonatomic, strong) NSNumber* viewCount;








@property int16_t viewCountValue;
- (int16_t)viewCountValue;
- (void)setViewCountValue:(int16_t)value_;





//- (BOOL)validateViewCount:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) MCategory *category;




//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;







@property (nonatomic, strong) MMap *map;




//- (BOOL)validateMap:(id*)value_ error:(NSError**)error_;





@end



@interface _MCacheViewCount (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveViewCount;
- (void)setPrimitiveViewCount:(NSNumber*)value;

- (int16_t)primitiveViewCountValue;
- (void)setPrimitiveViewCountValue:(int16_t)value_;





- (MCategory*)primitiveCategory;
- (void)setPrimitiveCategory:(MCategory*)value;



- (MMap*)primitiveMap;
- (void)setPrimitiveMap:(MMap*)value;


@end
