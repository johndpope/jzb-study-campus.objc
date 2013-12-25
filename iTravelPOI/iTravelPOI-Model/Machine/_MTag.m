//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTag.m instead.
//*********************************************************************************************************************


#define __MTag__PROTECTED__


#import "_MTag.h"

const struct MTagAttributes MTagAttributes = {
	.isAutoTag = @"isAutoTag",
};

const struct MTagRelationships MTagRelationships = {
	.points = @"points",
};

const struct MTagFetchedProperties MTagFetchedProperties = {
};

@implementation MTagID
@end

@implementation _MTag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MTag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MTag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MTag" inManagedObjectContext:moc_];
}

- (MTagID*)objectID {
	return (MTagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isAutoTagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isAutoTag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic isAutoTag;



- (BOOL)isAutoTagValue {
	NSNumber *result = [self isAutoTag];
	return [result boolValue];
}


- (void)setIsAutoTagValue:(BOOL)value_ {
	[self setIsAutoTag:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveIsAutoTagValue {
	NSNumber *result = [self primitiveIsAutoTag];
	return [result boolValue];
}

- (void)setPrimitiveIsAutoTagValue:(BOOL)value_ {
	[self setPrimitiveIsAutoTag:[NSNumber numberWithBool:value_]];
}





@dynamic points;

	
- (NSMutableSet*)pointsSet {
	[self willAccessValueForKey:@"points"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"points"];
  
	[self didAccessValueForKey:@"points"];
	return result;
}
	






@end




