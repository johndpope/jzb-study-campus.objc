//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseEntity.m instead.
//*********************************************************************************************************************


#define __MBaseEntity__PROTECTED__


#import "_MBaseEntity.h"

const struct MBaseEntityAttributes MBaseEntityAttributes = {
	.creationTime = @"creationTime",
	.etag = @"etag",
	.gID = @"gID",
	.iconHREF = @"iconHREF",
	.internalID = @"internalID",
	.markedAsDeleted = @"markedAsDeleted",
	.modifiedSinceLastSync = @"modifiedSinceLastSync",
	.name = @"name",
	.updateTime = @"updateTime",
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
	
	if ([key isEqualToString:@"internalIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"internalID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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




@dynamic creationTime;






@dynamic etag;






@dynamic gID;






@dynamic iconHREF;






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






@dynamic updateTime;











@end




