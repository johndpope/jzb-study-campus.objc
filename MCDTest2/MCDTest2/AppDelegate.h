//
//  AppDelegate.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTableView *dataTable;
@property (weak) IBOutlet NSButton *goBackButton;
@property (weak) IBOutlet NSTextField *groupLabel;

@end
