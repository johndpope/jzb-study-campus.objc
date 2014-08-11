//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBDetalle.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct TBDetalleAttributes {
	__unsafe_unretained NSString *nombre;
} TBDetalleAttributes;

extern const struct TBDetalleRelationships {
	__unsafe_unretained NSString *maestro;
} TBDetalleRelationships;

extern const struct TBDetalleFetchedProperties {
} TBDetalleFetchedProperties;

@class TBMaestro;



@interface TBDetalleID : NSManagedObjectID {}
@end

@interface _TBDetalle : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TBDetalleID*)objectID;



//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	

		
			
				
					@property (nonatomic, strong) NSString* nombre;
				
			
		

		

	//- (BOOL)validateNombre:(id*)value_ error:(NSError**)error_;
	
	





//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------


	
		
			
				@property (nonatomic, strong) TBMaestro *maestro;
			
		

		//- (BOOL)validateMaestro:(id*)value_ error:(NSError**)error_;

	









//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------





@end



@interface _TBDetalle (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveNombre;
- (void)setPrimitiveNombre:(NSString*)value;





- (TBMaestro*)primitiveMaestro;
- (void)setPrimitiveMaestro:(TBMaestro*)value;


@end
