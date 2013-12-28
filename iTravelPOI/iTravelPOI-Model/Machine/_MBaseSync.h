//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseSync.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MBase.h"


extern const struct MBaseSyncAttributes {
	__unsafe_unretained NSString *etag;
	__unsafe_unretained NSString *gID;
	__unsafe_unretained NSString *markedAsDeleted;
	__unsafe_unretained NSString *modifiedSinceLastSync;
} MBaseSyncAttributes;

extern const struct MBaseSyncRelationships {
} MBaseSyncRelationships;

extern const struct MBaseSyncFetchedProperties {
} MBaseSyncFetchedProperties;







@interface MBaseSyncID : NSManagedObjectID {}
@end

@interface _MBaseSync : MBase {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MBaseSyncID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					#ifndef __MBaseSync__PROTECTED__
					  @property (nonatomic, strong, readonly) NSString* etag;
					#else
					  @property (nonatomic, strong) NSString* etag;
					#endif
				
			
		

		

	//- (BOOL)validateEtag:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBaseSync__PROTECTED__
					  @property (nonatomic, strong, readonly) NSString* gID;
					#else
					  @property (nonatomic, strong) NSString* gID;
					#endif
				
			
		

		

	//- (BOOL)validateGID:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBaseSync__PROTECTED__
					  @property (nonatomic, strong, readonly) NSNumber* markedAsDeleted;
					#else
					  @property (nonatomic, strong) NSNumber* markedAsDeleted;
					#endif
				
			
		

		
			
				
					#ifndef __MBaseSync__PROTECTED__
					  @property (readonly) BOOL markedAsDeletedValue;
					  - (BOOL) markedAsDeletedValue;
					#else
					@property BOOL markedAsDeletedValue;
					  - (BOOL) markedAsDeletedValue;
					  - (void) setMarkedAsDeletedValue:(BOOL)value_;
					#endif
				
			
		

	//- (BOOL)validateMarkedAsDeleted:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBaseSync__PROTECTED__
					  @property (nonatomic, strong, readonly) NSNumber* modifiedSinceLastSync;
					#else
					  @property (nonatomic, strong) NSNumber* modifiedSinceLastSync;
					#endif
				
			
		

		
			
				
					#ifndef __MBaseSync__PROTECTED__
					  @property (readonly) BOOL modifiedSinceLastSyncValue;
					  - (BOOL) modifiedSinceLastSyncValue;
					#else
					@property BOOL modifiedSinceLastSyncValue;
					  - (BOOL) modifiedSinceLastSyncValue;
					  - (void) setModifiedSinceLastSyncValue:(BOOL)value_;
					#endif
				
			
		

	//- (BOOL)validateModifiedSinceLastSync:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------








//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end



@interface _MBaseSync (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEtag;
- (void)setPrimitiveEtag:(NSString*)value;




- (NSString*)primitiveGID;
- (void)setPrimitiveGID:(NSString*)value;




- (NSNumber*)primitiveMarkedAsDeleted;
- (void)setPrimitiveMarkedAsDeleted:(NSNumber*)value;

- (BOOL)primitiveMarkedAsDeletedValue;
- (void)setPrimitiveMarkedAsDeletedValue:(BOOL)value_;




- (NSNumber*)primitiveModifiedSinceLastSync;
- (void)setPrimitiveModifiedSinceLastSync:(NSNumber*)value;

- (BOOL)primitiveModifiedSinceLastSyncValue;
- (void)setPrimitiveModifiedSinceLastSyncValue:(BOOL)value_;




@end
