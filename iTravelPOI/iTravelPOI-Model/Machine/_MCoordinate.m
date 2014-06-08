//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MCoordinate.m instead.
//*********************************************************************************************************************


#define __MCoordinate__PROTECTED__


#import "_MCoordinate.h"

const struct MCoordinateAttributes MCoordinateAttributes = {
	.latitude = @"latitude",
	.longitude = @"longitude",
};

const struct MCoordinateRelationships MCoordinateRelationships = {
	.placemark = @"placemark",
};

const struct MCoordinateFetchedProperties MCoordinateFetchedProperties = {
};

@implementation MCoordinateID
@end

@implementation _MCoordinate

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MCoordinate" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MCoordinate";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MCoordinate" inManagedObjectContext:moc_];
}

- (MCoordinateID*)objectID {
	return (MCoordinateID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic latitude;



- (double)latitudeValue {
	NSNumber *result = [self latitude];
	return [result doubleValue];
}


- (void)setLatitudeValue:(double)value_ {
	[self setLatitude:[NSNumber numberWithDouble:value_]];
}


- (double)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLatitudeValue:(double)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic longitude;



- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}


- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}


- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic placemark;

	






@end




