//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTag.m instead.
//*********************************************************************************************************************


#define __MTag__PROTECTED__


#import "_MTag.h"

const struct MTagAttributes MTagAttributes = {
	.isAutoTag = @"isAutoTag",
	.level = @"level",
	.rootID = @"rootID",
	.shortName = @"shortName",
};

const struct MTagRelationships MTagRelationships = {
	.parent = @"parent",
	.points = @"points",
	.subtags = @"subtags",
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
	if ([key isEqualToString:@"levelValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"level"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rootIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rootID"];
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





@dynamic level;



- (int16_t)levelValue {
	NSNumber *result = [self level];
	return [result shortValue];
}


- (void)setLevelValue:(int16_t)value_ {
	[self setLevel:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveLevelValue {
	NSNumber *result = [self primitiveLevel];
	return [result shortValue];
}

- (void)setPrimitiveLevelValue:(int16_t)value_ {
	[self setPrimitiveLevel:[NSNumber numberWithShort:value_]];
}





@dynamic rootID;



- (int16_t)rootIDValue {
	NSNumber *result = [self rootID];
	return [result shortValue];
}


- (void)setRootIDValue:(int16_t)value_ {
	[self setRootID:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveRootIDValue {
	NSNumber *result = [self primitiveRootID];
	return [result shortValue];
}

- (void)setPrimitiveRootIDValue:(int16_t)value_ {
	[self setPrimitiveRootID:[NSNumber numberWithShort:value_]];
}





@dynamic shortName;






@dynamic parent;

	

@dynamic points;

	
- (NSMutableSet*)pointsSet {
	[self willAccessValueForKey:@"points"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"points"];
  
	[self didAccessValueForKey:@"points"];
	return result;
}
	

@dynamic subtags;

	
- (NSMutableSet*)subtagsSet {
	[self willAccessValueForKey:@"subtags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subtags"];
  
	[self didAccessValueForKey:@"subtags"];
	return result;
}
	






@end




