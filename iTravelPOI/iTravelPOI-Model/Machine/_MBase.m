//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBase.m instead.
//*********************************************************************************************************************


#define __MBase__PROTECTED__


#import "_MBase.h"

const struct MBaseAttributes MBaseAttributes = {
	.name = @"name",
	.tCreation = @"tCreation",
	.tUpdate = @"tUpdate",
};

const struct MBaseRelationships MBaseRelationships = {
	.icon = @"icon",
};

const struct MBaseFetchedProperties MBaseFetchedProperties = {
};

@implementation MBaseID
@end

@implementation _MBase

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MBase" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MBase";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MBase" inManagedObjectContext:moc_];
}

- (MBaseID*)objectID {
	return (MBaseID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic tCreation;






@dynamic tUpdate;






@dynamic icon;

	






@end




