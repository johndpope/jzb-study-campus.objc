//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBase.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct MBaseAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *tCreation;
	__unsafe_unretained NSString *tUpdate;
} MBaseAttributes;

extern const struct MBaseRelationships {
	__unsafe_unretained NSString *icon;
} MBaseRelationships;

extern const struct MBaseFetchedProperties {
} MBaseFetchedProperties;

@class MIcon;





@interface MBaseID : NSManagedObjectID {}
@end

@interface _MBase : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MBaseID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					#ifndef __MBase__PROTECTED__
					  @property (nonatomic, strong, readonly) NSString* name;
					#else
					  @property (nonatomic, strong) NSString* name;
					#endif
				
			
		

		

	//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBase__PROTECTED__
					  @property (nonatomic, strong, readonly) NSDate* tCreation;
					#else
					  @property (nonatomic, strong) NSDate* tCreation;
					#endif
				
			
		

		

	//- (BOOL)validateTCreation:(id*)value_ error:(NSError**)error_;
	
	



	

		
			
				
					#ifndef __MBase__PROTECTED__
					  @property (nonatomic, strong, readonly) NSDate* tUpdate;
					#else
					  @property (nonatomic, strong) NSDate* tUpdate;
					#endif
				
			
		

		

	//- (BOOL)validateTUpdate:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	
		
			
				#ifndef __MBase__PROTECTED__
				@property (nonatomic, strong, readonly) MIcon *icon;
				#else
				@property (nonatomic, strong) MIcon *icon;
				#endif
			
		

		//- (BOOL)validateIcon:(id*)value_ error:(NSError**)error_;

	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end



@interface _MBase (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSDate*)primitiveTCreation;
- (void)setPrimitiveTCreation:(NSDate*)value;




- (NSDate*)primitiveTUpdate;
- (void)setPrimitiveTUpdate:(NSDate*)value;





- (MIcon*)primitiveIcon;
- (void)setPrimitiveIcon:(MIcon*)value;


@end
