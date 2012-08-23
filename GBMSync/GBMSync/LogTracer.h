//
//  LogTracer.h
//  GBMSync
//
//  Created by Jose Zarzuela on 21/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LogTracer <NSObject>

- (void) trace:(NSString *)msg,...;

@end
