//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseEntity.m instead.
//*********************************************************************************************************************


#define __MBaseEntity__PROTECTED__


#import "_MBaseEntity.h"

const struct MBaseEntityAttributes MBaseEntityAttributes = {
	.name = @"name",
	.updated_date = @"updated_date",
};

const struct MBaseEntityRelationships MBaseEntityRelationships = {
};

const struct MBaseEntityFetchedProperties MBaseEntityFetchedProperties = {
};

@implementation MBaseEntityID
@end

@implementation _MBaseEntity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MBaseEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MBaseEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MBaseEntity" inManagedObjectContext:moc_];
}

- (MBaseEntityID*)objectID {
	return (MBaseEntityID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic updated_date;











@end




