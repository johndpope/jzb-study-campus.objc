//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MMapThumbnail.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct MMapThumbnailAttributes {
	__unsafe_unretained NSString *imageData;
	__unsafe_unretained NSString *internalID;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
} MMapThumbnailAttributes;

extern const struct MMapThumbnailRelationships {
	__unsafe_unretained NSString *point;
} MMapThumbnailRelationships;

extern const struct MMapThumbnailFetchedProperties {
} MMapThumbnailFetchedProperties;

@class MPoint;






@interface MMapThumbnailID : NSManagedObjectID {}
@end

@interface _MMapThumbnail : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MMapThumbnailID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					@property (nonatomic, strong) NSData* imageData;
				
			
		

		

	//- (BOOL)validateImageData:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MMapThumbnail__PROTECTED__
					@property (nonatomic, strong, readonly) NSNumber* internalID;
					#else
					@property (nonatomic, strong) NSNumber* internalID;
					#endif
				
			
		

		
			
				
					#ifndef __MMapThumbnail__PROTECTED__
					@property (readonly) int64_t internalIDValue;
					- (int64_t)internalIDValue;
					#else
					@property int64_t internalIDValue;
					- (int64_t)internalIDValue;
					- (void)setInternalIDValue:(int64_t)value_;
					#endif
				
			
		

	//- (BOOL)validateInternalID:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
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
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	
		
			
				@property (nonatomic, strong) MPoint *point;
			
		

		//- (BOOL)validatePoint:(id*)value_ error:(NSError**)error_;

	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end



@interface _MMapThumbnail (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveImageData;
- (void)setPrimitiveImageData:(NSData*)value;




- (NSNumber*)primitiveInternalID;
- (void)setPrimitiveInternalID:(NSNumber*)value;

- (int64_t)primitiveInternalIDValue;
- (void)setPrimitiveInternalIDValue:(int64_t)value_;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;





- (MPoint*)primitivePoint;
- (void)setPrimitivePoint:(MPoint*)value;


@end
