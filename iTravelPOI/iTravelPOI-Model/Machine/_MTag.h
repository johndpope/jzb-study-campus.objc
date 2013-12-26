//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTag.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MBase.h"


extern const struct MTagAttributes {
	__unsafe_unretained NSString *isAutoTag;
	__unsafe_unretained NSString *level;
	__unsafe_unretained NSString *rootID;
	__unsafe_unretained NSString *shortName;
} MTagAttributes;

extern const struct MTagRelationships {
	__unsafe_unretained NSString *parent;
	__unsafe_unretained NSString *points;
	__unsafe_unretained NSString *subtags;
} MTagRelationships;

extern const struct MTagFetchedProperties {
} MTagFetchedProperties;

@class MTag;
@class MPoint;
@class MTag;






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
	
	



	

		
			
				
					@property (nonatomic, strong) NSNumber* level;
				
			
		

		
			
				
					@property int16_t levelValue;
					- (int16_t)levelValue;
					- (void)setLevelValue:(int16_t)value_;
				
			
		

	//- (BOOL)validateLevel:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					@property (nonatomic, strong) NSNumber* rootID;
				
			
		

		
			
				
					@property int16_t rootIDValue;
					- (int16_t)rootIDValue;
					- (void)setRootIDValue:(int16_t)value_;
				
			
		

	//- (BOOL)validateRootID:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					@property (nonatomic, strong) NSString* shortName;
				
			
		

		

	//- (BOOL)validateShortName:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	
		
			
				@property (nonatomic, strong) MTag *parent;
			
		

		//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;

	



	

		

			
				@property (nonatomic, strong) NSSet *points;
			


		


		
			- (NSMutableSet*)pointsSet;
		


	



	

		

			
				@property (nonatomic, strong) NSSet *subtags;
			


		


		
			- (NSMutableSet*)subtagsSet;
		


	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end


@interface _MTag (PointsCoreDataGeneratedAccessors)
- (void)addPoints:(NSSet*)value_;
- (void)removePoints:(NSSet*)value_;
- (void)addPointsObject:(MPoint*)value_;
- (void)removePointsObject:(MPoint*)value_;
@end

@interface _MTag (SubtagsCoreDataGeneratedAccessors)
- (void)addSubtags:(NSSet*)value_;
- (void)removeSubtags:(NSSet*)value_;
- (void)addSubtagsObject:(MTag*)value_;
- (void)removeSubtagsObject:(MTag*)value_;
@end


@interface _MTag (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsAutoTag;
- (void)setPrimitiveIsAutoTag:(NSNumber*)value;

- (BOOL)primitiveIsAutoTagValue;
- (void)setPrimitiveIsAutoTagValue:(BOOL)value_;




- (NSNumber*)primitiveLevel;
- (void)setPrimitiveLevel:(NSNumber*)value;

- (int16_t)primitiveLevelValue;
- (void)setPrimitiveLevelValue:(int16_t)value_;




- (NSNumber*)primitiveRootID;
- (void)setPrimitiveRootID:(NSNumber*)value;

- (int16_t)primitiveRootIDValue;
- (void)setPrimitiveRootIDValue:(int16_t)value_;




- (NSString*)primitiveShortName;
- (void)setPrimitiveShortName:(NSString*)value;





- (MTag*)primitiveParent;
- (void)setPrimitiveParent:(MTag*)value;



- (NSMutableSet*)primitivePoints;
- (void)setPrimitivePoints:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSubtags;
- (void)setPrimitiveSubtags:(NSMutableSet*)value;


@end
