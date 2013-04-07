//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MMapBaseEntity.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MBaseEntity.h"


extern const struct MMapBaseEntityAttributes {
	__unsafe_unretained NSString *etag;
	__unsafe_unretained NSString *gmID;
	__unsafe_unretained NSString *markedAsDeleted;
	__unsafe_unretained NSString *modifiedSinceLastSync;
	__unsafe_unretained NSString *published_date;
} MMapBaseEntityAttributes;

extern const struct MMapBaseEntityRelationships {
} MMapBaseEntityRelationships;

extern const struct MMapBaseEntityFetchedProperties {
} MMapBaseEntityFetchedProperties;








@interface MMapBaseEntityID : NSManagedObjectID {}
@end

@interface _MMapBaseEntity : MBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MMapBaseEntityID*)objectID;








@property (nonatomic, strong) NSString* etag;






//- (BOOL)validateEtag:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSString* gmID;






//- (BOOL)validateGmID:(id*)value_ error:(NSError**)error_;








#ifndef __MMapBaseEntity__PROTECTED__
@property (nonatomic, strong, readonly) NSNumber* markedAsDeleted;
#else
@property (nonatomic, strong) NSNumber* markedAsDeleted;
#endif








#ifndef __MMapBaseEntity__PROTECTED__
@property (readonly) BOOL markedAsDeletedValue;
- (BOOL)markedAsDeletedValue;
#else
@property BOOL markedAsDeletedValue;
- (BOOL)markedAsDeletedValue;
- (void)setMarkedAsDeletedValue:(BOOL)value_;
#endif





//- (BOOL)validateMarkedAsDeleted:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSNumber* modifiedSinceLastSync;








@property BOOL modifiedSinceLastSyncValue;
- (BOOL)modifiedSinceLastSyncValue;
- (void)setModifiedSinceLastSyncValue:(BOOL)value_;





//- (BOOL)validateModifiedSinceLastSync:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSDate* published_date;






//- (BOOL)validatePublished_date:(id*)value_ error:(NSError**)error_;






@end



@interface _MMapBaseEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEtag;
- (void)setPrimitiveEtag:(NSString*)value;




- (NSString*)primitiveGmID;
- (void)setPrimitiveGmID:(NSString*)value;




- (NSNumber*)primitiveMarkedAsDeleted;
- (void)setPrimitiveMarkedAsDeleted:(NSNumber*)value;

- (BOOL)primitiveMarkedAsDeletedValue;
- (void)setPrimitiveMarkedAsDeletedValue:(BOOL)value_;




- (NSNumber*)primitiveModifiedSinceLastSync;
- (void)setPrimitiveModifiedSinceLastSync:(NSNumber*)value;

- (BOOL)primitiveModifiedSinceLastSyncValue;
- (void)setPrimitiveModifiedSinceLastSyncValue:(BOOL)value_;




- (NSDate*)primitivePublished_date;
- (void)setPrimitivePublished_date:(NSDate*)value;




@end
