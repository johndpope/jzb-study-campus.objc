//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RPointTag.m instead.
//*********************************************************************************************************************


#define __RPointTag__PROTECTED__


#import "_RPointTag.h"

const struct RPointTagAttributes RPointTagAttributes = {
	.isDirect = @"isDirect",
};

const struct RPointTagRelationships RPointTagRelationships = {
	.point = @"point",
	.tag = @"tag",
};

const struct RPointTagFetchedProperties RPointTagFetchedProperties = {
};

@implementation RPointTagID
@end

@implementation _RPointTag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RPointTag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RPointTag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RPointTag" inManagedObjectContext:moc_];
}

- (RPointTagID*)objectID {
	return (RPointTagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isDirectValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isDirect"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic isDirect;



- (BOOL)isDirectValue {
	NSNumber *result = [self isDirect];
	return [result boolValue];
}


- (void)setIsDirectValue:(BOOL)value_ {
	[self setIsDirect:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveIsDirectValue {
	NSNumber *result = [self primitiveIsDirect];
	return [result boolValue];
}

- (void)setPrimitiveIsDirectValue:(BOOL)value_ {
	[self setPrimitiveIsDirect:[NSNumber numberWithBool:value_]];
}





@dynamic point;

	

@dynamic tag;

	






@end




