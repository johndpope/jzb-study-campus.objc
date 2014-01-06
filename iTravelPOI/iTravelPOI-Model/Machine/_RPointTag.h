//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RPointTag.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct RPointTagAttributes {
	__unsafe_unretained NSString *isDirect;
} RPointTagAttributes;

extern const struct RPointTagRelationships {
	__unsafe_unretained NSString *point;
	__unsafe_unretained NSString *tag;
} RPointTagRelationships;

extern const struct RPointTagFetchedProperties {
} RPointTagFetchedProperties;

@class MPoint;
@class MTag;



@interface RPointTagID : NSManagedObjectID {}
@end

@interface _RPointTag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RPointTagID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					#ifndef __RPointTag__PROTECTED__
					  @property (nonatomic, strong, readonly) NSNumber* isDirect;
					#else
					  @property (nonatomic, strong) NSNumber* isDirect;
					#endif
				
			
		

		
			
				
					#ifndef __RPointTag__PROTECTED__
					  @property (readonly) BOOL isDirectValue;
					  - (BOOL) isDirectValue;
					#else
					@property BOOL isDirectValue;
					  - (BOOL) isDirectValue;
					  - (void) setIsDirectValue:(BOOL)value_;
					#endif
				
			
		

	//- (BOOL)validateIsDirect:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	
		
			
				#ifndef __RPointTag__PROTECTED__
				@property (nonatomic, strong, readonly) MPoint *point;
				#else
				@property (nonatomic, strong) MPoint *point;
				#endif
			
		

		//- (BOOL)validatePoint:(id*)value_ error:(NSError**)error_;

	



	
		
			
				#ifndef __RPointTag__PROTECTED__
				@property (nonatomic, strong, readonly) MTag *tag;
				#else
				@property (nonatomic, strong) MTag *tag;
				#endif
			
		

		//- (BOOL)validateTag:(id*)value_ error:(NSError**)error_;

	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end



@interface _RPointTag (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsDirect;
- (void)setPrimitiveIsDirect:(NSNumber*)value;

- (BOOL)primitiveIsDirectValue;
- (void)setPrimitiveIsDirectValue:(BOOL)value_;





- (MPoint*)primitivePoint;
- (void)setPrimitivePoint:(MPoint*)value;



- (MTag*)primitiveTag;
- (void)setPrimitiveTag:(MTag*)value;


@end
