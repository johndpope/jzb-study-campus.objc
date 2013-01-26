// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseEntity.m instead.

#define __MBaseEntity__PROTECTED__


#import "_MBaseEntity.h"

const struct MBaseEntityAttributes MBaseEntityAttributes = {
	.etag = @"etag",
	.gmID = @"gmID",
	.markedAsDeleted = @"markedAsDeleted",
	.modifiedSinceLastSync = @"modifiedSinceLastSync",
	.name = @"name",
	.published_Date = @"published_Date",
	.updated_Date = @"updated_Date",
};

const struct MBaseEntityRelationships MBaseEntityRelationships = {
};

const struct MBaseEntityFetchedProperties MBaseEntityFetchedProperties = {
};

@implementation MBaseEntityID
@end

@implementation _MBaseEntity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MBaseEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MBaseEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MBaseEntity" inManagedObjectContext:moc_];
}

- (MBaseEntityID*)objectID {
	return (MBaseEntityID*)[super objectID];
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





@dynamic name;






@dynamic published_Date;






@dynamic updated_Date;











@end




