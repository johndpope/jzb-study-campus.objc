// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseEntity.h instead.
#import <CoreData/CoreData.h>


extern const struct MBaseEntityAttributes {
	__unsafe_unretained NSString *etag;
	__unsafe_unretained NSString *gmID;
	__unsafe_unretained NSString *markedAsDeleted;
	__unsafe_unretained NSString *modifiedSinceLastSync;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *published_Date;
	__unsafe_unretained NSString *updated_Date;
} MBaseEntityAttributes;

extern const struct MBaseEntityRelationships {
} MBaseEntityRelationships;

extern const struct MBaseEntityFetchedProperties {
} MBaseEntityFetchedProperties;










@interface MBaseEntityID : NSManagedObjectID {}
@end

@interface _MBaseEntity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MBaseEntityID*)objectID;








@property (nonatomic, strong) NSString* etag;






//- (BOOL)validateEtag:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSString* gmID;






//- (BOOL)validateGmID:(id*)value_ error:(NSError**)error_;








#ifndef __MBaseEntity__PROTECTED__
@property (nonatomic, strong, readonly) NSNumber* markedAsDeleted;
#else
@property (nonatomic, strong) NSNumber* markedAsDeleted;
#endif








#ifndef __MBaseEntity__PROTECTED__
@property (nonatomic, readonly) BOOL markedAsDeletedValue;
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








@property (nonatomic, strong) NSString* name;






//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSDate* published_Date;






//- (BOOL)validatePublished_Date:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSDate* updated_Date;






//- (BOOL)validateUpdated_Date:(id*)value_ error:(NSError**)error_;






@end



@interface _MBaseEntity (CoreDataGeneratedPrimitiveAccessors)


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




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSDate*)primitivePublished_Date;
- (void)setPrimitivePublished_Date:(NSDate*)value;




- (NSDate*)primitiveUpdated_Date;
- (void)setPrimitiveUpdated_Date:(NSDate*)value;




@end
