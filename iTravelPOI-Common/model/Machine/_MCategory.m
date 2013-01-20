// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MCategory.m instead.

#import "_MCategory.h"

const struct MCategoryAttributes MCategoryAttributes = {
	.iconHREF = @"iconHREF",
	.viewCount = @"viewCount",
};

const struct MCategoryRelationships MCategoryRelationships = {
	.mapViewCounts = @"mapViewCounts",
	.parent = @"parent",
	.points = @"points",
	.subCategories = @"subCategories",
};

const struct MCategoryFetchedProperties MCategoryFetchedProperties = {
	.allPointsInMap = @"allPointsInMap",
};

@implementation MCategoryID
@end

@implementation _MCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MCategory" inManagedObjectContext:moc_];
}

- (MCategoryID*)objectID {
	return (MCategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic iconHREF;






@dynamic viewCount;






@dynamic mapViewCounts;

	
- (NSMutableSet*)mapViewCountsSet {
	[self willAccessValueForKey:@"mapViewCounts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"mapViewCounts"];
  
	[self didAccessValueForKey:@"mapViewCounts"];
	return result;
}
	

@dynamic parent;

	

@dynamic points;

	
- (NSMutableSet*)pointsSet {
	[self willAccessValueForKey:@"points"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"points"];
  
	[self didAccessValueForKey:@"points"];
	return result;
}
	

@dynamic subCategories;

	
- (NSMutableSet*)subCategoriesSet {
	[self willAccessValueForKey:@"subCategories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subCategories"];
  
	[self didAccessValueForKey:@"subCategories"];
	return result;
}
	



@dynamic allPointsInMap;




@end
