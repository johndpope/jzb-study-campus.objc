//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MIcon.m instead.
//*********************************************************************************************************************


#define __MIcon__PROTECTED__


#import "_MIcon.h"

const struct MIconAttributes MIconAttributes = {
	.iconHREF = @"iconHREF",
	.name = @"name",
};

const struct MIconRelationships MIconRelationships = {
	.tag = @"tag",
};

const struct MIconFetchedProperties MIconFetchedProperties = {
};

@implementation MIconID
@end

@implementation _MIcon

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MIcon" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MIcon";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MIcon" inManagedObjectContext:moc_];
}

- (MIconID*)objectID {
	return (MIconID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic iconHREF;






@dynamic name;






@dynamic tag;

	






@end




