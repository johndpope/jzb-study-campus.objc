//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTag.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MBase.h"


extern const struct MTagAttributes {
	__unsafe_unretained NSString *isAutoTag;
} MTagAttributes;

extern const struct MTagRelationships {
	__unsafe_unretained NSString *points;
} MTagRelationships;

extern const struct MTagFetchedProperties {
} MTagFetchedProperties;

@class MPoint;



@interface MTagID : NSManagedObjectID {}
@end

@interface _MTag : MBase {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTagID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					#ifndef __MTag__PROTECTED__
					@property (nonatomic, strong, readonly) NSNumber* isAutoTag;
					#else
					@property (nonatomic, strong) NSNumber* isAutoTag;
					#endif
				
			
		

		
			
				
					#ifndef __MTag__PROTECTED__
					@property (readonly) BOOL isAutoTagValue;
					- (BOOL)isAutoTagValue;
					#else
					@property BOOL isAutoTagValue;
					- (BOOL)isAutoTagValue;
					- (void)setIsAutoTagValue:(BOOL)value_;
					#endif
				
			
		

	//- (BOOL)validateIsAutoTag:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		

			
				@property (nonatomic, strong) NSSet *points;
			


		


		
			- (NSMutableSet*)pointsSet;
		


	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end


@interface _MTag (PointsCoreDataGeneratedAccessors)
- (void)addPoints:(NSSet*)value_;
- (void)removePoints:(NSSet*)value_;
- (void)addPointsObject:(MPoint*)value_;
- (void)removePointsObject:(MPoint*)value_;
@end


@interface _MTag (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsAutoTag;
- (void)setPrimitiveIsAutoTag:(NSNumber*)value;

- (BOOL)primitiveIsAutoTagValue;
- (void)setPrimitiveIsAutoTagValue:(BOOL)value_;





- (NSMutableSet*)primitivePoints;
- (void)setPrimitivePoints:(NSMutableSet*)value;


@end
