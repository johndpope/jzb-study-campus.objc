//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseEntity.h instead.
//*********************************************************************************************************************

#import <CoreData/CoreData.h>



extern const struct MBaseEntityAttributes {
	__unsafe_unretained NSString *iconBaseHREF;
	__unsafe_unretained NSString *iconExtraInfo;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *published_date;
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








#ifndef __MBaseEntity__PROTECTED__
@property (nonatomic, strong, readonly) NSString* iconBaseHREF;
#else
@property (nonatomic, strong) NSString* iconBaseHREF;
#endif






//- (BOOL)validateIconBaseHREF:(id*)value_ error:(NSError**)error_;








#ifndef __MBaseEntity__PROTECTED__
@property (nonatomic, strong, readonly) NSString* iconExtraInfo;
#else
@property (nonatomic, strong) NSString* iconExtraInfo;
#endif






//- (BOOL)validateIconExtraInfo:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSString* name;






//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSDate* published_date;






//- (BOOL)validatePublished_date:(id*)value_ error:(NSError**)error_;








@property (nonatomic, strong) NSDate* updated_date;






//- (BOOL)validateUpdated_date:(id*)value_ error:(NSError**)error_;






@end



@interface _MBaseEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveIconBaseHREF;
- (void)setPrimitiveIconBaseHREF:(NSString*)value;




- (NSString*)primitiveIconExtraInfo;
- (void)setPrimitiveIconExtraInfo:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSDate*)primitivePublished_date;
- (void)setPrimitivePublished_date:(NSDate*)value;




- (NSDate*)primitiveUpdated_date;
- (void)setPrimitiveUpdated_date:(NSDate*)value;




@end
