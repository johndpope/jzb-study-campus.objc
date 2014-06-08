//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MPolyLine.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MPoint.h"


extern const struct MPolyLineAttributes {
	__unsafe_unretained NSString *hexColor;
} MPolyLineAttributes;

extern const struct MPolyLineRelationships {
	__unsafe_unretained NSString *coordinates;
} MPolyLineRelationships;

extern const struct MPolyLineFetchedProperties {
} MPolyLineFetchedProperties;

@class MCoordinate;



@interface MPolyLineID : NSManagedObjectID {}
@end

@interface _MPolyLine : MPoint {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MPolyLineID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					#ifndef __MPolyLine__PROTECTED__
					  @property (nonatomic, strong, readonly) NSNumber* hexColor;
					#else
					  @property (nonatomic, strong) NSNumber* hexColor;
					#endif
				
			
		

		
			
				
					#ifndef __MPolyLine__PROTECTED__
					  @property (readonly) int32_t hexColorValue;
					  - (int32_t) hexColorValue;
					#else
					@property int32_t hexColorValue;
					  - (int32_t) hexColorValue;
					  - (void) setHexColorValue:(int32_t)value_;
					#endif
				
			
		

	//- (BOOL)validateHexColor:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		

			
				#ifndef __MPolyLine__PROTECTED__
				@property (nonatomic, strong, readonly) NSOrderedSet *coordinates;
				#else
				@property (nonatomic, strong) NSOrderedSet *coordinates;
				#endif
			


		


		
			#ifndef __MPolyLine__PROTECTED__
			- (NSMutableOrderedSet*)coordinatesSet;
			#endif
		


	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end


@interface _MPolyLine (CoordinatesCoreDataGeneratedAccessors)
- (void)addCoordinates:(NSOrderedSet*)value_;
- (void)removeCoordinates:(NSOrderedSet*)value_;
- (void)addCoordinatesObject:(MCoordinate*)value_;
- (void)removeCoordinatesObject:(MCoordinate*)value_;
@end


@interface _MPolyLine (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveHexColor;
- (void)setPrimitiveHexColor:(NSNumber*)value;

- (int32_t)primitiveHexColorValue;
- (void)setPrimitiveHexColorValue:(int32_t)value_;





- (NSMutableOrderedSet*)primitiveCoordinates;
- (void)setPrimitiveCoordinates:(NSMutableOrderedSet*)value;


@end
