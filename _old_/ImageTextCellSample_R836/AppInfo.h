//
//  AppData.h
//  ImageTextCellSample
//
//  Created by Martin Kahr on 04.05.07.
//  Copyright 2007 CASE Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppInfo : NSObject <NSCopying> {
	NSDictionary* infoDictionary;
	NSImage*  icon;
}

- (id) initWithApplicationAtPath: (NSString*) path;
- (id) initWithInfoDictionary: (NSDictionary*) infoDict icon: (NSImage*) image;

- (NSString*) displayName;
- (NSString*) details;
- (NSImage*) icon;

@end
