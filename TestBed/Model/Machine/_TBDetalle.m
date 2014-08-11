//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBDetalle.m instead.
//*********************************************************************************************************************


#define __TBDetalle__PROTECTED__


#import "_TBDetalle.h"

const struct TBDetalleAttributes TBDetalleAttributes = {
	.nombre = @"nombre",
};

const struct TBDetalleRelationships TBDetalleRelationships = {
	.maestro = @"maestro",
};

const struct TBDetalleFetchedProperties TBDetalleFetchedProperties = {
};

@implementation TBDetalleID
@end

@implementation _TBDetalle

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TBDetalle" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TBDetalle";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TBDetalle" inManagedObjectContext:moc_];
}

- (TBDetalleID*)objectID {
	return (TBDetalleID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic nombre;






@dynamic maestro;

	






@end




