//
// AppDelegate.m
// GMapAPI
//
// Created by Jose Zarzuela on 01/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "AppDelegate.h"
#import "DDTTYLogger.h"


#import "GM_Test.h"
#import "GM_SyncTest.h"
#import "GEOCoding_Test.h"


@implementation AppDelegate



// ---------------------------------------------------------------------------------------------------------------------
- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    GM_SyncTest *gmSycnTest = [GM_SyncTest testWithEmail:@"jzarzuela@gmail.com" password:@"#webweb1971" exitOnError:true error:nil];
    [gmSycnTest syncTestAll];

    /*
    GM_Test *gmTest = [GM_Test testWithEmail:@"jzarzuela@gmail.com" password:@"#webweb1971" exitOnError:true error:nil];
    [gmTest asyncTestAll];

    [GEOCoding_Test testGeocoding];
     */

}

@end
