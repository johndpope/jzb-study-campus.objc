//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseEntity.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct MBaseEntityAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *updated_date;
} MBaseEntityAttributes;

extern const struct MBaseEntityRelationships {
} MBaseEntityRelationships;

extern const struct MBaseEntityFetchedProperties {
} MBaseEntityFetchedProperties;





@interface MBaseEntityID : NSManagedObjectID {}
@end

@interface _MBaseEntity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MBaseEntityID*)objectID;








@property (nonatomic, strong) NSString* name;






//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSDate* updated_date;






//- (BOOL)validateUpdated_date:(id*)value_ error:(NSError**)error_;






@end



@interface _MBaseEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSDate*)primitiveUpdated_date;
- (void)setPrimitiveUpdated_date:(NSDate*)value;




@end
