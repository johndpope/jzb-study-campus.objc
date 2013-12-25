//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseSync.m instead.
//*********************************************************************************************************************


#define __MBaseSync__PROTECTED__


#import "_MBaseSync.h"

const struct MBaseSyncAttributes MBaseSyncAttributes = {
	.etag = @"etag",
	.gID = @"gID",
	.markedAsDeleted = @"markedAsDeleted",
	.modifiedSinceLastSync = @"modifiedSinceLastSync",
};

const struct MBaseSyncRelationships MBaseSyncRelationships = {
};

const struct MBaseSyncFetchedProperties MBaseSyncFetchedProperties = {
};

@implementation MBaseSyncID
@end

@implementation _MBaseSync

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MBaseSync" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MBaseSync";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MBaseSync" inManagedObjectContext:moc_];
}

- (MBaseSyncID*)objectID {
	return (MBaseSyncID*)[super objectID];
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






@dynamic gID;






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










@end




