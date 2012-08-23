//
//  AppDelegate.h
//  GBMSync
//
//  Created by Jose Zarzuela on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "LogTracer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, LogTracer>

@property (weak) IBOutlet NSTextField *userName;
@property (weak) IBOutlet NSSecureTextField *userPwd;
@property (weak) IBOutlet WebView *browser;
@property (unsafe_unretained) IBOutlet NSTextView *tracesView;

@end
