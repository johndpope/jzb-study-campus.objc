//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MCoordinate.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct MCoordinateAttributes {
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
} MCoordinateAttributes;

extern const struct MCoordinateRelationships {
	__unsafe_unretained NSString *placemark;
} MCoordinateRelationships;

extern const struct MCoordinateFetchedProperties {
} MCoordinateFetchedProperties;

@class MPolyLine;




@interface MCoordinateID : NSManagedObjectID {}
@end

@interface _MCoordinate : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MCoordinateID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
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


	
		
			
				#ifndef __MCoordinate__PROTECTED__
				@property (nonatomic, strong, readonly) MPolyLine *placemark;
				#else
				@property (nonatomic, strong) MPolyLine *placemark;
				#endif
			
		

		//- (BOOL)validatePlacemark:(id*)value_ error:(NSError**)error_;

	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end



@interface _MCoordinate (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;





- (MPolyLine*)primitivePlacemark;
- (void)setPrimitivePlacemark:(MPolyLine*)value;


@end
