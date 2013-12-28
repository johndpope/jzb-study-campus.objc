//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RTagSubtag.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct RTagSubtagAttributes {
	__unsafe_unretained NSString *isDirect;
} RTagSubtagAttributes;

extern const struct RTagSubtagRelationships {
	__unsafe_unretained NSString *childTag;
	__unsafe_unretained NSString *parentTag;
} RTagSubtagRelationships;

extern const struct RTagSubtagFetchedProperties {
} RTagSubtagFetchedProperties;

@class MTag;
@class MTag;



@interface RTagSubtagID : NSManagedObjectID {}
@end

@interface _RTagSubtag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RTagSubtagID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					@property (nonatomic, strong) NSNumber* isDirect;
				
			
		

		
			
				
					@property BOOL isDirectValue;
					- (BOOL)isDirectValue;
					- (void)setIsDirectValue:(BOOL)value_;
				
			
		

	//- (BOOL)validateIsDirect:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	
		
			
				@property (nonatomic, strong) MTag *childTag;
			
		

		//- (BOOL)validateChildTag:(id*)value_ error:(NSError**)error_;

	



	
		
			
				@property (nonatomic, strong) MTag *parentTag;
			
		

		//- (BOOL)validateParentTag:(id*)value_ error:(NSError**)error_;

	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end



@interface _RTagSubtag (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsDirect;
- (void)setPrimitiveIsDirect:(NSNumber*)value;

- (BOOL)primitiveIsDirectValue;
- (void)setPrimitiveIsDirectValue:(BOOL)value_;





- (MTag*)primitiveChildTag;
- (void)setPrimitiveChildTag:(MTag*)value;



- (MTag*)primitiveParentTag;
- (void)setPrimitiveParentTag:(MTag*)value;


@end
