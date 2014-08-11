//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TBMaestro.m instead.
//*********************************************************************************************************************


#define __TBMaestro__PROTECTED__


#import "_TBMaestro.h"

const struct TBMaestroAttributes TBMaestroAttributes = {
	.nombre = @"nombre",
};

const struct TBMaestroRelationships TBMaestroRelationships = {
	.detalles = @"detalles",
};

const struct TBMaestroFetchedProperties TBMaestroFetchedProperties = {
};

@implementation TBMaestroID
@end

@implementation _TBMaestro

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TBMaestro" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TBMaestro";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TBMaestro" inManagedObjectContext:moc_];
}

- (TBMaestroID*)objectID {
	return (TBMaestroID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic nombre;






@dynamic detalles;

	
- (NSMutableSet*)detallesSet {
	[self willAccessValueForKey:@"detalles"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"detalles"];
  
	[self didAccessValueForKey:@"detalles"];
	return result;
}
	






@end




