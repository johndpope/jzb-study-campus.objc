//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseEntity.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct MBaseEntityAttributes {
	__unsafe_unretained NSString *creationTime;
	__unsafe_unretained NSString *etag;
	__unsafe_unretained NSString *gID;
	__unsafe_unretained NSString *iconHREF;
	__unsafe_unretained NSString *internalID;
	__unsafe_unretained NSString *markedAsDeleted;
	__unsafe_unretained NSString *modifiedSinceLastSync;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *updateTime;
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



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					#ifndef __MBaseEntity__PROTECTED__
					  @property (nonatomic, strong, readonly) NSDate* creationTime;
					#else
					  @property (nonatomic, strong) NSDate* creationTime;
					#endif
				
			
		

		

	//- (BOOL)validateCreationTime:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBaseEntity__PROTECTED__
					  @property (nonatomic, strong, readonly) NSString* etag;
					#else
					  @property (nonatomic, strong) NSString* etag;
					#endif
				
			
		

		

	//- (BOOL)validateEtag:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBaseEntity__PROTECTED__
					  @property (nonatomic, strong, readonly) NSString* gID;
					#else
					  @property (nonatomic, strong) NSString* gID;
					#endif
				
			
		

		

	//- (BOOL)validateGID:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					@property (nonatomic, strong) NSString* iconHREF;
				
			
		

		

	//- (BOOL)validateIconHREF:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBaseEntity__PROTECTED__
					  @property (nonatomic, strong, readonly) NSNumber* internalID;
					#else
					  @property (nonatomic, strong) NSNumber* internalID;
					#endif
				
			
		

		
			
				
					#ifndef __MBaseEntity__PROTECTED__
					  @property (readonly) int64_t internalIDValue;
					  - (int64_t) internalIDValue;
					#else
					@property int64_t internalIDValue;
					  - (int64_t) internalIDValue;
					  - (void) setInternalIDValue:(int64_t)value_;
					#endif
				
			
		

	//- (BOOL)validateInternalID:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBaseEntity__PROTECTED__
					  @property (nonatomic, strong, readonly) NSNumber* markedAsDeleted;
					#else
					  @property (nonatomic, strong) NSNumber* markedAsDeleted;
					#endif
				
			
		

		
			
				
					#ifndef __MBaseEntity__PROTECTED__
					  @property (readonly) BOOL markedAsDeletedValue;
					  - (BOOL) markedAsDeletedValue;
					#else
					@property BOOL markedAsDeletedValue;
					  - (BOOL) markedAsDeletedValue;
					  - (void) setMarkedAsDeletedValue:(BOOL)value_;
					#endif
				
			
		

	//- (BOOL)validateMarkedAsDeleted:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBaseEntity__PROTECTED__
					  @property (nonatomic, strong, readonly) NSNumber* modifiedSinceLastSync;
					#else
					  @property (nonatomic, strong) NSNumber* modifiedSinceLastSync;
					#endif
				
			
		

		
			
				
					#ifndef __MBaseEntity__PROTECTED__
					  @property (readonly) BOOL modifiedSinceLastSyncValue;
					  - (BOOL) modifiedSinceLastSyncValue;
					#else
					@property BOOL modifiedSinceLastSyncValue;
					  - (BOOL) modifiedSinceLastSyncValue;
					  - (void) setModifiedSinceLastSyncValue:(BOOL)value_;
					#endif
				
			
		

	//- (BOOL)validateModifiedSinceLastSync:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					@property (nonatomic, strong) NSString* name;
				
			
		

		

	//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBaseEntity__PROTECTED__
					  @property (nonatomic, strong, readonly) NSDate* updateTime;
					#else
					  @property (nonatomic, strong) NSDate* updateTime;
					#endif
				
			
		

		

	//- (BOOL)validateUpdateTime:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------








//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end



@interface _MBaseEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreationTime;
- (void)setPrimitiveCreationTime:(NSDate*)value;




- (NSString*)primitiveEtag;
- (void)setPrimitiveEtag:(NSString*)value;




- (NSString*)primitiveGID;
- (void)setPrimitiveGID:(NSString*)value;




- (NSString*)primitiveIconHREF;
- (void)setPrimitiveIconHREF:(NSString*)value;




- (NSNumber*)primitiveInternalID;
- (void)setPrimitiveInternalID:(NSNumber*)value;

- (int64_t)primitiveInternalIDValue;
- (void)setPrimitiveInternalIDValue:(int64_t)value_;




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




- (NSDate*)primitiveUpdateTime;
- (void)setPrimitiveUpdateTime:(NSDate*)value;




@end
