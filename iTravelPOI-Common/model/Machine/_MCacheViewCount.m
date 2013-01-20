// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MCacheViewCount.m instead.

#import "_MCacheViewCount.h"

const struct MCacheViewCountAttributes MCacheViewCountAttributes = {
	.viewCount = @"viewCount",
};

const struct MCacheViewCountRelationships MCacheViewCountRelationships = {
	.category = @"category",
	.map = @"map",
};

const struct MCacheViewCountFetchedProperties MCacheViewCountFetchedProperties = {
};

@implementation MCacheViewCountID
@end

@implementation _MCacheViewCount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MCacheViewCount" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MCacheViewCount";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MCacheViewCount" inManagedObjectContext:moc_];
}

- (MCacheViewCountID*)objectID {
	return (MCacheViewCountID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic viewCount;






@dynamic category;

	

@dynamic map;

	






@end
