//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MMapBaseEntity.m instead.
//*********************************************************************************************************************


#define __MMapBaseEntity__PROTECTED__


#import "_MMapBaseEntity.h"

const struct MMapBaseEntityAttributes MMapBaseEntityAttributes = {
	.etag = @"etag",
	.gmID = @"gmID",
	.markedAsDeleted = @"markedAsDeleted",
	.modifiedSinceLastSync = @"modifiedSinceLastSync",
	.published_date = @"published_date",
};

const struct MMapBaseEntityRelationships MMapBaseEntityRelationships = {
};

const struct MMapBaseEntityFetchedProperties MMapBaseEntityFetchedProperties = {
};

@implementation MMapBaseEntityID
@end

@implementation _MMapBaseEntity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MMapBaseEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MMapBaseEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MMapBaseEntity" inManagedObjectContext:moc_];
}

- (MMapBaseEntityID*)objectID {
	return (MMapBaseEntityID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"markedAsDeletedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"markedAsDeleted"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"modifiedSinceLastSyncValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"modifiedSinceLastSync"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic etag;






@dynamic gmID;






@dynamic markedAsDeleted;



- (BOOL)markedAsDeletedValue {
	NSNumber *result = [self markedAsDeleted];
	return [result boolValue];
}


- (void)setMarkedAsDeletedValue:(BOOL)value_ {
	[self setMarkedAsDeleted:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveMarkedAsDeletedValue {
	NSNumber *result = [self primitiveMarkedAsDeleted];
	return [result boolValue];
}

- (void)setPrimitiveMarkedAsDeletedValue:(BOOL)value_ {
	[self setPrimitiveMarkedAsDeleted:[NSNumber numberWithBool:value_]];
}





@dynamic modifiedSinceLastSync;



- (BOOL)modifiedSinceLastSyncValue {
	NSNumber *result = [self modifiedSinceLastSync];
	return [result boolValue];
}


- (void)setModifiedSinceLastSyncValue:(BOOL)value_ {
	[self setModifiedSinceLastSync:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveModifiedSinceLastSyncValue {
	NSNumber *result = [self primitiveModifiedSinceLastSync];
	return [result boolValue];
}

- (void)setPrimitiveModifiedSinceLastSyncValue:(BOOL)value_ {
	[self setPrimitiveModifiedSinceLastSync:[NSNumber numberWithBool:value_]];
}





@dynamic published_date;











@end




