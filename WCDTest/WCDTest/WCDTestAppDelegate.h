//
//  WCDTestAppDelegate.h
//  WCDTest
//
//  Created by jzarzuela on 09/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface WCDTestAppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate, NSTableViewDataSource> {
}
 

// ----- OUTLETs -----
@property (assign) IBOutlet NSWindow *bi_window;
@property (assign) IBOutlet NSTabView *bi_tabs;
@property (assign) IBOutlet NSTextField *bi_email;
@property (assign) IBOutlet NSSecureTextField *bi_password;
@property (assign) IBOutlet NSTableView *bi_syncTable;

@end
