//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MBaseGMSync.m instead.
//*********************************************************************************************************************


#define __MBaseGMSync__PROTECTED__


#import "_MBaseGMSync.h"

const struct MBaseGMSyncAttributes MBaseGMSyncAttributes = {
	.etag = @"etag",
	.gmID = @"gmID",
	.markedAsDeleted = @"markedAsDeleted",
	.modifiedSinceLastSync = @"modifiedSinceLastSync",
};

const struct MBaseGMSyncRelationships MBaseGMSyncRelationships = {
};

const struct MBaseGMSyncFetchedProperties MBaseGMSyncFetchedProperties = {
};

@implementation MBaseGMSyncID
@end

@implementation _MBaseGMSync

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MBaseGMSync" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MBaseGMSync";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MBaseGMSync" inManagedObjectContext:moc_];
}

- (MBaseGMSyncID*)objectID {
	return (MBaseGMSyncID*)[super objectID];
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










@end




