//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTag.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>

#import "MBase.h"


extern const struct MTagAttributes {
	__unsafe_unretained NSString *isAutoTag;
	__unsafe_unretained NSString *shortName;
} MTagAttributes;

extern const struct MTagRelationships {
	__unsafe_unretained NSString *ancestors;
	__unsafe_unretained NSString *children;
	__unsafe_unretained NSString *descendants;
	__unsafe_unretained NSString *parent;
	__unsafe_unretained NSString *rPoints;
} MTagRelationships;

extern const struct MTagFetchedProperties {
} MTagFetchedProperties;

@class MTag;
@class MTag;
@class MTag;
@class MTag;
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
	
	



	

		
			
				
					@property (nonatomic, strong) NSString* shortName;
				
			
		

		

	//- (BOOL)validateShortName:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		

			
				#ifndef __MTag__PROTECTED__
				@property (nonatomic, strong, readonly) NSSet *ancestors;
				#else
				@property (nonatomic, strong) NSSet *ancestors;
				#endif
			


		


		
			#ifndef __MTag__PROTECTED__
			- (NSMutableSet*)ancestorsSet;
			#endif
		


	



	

		

			
				#ifndef __MTag__PROTECTED__
				@property (nonatomic, strong, readonly) NSSet *children;
				#else
				@property (nonatomic, strong) NSSet *children;
				#endif
			


		


		
			#ifndef __MTag__PROTECTED__
			- (NSMutableSet*)childrenSet;
			#endif
		


	



	

		

			
				#ifndef __MTag__PROTECTED__
				@property (nonatomic, strong, readonly) NSSet *descendants;
				#else
				@property (nonatomic, strong) NSSet *descendants;
				#endif
			


		


		
			#ifndef __MTag__PROTECTED__
			- (NSMutableSet*)descendantsSet;
			#endif
		


	



	
		
			
				#ifndef __MTag__PROTECTED__
				@property (nonatomic, strong, readonly) MTag *parent;
				#else
				@property (nonatomic, strong) MTag *parent;
				#endif
			
		

		//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;

	



	

		

			
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


@interface _MTag (AncestorsCoreDataGeneratedAccessors)
- (void)addAncestors:(NSSet*)value_;
- (void)removeAncestors:(NSSet*)value_;
- (void)addAncestorsObject:(MTag*)value_;
- (void)removeAncestorsObject:(MTag*)value_;
@end

@interface _MTag (ChildrenCoreDataGeneratedAccessors)
- (void)addChildren:(NSSet*)value_;
- (void)removeChildren:(NSSet*)value_;
- (void)addChildrenObject:(MTag*)value_;
- (void)removeChildrenObject:(MTag*)value_;
@end

@interface _MTag (DescendantsCoreDataGeneratedAccessors)
- (void)addDescendants:(NSSet*)value_;
- (void)removeDescendants:(NSSet*)value_;
- (void)addDescendantsObject:(MTag*)value_;
- (void)removeDescendantsObject:(MTag*)value_;
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




- (NSString*)primitiveShortName;
- (void)setPrimitiveShortName:(NSString*)value;





- (NSMutableSet*)primitiveAncestors;
- (void)setPrimitiveAncestors:(NSMutableSet*)value;



- (NSMutableSet*)primitiveChildren;
- (void)setPrimitiveChildren:(NSMutableSet*)value;



- (NSMutableSet*)primitiveDescendants;
- (void)setPrimitiveDescendants:(NSMutableSet*)value;



- (MTag*)primitiveParent;
- (void)setPrimitiveParent:(MTag*)value;



- (NSMutableSet*)primitiveRPoints;
- (void)setPrimitiveRPoints:(NSMutableSet*)value;


@end
