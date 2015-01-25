//  Swift Non-Standard Library
//
//  Created by Russ Bishop
//  http://github.com/xenadu/SwiftNonStandardLibrary
//
//  MIT licensed; see LICENSE for more information


#import <Foundation/Foundation.h>


@interface OSSExceptionHelper : NSObject

+ (void)tryInvokeBlock:(void(^)(void))tryBlock catch:(void(^)(NSException*))catchBlock finally:(void(^)(void))finallyBlock;
+ (id)tryInvokeBlockWithReturn:(id(^)(void))tryBlock catch:(id(^)(NSException*))catchBlock finally:(void(^)(void))finallyBlock;
+ (void)throwExceptionNamed:(NSString *)name message:(NSString *)message;
+ (void)throwException:(NSException *)ex;

@end


