// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MMap.m instead.

#import "_MMap.h"

const struct MMapAttributes MMapAttributes = {
	.summary = @"summary",
	.viewCount = @"viewCount",
};

const struct MMapRelationships MMapRelationships = {
	.catViewCounts = @"catViewCounts",
	.points = @"points",
};

const struct MMapFetchedProperties MMapFetchedProperties = {
};

@implementation MMapID
@end

@implementation _MMap

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MMap" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MMap";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MMap" inManagedObjectContext:moc_];
}

- (MMapID*)objectID {
	return (MMapID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic summary;






@dynamic viewCount;






@dynamic catViewCounts;

	
- (NSMutableSet*)catViewCountsSet {
	[self willAccessValueForKey:@"catViewCounts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"catViewCounts"];
  
	[self didAccessValueForKey:@"catViewCounts"];
	return result;
}
	

@dynamic points;

	
- (NSMutableSet*)pointsSet {
	[self willAccessValueForKey:@"points"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"points"];
  
	[self didAccessValueForKey:@"points"];
	return result;
}
	






@end
