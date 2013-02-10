//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseGMSync.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MBaseEntity.h"


extern const struct MBaseGMSyncAttributes {
	__unsafe_unretained NSString *etag;
	__unsafe_unretained NSString *gmID;
	__unsafe_unretained NSString *markedAsDeleted;
	__unsafe_unretained NSString *modifiedSinceLastSync;
} MBaseGMSyncAttributes;

extern const struct MBaseGMSyncRelationships {
} MBaseGMSyncRelationships;

extern const struct MBaseGMSyncFetchedProperties {
} MBaseGMSyncFetchedProperties;







@interface MBaseGMSyncID : NSManagedObjectID {}
@end

@interface _MBaseGMSync : MBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MBaseGMSyncID*)objectID;








@property (nonatomic, strong) NSString* etag;






//- (BOOL)validateEtag:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSString* gmID;






//- (BOOL)validateGmID:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSNumber* markedAsDeleted;








@property BOOL markedAsDeletedValue;
- (BOOL)markedAsDeletedValue;
- (void)setMarkedAsDeletedValue:(BOOL)value_;





//- (BOOL)validateMarkedAsDeleted:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSNumber* modifiedSinceLastSync;








@property BOOL modifiedSinceLastSyncValue;
- (BOOL)modifiedSinceLastSyncValue;
- (void)setModifiedSinceLastSyncValue:(BOOL)value_;





//- (BOOL)validateModifiedSinceLastSync:(id*)value_ error:(NSError**)error_;






@end



@interface _MBaseGMSync (CoreDataGeneratedPrimitiveAccessors)


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




@end
