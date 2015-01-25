//
// NSError+SimpleInit.m
// JZBTest
//
// Created by Snow Leopard User on 16/10/11.
// Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSError+SimpleInit.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation NSError (SimpleInit)



// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
// Simplifica la creacion de una instancia de error
+ (NSError *) errorWithDomain:(NSString *)domain reason:(NSString *)reason,... {

    va_list args;
    va_start(args, reason);
    return [self _errorWithDomain:domain code:1 reason:reason args:args];
}

// ---------------------------------------------------------------------------------------------------------------------
// Simplifica la creacion de una instancia de error
+ (NSError *) errorWithDomain:(NSString *)domain code:(NSInteger)code reason:(NSString *)reason,... {
    
    va_list args;
    va_start(args, reason);
    return [self _errorWithDomain:domain code:code reason:reason args:args];
}

// ---------------------------------------------------------------------------------------------------------------------
// Simplifica la creacion de una instancia de error y su asignacion por referencia
+ (void) setErrorRef:(NSErrorRef *)errRef domain:(NSString *)domain reason:(NSString *)reason,... {

    if(errRef) {
        va_list args;
        va_start(args, reason);
        *errRef = [self _errorWithDomain:domain code:1 reason:reason args:args];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// Simplifica la creacion de una instancia de error y su asignacion por referencia
+ (void) setErrorRef:(NSErrorRef *)errRef domain:(NSString *)domain code:(NSInteger)code reason:(NSString *)reason,... {

    if(errRef) {
        va_list args;
        va_start(args, reason);
        *errRef = [self _errorWithDomain:domain code:code reason:reason args:args];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// Simplifica la creacion de una instancia de error y su asignacion por referencia
+ (void) nilErrorRef:(NSErrorRef *)errRef {
    
    if(errRef) *errRef = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
// Simplifica la creacion de una instancia de error
+ (NSError *) _errorWithDomain:(NSString *)domain code:(NSInteger)code reason:(NSString *)reason args:(va_list)args {
    
    NSString *formattedReason = [[NSString alloc] initWithFormat:reason arguments:args];
    va_end(args);
    
    NSDictionary *errInfo = [NSDictionary dictionaryWithObject:formattedReason forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:errInfo];
    return error;
}





@end
