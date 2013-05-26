//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MPoint.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MMapBaseEntity.h"


extern const struct MPointAttributes {
	__unsafe_unretained NSString *descr;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
} MPointAttributes;

extern const struct MPointRelationships {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *map;
	__unsafe_unretained NSString *thumbnail;
} MPointRelationships;

extern const struct MPointFetchedProperties {
} MPointFetchedProperties;

@class MCategory;
@class MMap;
@class MMapThumbnail;





@interface MPointID : NSManagedObjectID {}
@end

@interface _MPoint : MMapBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MPointID*)objectID;








@property (nonatomic, strong) NSString* descr;






//- (BOOL)validateDescr:(id*)value_ error:(NSError**)error_;








#ifndef __MPoint__PROTECTED__
@property (nonatomic, strong, readonly) NSNumber* latitude;
#else
@property (nonatomic, strong) NSNumber* latitude;
#endif








#ifndef __MPoint__PROTECTED__
@property (readonly) double latitudeValue;
- (double)latitudeValue;
#else
@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;
#endif





//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;








#ifndef __MPoint__PROTECTED__
@property (nonatomic, strong, readonly) NSNumber* longitude;
#else
@property (nonatomic, strong) NSNumber* longitude;
#endif








#ifndef __MPoint__PROTECTED__
@property (readonly) double longitudeValue;
- (double)longitudeValue;
#else
@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;
#endif





//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;









#ifndef __MPoint__PROTECTED__
@property (nonatomic, strong, readonly) MCategory *category;
#else
@property (nonatomic, strong) MCategory *category;
#endif





//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;








#ifndef __MPoint__PROTECTED__
@property (nonatomic, strong, readonly) MMap *map;
#else
@property (nonatomic, strong) MMap *map;
#endif





//- (BOOL)validateMap:(id*)value_ error:(NSError**)error_;








#ifndef __MPoint__PROTECTED__
@property (nonatomic, strong, readonly) MMapThumbnail *thumbnail;
#else
@property (nonatomic, strong) MMapThumbnail *thumbnail;
#endif





//- (BOOL)validateThumbnail:(id*)value_ error:(NSError**)error_;





@end



@interface _MPoint (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDescr;
- (void)setPrimitiveDescr:(NSString*)value;




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



- (MMapThumbnail*)primitiveThumbnail;
- (void)setPrimitiveThumbnail:(MMapThumbnail*)value;


@end
