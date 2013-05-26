//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MMapThumbnail.m instead.
//*********************************************************************************************************************


#define __MMapThumbnail__PROTECTED__


#import "_MMapThumbnail.h"

const struct MMapThumbnailAttributes MMapThumbnailAttributes = {
	.imageData = @"imageData",
	.internalID = @"internalID",
	.latitude = @"latitude",
	.longitude = @"longitude",
};

const struct MMapThumbnailRelationships MMapThumbnailRelationships = {
	.point = @"point",
};

const struct MMapThumbnailFetchedProperties MMapThumbnailFetchedProperties = {
};

@implementation MMapThumbnailID
@end

@implementation _MMapThumbnail

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MMapThumbnail" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MMapThumbnail";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MMapThumbnail" inManagedObjectContext:moc_];
}

- (MMapThumbnailID*)objectID {
	return (MMapThumbnailID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"internalIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"internalID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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




@dynamic imageData;






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





@dynamic point;

	






@end




