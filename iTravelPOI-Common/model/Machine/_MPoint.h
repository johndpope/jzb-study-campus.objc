// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MPoint.h instead.

#import <CoreData/CoreData.h>
#import "MBaseEntity.h"

extern const struct MPointAttributes {
	__unsafe_unretained NSString *descr;
	__unsafe_unretained NSString *iconHREF;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
} MPointAttributes;

extern const struct MPointRelationships {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *map;
} MPointRelationships;

extern const struct MPointFetchedProperties {
} MPointFetchedProperties;

@class MCategory;
@class MMap;






@interface MPointID : NSManagedObjectID {}
@end

@interface _MPoint : MBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MPointID*)objectID;





@property (nonatomic, strong) NSString* descr;



//- (BOOL)validateDescr:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iconHREF;



//- (BOOL)validateIconHREF:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* latitude;



@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MCategory *category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) MMap *map;

//- (BOOL)validateMap:(id*)value_ error:(NSError**)error_;





@end

@interface _MPoint (CoreDataGeneratedAccessors)

@end

@interface _MPoint (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDescr;
- (void)setPrimitiveDescr:(NSString*)value;




- (NSString*)primitiveIconHREF;
- (void)setPrimitiveIconHREF:(NSString*)value;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;





- (MCategory*)primitiveCategory;
- (void)setPrimitiveCategory:(MCategory*)value;



- (MMap*)primitiveMap;
- (void)setPrimitiveMap:(MMap*)value;


@end
