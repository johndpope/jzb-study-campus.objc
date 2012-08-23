//
//  MainController.h
//  ImageTextCellSample
//
//  Created by Martin Kahr on 11.12.06.
//  Copyright 2006 CASE Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MainController : NSObject {
	IBOutlet NSTableView* appList;
	
	NSMutableArray* applications;
}

- (NSArray*) applications;

@end
