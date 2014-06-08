//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MPolyLine.m instead.
//*********************************************************************************************************************


#define __MPolyLine__PROTECTED__


#import "_MPolyLine.h"

const struct MPolyLineAttributes MPolyLineAttributes = {
	.hexColor = @"hexColor",
};

const struct MPolyLineRelationships MPolyLineRelationships = {
	.coordinates = @"coordinates",
};

const struct MPolyLineFetchedProperties MPolyLineFetchedProperties = {
};

@implementation MPolyLineID
@end

@implementation _MPolyLine

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MPolyLine" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MPolyLine";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MPolyLine" inManagedObjectContext:moc_];
}

- (MPolyLineID*)objectID {
	return (MPolyLineID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"hexColorValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hexColor"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic hexColor;



- (int32_t)hexColorValue {
	NSNumber *result = [self hexColor];
	return [result intValue];
}


- (void)setHexColorValue:(int32_t)value_ {
	[self setHexColor:[NSNumber numberWithInt:value_]];
}


- (int32_t)primitiveHexColorValue {
	NSNumber *result = [self primitiveHexColor];
	return [result intValue];
}

- (void)setPrimitiveHexColorValue:(int32_t)value_ {
	[self setPrimitiveHexColor:[NSNumber numberWithInt:value_]];
}





@dynamic coordinates;

	
- (NSMutableOrderedSet*)coordinatesSet {
	[self willAccessValueForKey:@"coordinates"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"coordinates"];
  
	[self didAccessValueForKey:@"coordinates"];
	return result;
}
	






@end


@implementation _MPolyLine (CoordinatesCoreDataGeneratedAccessors)
- (void)addCoordinates:(NSOrderedSet*)value_ {
	[self.coordinatesSet unionOrderedSet:value_];
}
- (void)removeCoordinates:(NSOrderedSet*)value_ {
	[self.coordinatesSet minusOrderedSet:value_];
}
- (void)addCoordinatesObject:(MCoordinate*)value_ {
	[self.coordinatesSet addObject:value_];
}
- (void)removeCoordinatesObject:(MCoordinate*)value_ {
	[self.coordinatesSet removeObject:value_];
}
@end



