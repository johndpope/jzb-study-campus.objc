//
// GMapDataHttpFetcher.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "GMapDataHttpFetcher.h"

#import "DDLog.h"
#import "SimpleXMLReader.h"
#import "NSString+HTML.h"
#import "NetworkProgressWheelController.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
#define GMapDataHttpFetcher_Timeout 10



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMapDataHttpFetcher ()

@property (strong, nonatomic) NSString *authToken;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMapDataHttpFetcher





// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) loginWithEmail:(NSString *)email password:(NSString *)password errRef:(NSErrorRef *)errRef {

    // DDLogVerbose(@"GMapDataHttpFetcher - loginWithEmail");


    // Establece que no hay un error
    [NSError nilErrorRef:errRef];

    // De momento borra el actual token
    self.authToken = nil;

    NSURL *loginURL = [NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"];

    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"myCompany-myAppName-v1.0", @"source",
                                @"HOSTED_OR_GOOGLE", @"accountType",
                                @"local", @"service",
                                email, @"Email",
                                password, @"Passwd",
                                nil];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginURL];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:GMapDataHttpFetcher_Timeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[self _encodeParamsInDictionary:paramsDict]];

    NSHTTPURLResponse *response = nil;
    [NetworkProgressWheelController start];
    NSError *loginError = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&loginError];
    [NetworkProgressWheelController stop];

    if(loginError != nil || (response != nil && response.statusCode != 200)) {
        [NSError setErrorRef:errRef domain:@"GMapDataHttpFetcher" reason:@"Error login user.\n  Return data: %@\n  error:%@", returnData, loginError];
        return FALSE;
    }


    // Busca y extrae el token de SSO
    NSString *content = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSArray *splittedStr = [content componentsSeparatedByString:@"\n"];
    for(NSString *str in splittedStr) {
        if([str hasPrefix:@"Auth="]) {
            self.authToken = [str substringWithRange:(NSRange){5, [str length] - 5}];
            DDLogVerbose(@"GMapDataHttpFetcher - AuthToken found: %@", self.authToken);
        }
    }
    
    // Indica si consiguio el token o no
    if(self.authToken == nil) {
        [NSError setErrorRef:errRef domain:@"GMapDataHttpFetcher" reason:@"Error login user.\n  Return data: %@\n  error:%@", returnData, loginError];
        return FALSE;
    } else {
        [NSError nilErrorRef:errRef];
        return TRUE;
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) gmapGET:(NSString *)feedStrURL errRef:(NSErrorRef *)errRef {

    // DDLogVerbose(@"GMapDataHttpFetcher - getServiceInfo");

    [NSError nilErrorRef:errRef];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setHTTPMethod:@"GET"];

    NSDictionary *dictResult = [self _processNetworkRequest:request isDelete:FALSE errRef:errRef];
    return dictResult;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) gmapPOST:(NSString *)feedStrURL feedData:(NSString *)feedData errRef:(NSErrorRef *)errRef {

    // DDLogVerbose(@"GMapDataHttpFetcher - putServiceInfo");

    [NSError nilErrorRef:errRef];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[feedData dataUsingEncoding:NSUTF8StringEncoding]];

    NSDictionary *dictResult = [self _processNetworkRequest:request isDelete:FALSE errRef:errRef];
    return dictResult;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) gmapUPDATE:(NSString *)feedStrURL feedData:(NSString *)feedData errRef:(NSErrorRef *)errRef {

    // DDLogVerbose(@"GMapDataHttpFetcher - putServiceInfo");

    [NSError nilErrorRef:errRef];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"PUT" forHTTPHeaderField:@"X-HTTP-Method-Override"];
    [request setHTTPBody:[feedData dataUsingEncoding:NSUTF8StringEncoding]];

    NSDictionary *dictResult = [self _processNetworkRequest:request isDelete:FALSE errRef:errRef];
    return dictResult;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) gmapDELETE:(NSString *)feedStrURL feedData:(NSString *)feedData errRef:(NSErrorRef *)errRef {

    // DDLogVerbose(@"GMapDataHttpFetcher - deleteServiceInfo");

    [NSError nilErrorRef:errRef];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"DELETE" forHTTPHeaderField:@"X-HTTP-Method-Override"];

    NSError *localError = nil;
    [self _processNetworkRequest:request isDelete:TRUE errRef:&localError];
    if(errRef) *errRef = localError;
    return localError==nil;
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSData *) _encodeParamsInDictionary:(NSDictionary *)dictionary {

    NSMutableArray *parts = [NSMutableArray array];
    for(NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionaryStr = [parts componentsJoinedByString:@"&"];
    return [encodedDictionaryStr dataUsingEncoding:NSUTF8StringEncoding];
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) _processNetworkRequest:(NSMutableURLRequest *)request isDelete:(BOOL)isDelete errRef:(NSErrorRef *)errRef{
    
    // Establece que no hay un error
    [NSError nilErrorRef:errRef];

    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:GMapDataHttpFetcher_Timeout];
    [request setValue:@"application/atom+xml;charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [request setValue:@"myCompany-myAppName-v1.0(gzip)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"2.0" forHTTPHeaderField:@"GData-Version"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    
    if(self.authToken != nil) {
        [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", self.authToken] forHTTPHeaderField:@"Authorization"];
    }
    
    NSHTTPURLResponse *response = nil;
    [NetworkProgressWheelController start];
    NSError *callingError = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&callingError];
    [NetworkProgressWheelController stop];

    //NSString *content = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    //DDLogVerbose(@"content: %@", content);

    if(callingError != nil || (response != nil && (response.statusCode != 200 && response.statusCode != 201))) {
        NSString *content = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] gtm_stringByUnescapingFromHTML];
        [NSError setErrorRef:errRef domain:@"GMapDataHttpFetcher" reason:@"Calling GMap service.\n  Return data: %@\n  error:%@", content, callingError];
        return nil;
    }
    
    // Hay una situacion especial, en el borrado, en el que se retorna vacio el buffer
    if(isDelete && returnData.length==0) return nil;

    //Parsea la respuesta y retorna el resultado
    NSError *parseError = nil;
    NSDictionary *dictResult = [SimpleXMLReader dictionaryForXMLData:returnData error:&parseError];
    if(parseError != nil || dictResult == nil) {
        NSString *content = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] gtm_stringByUnescapingFromHTML];
        [NSError setErrorRef:errRef domain:@"GMapDataHttpFetcher" reason:@"Parsing GMap service response.\n  Return data: %@\n  error:%@", content, parseError];
        return nil;
    }
    
    return dictResult;
}


@end
