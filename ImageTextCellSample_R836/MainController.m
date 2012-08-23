//
//  MainController.m
//  ImageTextCellSample
//
//  Created by Martin Kahr on 11.12.06.
//  Copyright 2006 CASE Apps. All rights reserved.
//

#import "MainController.h"
#import "ImageTextCell.h"
#import "AppInfo.h"

@implementation MainController

- (id) init {
	if (self = [super init]) {
		// build up some sample data
		applications = [[NSMutableArray alloc] init];
		NSEnumerator* dirEnum = [[[NSFileManager defaultManager] directoryContentsAtPath:@"/Applications"] objectEnumerator];
		NSString *file;
		while (file = [dirEnum nextObject]) {
			if ([[file pathExtension] isEqualToString: @"app"]) {
				NSString* fullPath = [NSString stringWithFormat:@"/Applications/%@", file];
				AppInfo* appInfo   = [[[AppInfo alloc] initWithApplicationAtPath: fullPath] autorelease];
				if (appInfo) [applications addObject: appInfo];
			}
		}		
	}
	return self;
}

- (void) dealloc {
	[applications autorelease];
	[super dealloc];
}

- (NSArray*) applications {
	return applications;
}

- (void) awakeFromNib {	
	// set the new custom cell
	NSTableColumn* column = [[appList tableColumns] objectAtIndex:0];
	
	ImageTextCell* cell = [[[ImageTextCell alloc] init] autorelease];	
	[column setDataCell: cell];		

	BOOL useDelegateMethods = YES;
	
	if (useDelegateMethods) {
		// Variant 1: use delegate methods
		
		// inform the cell that this instance implements the delegate methods
		[cell setDataDelegate: self];	
		
	} else {
		// Variant 2: use key paths
		[cell setPrimaryTextKeyPath: @"displayName"];
		[cell setSecondaryTextKeyPath: @"details"];
		[cell setIconKeyPath: @"icon"];
	}
}

- (NSString*) myPrimaryText {
	return @"Test";
}

#pragma mark -
#pragma mark Custom Cell data delegate methods

- (NSImage*) iconForCell: (ImageTextCell*) cell data: (NSObject*) data {
	AppInfo* appInfo = (AppInfo*) data;
	return [appInfo icon];
}
- (NSString*) primaryTextForCell: (ImageTextCell*) cell data: (NSObject*) data {
	AppInfo* appInfo = (AppInfo*) data;
	return [appInfo displayName];
}
- (NSString*) secondaryTextForCell: (ImageTextCell*) cell data: (NSObject*) data {
	AppInfo* appInfo = (AppInfo*) data;
	return [appInfo details];
}

/* optional delegate methods
- (NSObject*) dataElementForCell: (ImageTextCell*) cell {
	return [cell objectValue];
}
- (BOOL) disabledForCell: (ImageTextCell*) cell data: (NSObject*) data {
	return NO;
}*/

@end
