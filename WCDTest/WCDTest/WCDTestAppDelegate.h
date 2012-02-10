//
//  WCDTestAppDelegate.h
//  WCDTest
//
//  Created by jzarzuela on 09/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WCDTestAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    NSButton *_myButton;
    NSScrollView *myList;
    NSTableView *myTable;
}

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSButton *myButton;
@property (assign) IBOutlet NSTableView *myTable;

@property (nonatomic,retain) NSArray *maps;

@end
