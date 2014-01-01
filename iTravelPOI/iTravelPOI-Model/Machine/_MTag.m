//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTag.m instead.
//*********************************************************************************************************************


#define __MTag__PROTECTED__


#import "_MTag.h"

const struct MTagAttributes MTagAttributes = {
	.isAutoTag = @"isAutoTag",
	.shortName = @"shortName",
};

const struct MTagRelationships MTagRelationships = {
	.ancestors = @"ancestors",
	.children = @"children",
	.descendants = @"descendants",
	.parent = @"parent",
	.rPoints = @"rPoints",
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





@dynamic shortName;






@dynamic ancestors;

	
- (NSMutableSet*)ancestorsSet {
	[self willAccessValueForKey:@"ancestors"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"ancestors"];
  
	[self didAccessValueForKey:@"ancestors"];
	return result;
}
	

@dynamic children;

	
- (NSMutableSet*)childrenSet {
	[self willAccessValueForKey:@"children"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"children"];
  
	[self didAccessValueForKey:@"children"];
	return result;
}
	

@dynamic descendants;

	
- (NSMutableSet*)descendantsSet {
	[self willAccessValueForKey:@"descendants"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"descendants"];
  
	[self didAccessValueForKey:@"descendants"];
	return result;
}
	

@dynamic parent;

	

@dynamic rPoints;

	
- (NSMutableSet*)rPointsSet {
	[self willAccessValueForKey:@"rPoints"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"rPoints"];
  
	[self didAccessValueForKey:@"rPoints"];
	return result;
}
	






@end




