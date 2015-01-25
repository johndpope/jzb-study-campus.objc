//  Swift Non-Standard Library
//
//  Created by Russ Bishop
//  http://github.com/xenadu/SwiftNonStandardLibrary
//
//  MIT licensed; see LICENSE for more information


#import "OSSExceptionHelper.h"



//#if TARGET_OS_IPHONE
//#import "SwiftNonStandardLibrary_iOS.h"
//#else
//#import "SwiftNonStandardLibrary.h"
//#endif


@implementation OSSExceptionHelper

+ (void)tryInvokeBlock:(void(^)(void))tryBlock catch:(void(^)(NSException*))catchBlock finally:(void(^)(void))finallyBlock
{
    NSAssert(tryBlock != NULL, @"try block cannot be null");
    //NSAssert(catchBlock != NULL || finallyBlock != NULL, @"catch or finally block must be provided");
    @try {
        tryBlock();
    }
    @catch (NSException *ex) {
        if(catchBlock != NULL) {
            catchBlock(ex);
        }
    }
    @finally {
        if(finallyBlock != NULL) {
            finallyBlock();
        }
    }
}

+ (id)tryInvokeBlockWithReturn:(id(^)(void))tryBlock catch:(id(^)(NSException*))catchBlock finally:(void(^)(void))finallyBlock
{
    NSAssert(tryBlock != NULL, @"try block cannot be null");
    //NSAssert(catchBlock != NULL || finallyBlock != NULL, @"catch or finally block must be provided");
    
    id returnValue = nil;
    @try {
        returnValue = tryBlock();
    }
    @catch (NSException *ex) {
        if(catchBlock != NULL) {
            returnValue = catchBlock(ex);
        }
    }
    @finally {
        if(finallyBlock != NULL) {
            finallyBlock();
        }
    }
    return returnValue;
}

+ (void)throwExceptionNamed:(NSString *)name message:(NSString *)message
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-security"
    [NSException raise:name format:message];
#pragma clang diagnostic pop
}

+ (void)throwException:(NSException *)ex
{
    @throw ex;
}

@end
