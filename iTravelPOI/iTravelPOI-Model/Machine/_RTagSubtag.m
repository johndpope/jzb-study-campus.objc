//*********************************************************************************************************************
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RTagSubtag.m instead.
//*********************************************************************************************************************


#define __RTagSubtag__PROTECTED__


#import "_RTagSubtag.h"

const struct RTagSubtagAttributes RTagSubtagAttributes = {
	.isDirect = @"isDirect",
};

const struct RTagSubtagRelationships RTagSubtagRelationships = {
	.childTag = @"childTag",
	.parentTag = @"parentTag",
};

const struct RTagSubtagFetchedProperties RTagSubtagFetchedProperties = {
};

@implementation RTagSubtagID
@end

@implementation _RTagSubtag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RTagSubtag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RTagSubtag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RTagSubtag" inManagedObjectContext:moc_];
}

- (RTagSubtagID*)objectID {
	return (RTagSubtagID*)[super objectID];
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





@dynamic childTag;

	

@dynamic parentTag;

	






@end




