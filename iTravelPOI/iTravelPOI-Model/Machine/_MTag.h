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
	__unsafe_unretained NSString *otherPointsTag;
	__unsafe_unretained NSString *rChildrenTags;
	__unsafe_unretained NSString *rParentTags;
	__unsafe_unretained NSString *rPoints;
} MTagRelationships;

extern const struct MTagFetchedProperties {
} MTagFetchedProperties;

@class MTag;
@class RTagSubtag;
@class RTagSubtag;
@class RPointTag;






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
					  - (BOOL) isAutoTagValue;
					#else
					@property BOOL isAutoTagValue;
					  - (BOOL) isAutoTagValue;
					  - (void) setIsAutoTagValue:(BOOL)value_;
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


	
		
			
				@property (nonatomic, strong) MTag *otherPointsTag;
			
		

		//- (BOOL)validateOtherPointsTag:(id*)value_ error:(NSError**)error_;

	



	

		

			
				#ifndef __MTag__PROTECTED__
				@property (nonatomic, strong, readonly) NSSet *rChildrenTags;
				#else
				@property (nonatomic, strong) NSSet *rChildrenTags;
				#endif
			


		


		
			#ifndef __MTag__PROTECTED__
			- (NSMutableSet*)rChildrenTagsSet;
			#endif
		


	



	

		

			
				#ifndef __MTag__PROTECTED__
				@property (nonatomic, strong, readonly) NSSet *rParentTags;
				#else
				@property (nonatomic, strong) NSSet *rParentTags;
				#endif
			


		


		
			#ifndef __MTag__PROTECTED__
			- (NSMutableSet*)rParentTagsSet;
			#endif
		


	



	

		

			
				#ifndef __MTag__PROTECTED__
				@property (nonatomic, strong, readonly) NSSet *rPoints;
				#else
				@property (nonatomic, strong) NSSet *rPoints;
				#endif
			


		


		
			#ifndef __MTag__PROTECTED__
			- (NSMutableSet*)rPointsSet;
			#endif
		


	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end


@interface _MTag (RChildrenTagsCoreDataGeneratedAccessors)
- (void)addRChildrenTags:(NSSet*)value_;
- (void)removeRChildrenTags:(NSSet*)value_;
- (void)addRChildrenTagsObject:(RTagSubtag*)value_;
- (void)removeRChildrenTagsObject:(RTagSubtag*)value_;
@end

@interface _MTag (RParentTagsCoreDataGeneratedAccessors)
- (void)addRParentTags:(NSSet*)value_;
- (void)removeRParentTags:(NSSet*)value_;
- (void)addRParentTagsObject:(RTagSubtag*)value_;
- (void)removeRParentTagsObject:(RTagSubtag*)value_;
@end

@interface _MTag (RPointsCoreDataGeneratedAccessors)
- (void)addRPoints:(NSSet*)value_;
- (void)removeRPoints:(NSSet*)value_;
- (void)addRPointsObject:(RPointTag*)value_;
- (void)removeRPointsObject:(RPointTag*)value_;
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





- (MTag*)primitiveOtherPointsTag;
- (void)setPrimitiveOtherPointsTag:(MTag*)value;



- (NSMutableSet*)primitiveRChildrenTags;
- (void)setPrimitiveRChildrenTags:(NSMutableSet*)value;



- (NSMutableSet*)primitiveRParentTags;
- (void)setPrimitiveRParentTags:(NSMutableSet*)value;



- (NSMutableSet*)primitiveRPoints;
- (void)setPrimitiveRPoints:(NSMutableSet*)value;


@end
