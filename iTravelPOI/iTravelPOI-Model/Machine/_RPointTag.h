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


	

		
			
				
					@property (nonatomic, strong) NSNumber* isDirect;
				
			
		

		
			
				
					@property BOOL isDirectValue;
					- (BOOL)isDirectValue;
					- (void)setIsDirectValue:(BOOL)value_;
				
			
		

	//- (BOOL)validateIsDirect:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	
		
			
				@property (nonatomic, strong) MPoint *point;
			
		

		//- (BOOL)validatePoint:(id*)value_ error:(NSError**)error_;

	



	
		
			
				@property (nonatomic, strong) MTag *tag;
			
		

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
