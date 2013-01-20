//
//  ErrorManagerService.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 03/09/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "ErrorManagerService.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Service private enumerations & definitions
//---------------------------------------------------------------------------------------------------------------------




//*********************************************************************************************************************
#pragma mark -
#pragma mark ErrorManagerService Service private interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface ErrorManagerService()


+ (ErrorManagerService *) sharedInstance;


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark ErrorManagerService Service implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation ErrorManagerService



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (void) manageError:(NSError *)error compID:(NSString *)compID messageWithFormat:(NSString *)message, ... {

    va_list args;
    va_start(args, message);
    
    __block NSString *_errMsg = [NSString stringWithFormat:message,args];
    va_end(args);
    
    // __block NSString *_errMsg = [NSString stringWithFormat:@"%@ - %@", compID, message];
    __block NSError *_err = error;
    
    NSLog(@"%@. Error:%@, %@", _errMsg, _err, [_err userInfo]);

    dispatch_sync(dispatch_get_main_queue(), ^{
        
    #if TARGET_OS_IPHONE
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Announcement"
                              message: _errMsg
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    #else
        NSAlert *alert = [NSAlert alertWithError:_err];
        [alert setMessageText:_errMsg];
        [alert runModal];
    #endif
        
    });
    
}





//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS private methods
//---------------------------------------------------------------------------------------------------------------------
+ (ErrorManagerService *)sharedInstance {
    
    static ErrorManagerService *_globalModelInstance = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        NSLog(@"ErrorManagerService - Creating sharedInstance");
        _globalModelInstance = [[self alloc] init];
    });
    return _globalModelInstance;
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------

@end

