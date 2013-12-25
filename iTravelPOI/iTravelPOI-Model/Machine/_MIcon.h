//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MIcon.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct MIconAttributes {
	__unsafe_unretained NSString *iconHREF;
	__unsafe_unretained NSString *name;
} MIconAttributes;

extern const struct MIconRelationships {
	__unsafe_unretained NSString *tag;
} MIconRelationships;

extern const struct MIconFetchedProperties {
} MIconFetchedProperties;

@class MTag;




@interface MIconID : NSManagedObjectID {}
@end

@interface _MIcon : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MIconID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					#ifndef __MIcon__PROTECTED__
					@property (nonatomic, strong, readonly) NSString* iconHREF;
					#else
					@property (nonatomic, strong) NSString* iconHREF;
					#endif
				
			
		

		

	//- (BOOL)validateIconHREF:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MIcon__PROTECTED__
					@property (nonatomic, strong, readonly) NSString* name;
					#else
					@property (nonatomic, strong) NSString* name;
					#endif
				
			
		

		

	//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	
		
			
				#ifndef __MIcon__PROTECTED__
				@property (nonatomic, strong, readonly) MTag *tag;
				#else
				@property (nonatomic, strong) MTag *tag;
				#endif
			
		

		//- (BOOL)validateTag:(id*)value_ error:(NSError**)error_;

	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end



@interface _MIcon (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveIconHREF;
- (void)setPrimitiveIconHREF:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (MTag*)primitiveTag;
- (void)setPrimitiveTag:(MTag*)value;


@end
