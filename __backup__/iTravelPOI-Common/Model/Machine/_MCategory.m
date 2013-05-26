//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MCategory.m instead.
//*********************************************************************************************************************


#define __MCategory__PROTECTED__


#import "_MCategory.h"

const struct MCategoryAttributes MCategoryAttributes = {
	.fullName = @"fullName",
	.iconBaseHREF = @"iconBaseHREF",
	.viewCount = @"viewCount",
};

const struct MCategoryRelationships MCategoryRelationships = {
	.mapViewCounts = @"mapViewCounts",
	.parent = @"parent",
	.points = @"points",
	.subCategories = @"subCategories",
};

const struct MCategoryFetchedProperties MCategoryFetchedProperties = {
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
	
	if ([key isEqualToString:@"viewCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"viewCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic fullName;






@dynamic iconBaseHREF;






@dynamic viewCount;



- (int16_t)viewCountValue {
	NSNumber *result = [self viewCount];
	return [result shortValue];
}


- (void)setViewCountValue:(int16_t)value_ {
	[self setViewCount:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveViewCountValue {
	NSNumber *result = [self primitiveViewCount];
	return [result shortValue];
}

- (void)setPrimitiveViewCountValue:(int16_t)value_ {
	[self setPrimitiveViewCount:[NSNumber numberWithShort:value_]];
}





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
	






@end




