//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RMCViewCount.m instead.
//*********************************************************************************************************************


#define __RMCViewCount__PROTECTED__


#import "_RMCViewCount.h"

const struct RMCViewCountAttributes RMCViewCountAttributes = {
	.internalID = @"internalID",
	.viewCount = @"viewCount",
};

const struct RMCViewCountRelationships RMCViewCountRelationships = {
	.category = @"category",
	.map = @"map",
};

const struct RMCViewCountFetchedProperties RMCViewCountFetchedProperties = {
};

@implementation RMCViewCountID
@end

@implementation _RMCViewCount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RMCViewCount" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RMCViewCount";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RMCViewCount" inManagedObjectContext:moc_];
}

- (RMCViewCountID*)objectID {
	return (RMCViewCountID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"internalIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"internalID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"viewCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"viewCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic internalID;



- (int64_t)internalIDValue {
	NSNumber *result = [self internalID];
	return [result longLongValue];
}


- (void)setInternalIDValue:(int64_t)value_ {
	[self setInternalID:[NSNumber numberWithLongLong:value_]];
}


- (int64_t)primitiveInternalIDValue {
	NSNumber *result = [self primitiveInternalID];
	return [result longLongValue];
}

- (void)setPrimitiveInternalIDValue:(int64_t)value_ {
	[self setPrimitiveInternalID:[NSNumber numberWithLongLong:value_]];
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




