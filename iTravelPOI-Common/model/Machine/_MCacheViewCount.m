// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MCacheViewCount.m instead.

#define __MCacheViewCount__PROTECTED__


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
	
	if ([key isEqualToString:@"viewCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"viewCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




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





@dynamic category;

	

@dynamic map;

	






@end




