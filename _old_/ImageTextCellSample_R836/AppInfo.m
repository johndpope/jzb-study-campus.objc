//
//  AppData.m
//  ImageTextCellSample
//
//  Created by Martin Kahr on 04.05.07.
//  Copyright 2007 CASE Apps. All rights reserved.
//

#import "AppInfo.h"

@implementation AppInfo

- (id) initWithApplicationAtPath: (NSString*) path {
	NSBundle* bundle = [NSBundle bundleWithPath: path];
	if (bundle == nil) {
		[self autorelease];
		return nil;
	}
	
	return [self initWithInfoDictionary:[bundle infoDictionary] icon:[[NSWorkspace sharedWorkspace] iconForFile: path]];
}

- (id) initWithInfoDictionary: (NSDictionary*) infoDict icon: (NSImage*) image {
	if (self = [super init]) {
		infoDictionary = [infoDict retain];
		icon = [image retain];
	}
	return self;
}

// When an instance is assigned as objectValue to a NSCell, the NSCell creates a copy.
// Therefore we have to implement the NSCopying protocol
- (id)copyWithZone:(NSZone *)zone {
    AppInfo *copy = [[[self class] allocWithZone: zone] initWithInfoDictionary:infoDictionary icon: icon];
    return copy;
}

- (void) dealloc {
	[infoDictionary release];
	[icon release];
	[super dealloc];
}

- (NSString*) displayName {
	NSString* displayName = [infoDictionary objectForKey: @"CFBundleName"];
	if (displayName) return displayName;
	return [infoDictionary objectForKey: @"CFBundleExecutable"];
}
- (NSString*) details {
	return [NSString stringWithFormat: @"Version %@", [infoDictionary objectForKey: @"CFBundleShortVersionString"]];
}
- (NSImage*) icon {
	return icon;
}

@end
