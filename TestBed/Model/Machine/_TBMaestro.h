//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMaestro.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct TBMaestroAttributes {
	__unsafe_unretained NSString *nombre;
} TBMaestroAttributes;

extern const struct TBMaestroRelationships {
	__unsafe_unretained NSString *detalles;
} TBMaestroRelationships;

extern const struct TBMaestroFetchedProperties {
} TBMaestroFetchedProperties;

@class TBDetalle;



@interface TBMaestroID : NSManagedObjectID {}
@end

@interface _TBMaestro : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TBMaestroID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					@property (nonatomic, strong) NSString* nombre;
				
			
		

		

	//- (BOOL)validateNombre:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		

			
				@property (nonatomic, strong) NSSet *detalles;
			


		


		
			- (NSMutableSet*)detallesSet;
		


	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end


@interface _TBMaestro (DetallesCoreDataGeneratedAccessors)
- (void)addDetalles:(NSSet*)value_;
- (void)removeDetalles:(NSSet*)value_;
- (void)addDetallesObject:(TBDetalle*)value_;
- (void)removeDetallesObject:(TBDetalle*)value_;
@end


@interface _TBMaestro (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveNombre;
- (void)setPrimitiveNombre:(NSString*)value;





- (NSMutableSet*)primitiveDetalles;
- (void)setPrimitiveDetalles:(NSMutableSet*)value;


@end
