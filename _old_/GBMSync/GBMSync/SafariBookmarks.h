//
//  SafariBookmarks.h
//  GBMSync
//
//  Created by Jose Zarzuela on 21/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogTracer.h"

@interface SafariBookmarks : NSObject {
    NSMutableDictionary *safaryPlist;
    NSMutableDictionary *bkmrkBar;
    NSMutableDictionary *gbkmrks;
}

@property (weak) id<LogTracer> tracer;


- (void) readSafariBookmarks;


@end
