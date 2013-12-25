//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MMap.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MBaseSync.h"


extern const struct MMapAttributes {
	__unsafe_unretained NSString *summary;
} MMapAttributes;

extern const struct MMapRelationships {
	__unsafe_unretained NSString *points;
} MMapRelationships;

extern const struct MMapFetchedProperties {
} MMapFetchedProperties;

@class MPoint;



@interface MMapID : NSManagedObjectID {}
@end

@interface _MMap : MBaseSync {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MMapID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					@property (nonatomic, strong) NSString* summary;
				
			
		

		

	//- (BOOL)validateSummary:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		

			
				@property (nonatomic, strong) NSSet *points;
			


		


		
			- (NSMutableSet*)pointsSet;
		


	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end


@interface _MMap (PointsCoreDataGeneratedAccessors)
- (void)addPoints:(NSSet*)value_;
- (void)removePoints:(NSSet*)value_;
- (void)addPointsObject:(MPoint*)value_;
- (void)removePointsObject:(MPoint*)value_;
@end


@interface _MMap (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveSummary;
- (void)setPrimitiveSummary:(NSString*)value;





- (NSMutableSet*)primitivePoints;
- (void)setPrimitivePoints:(NSMutableSet*)value;


@end
