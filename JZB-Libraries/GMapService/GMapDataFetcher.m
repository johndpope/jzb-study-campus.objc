//
// GMapDataFetcher.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "GMapDataFetcher.h"
#import "DDLog.h"
#import "SimpleXMLReader.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
#define GMAPDataFetcher_Timeout 20



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMapDataFetcher () {
}


@property (strong) NSString *authToken;


- (NSError *) anError:(NSString *)desc withError:(NSError *)prevErr returnData:(NSData *)returnData;
- (NSData *) encodeParamsInDictionary:(NSDictionary *)dictionary;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMapDataFetcher

@synthesize authToken = _authToken;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) loginWithEmail:(NSString *)email password:(NSString *)password error:(NSError **)err {

    // DDLogVerbose(@"GMapDataFetcher - loginWithEmail");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;



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
    [request setTimeoutInterval:GMAPDataFetcher_Timeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[self encodeParamsInDictionary:paramsDict]];

    NSHTTPURLResponse *response = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:err];

    if(*err != nil || (response != nil && response.statusCode != 200)) {

        *err = [self anError:@"Login user" withError:*err returnData:returnData];

    } else {

        NSString *content = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSArray *splittedStr = [content componentsSeparatedByString:@"\n"];
        for(NSString *str in splittedStr) {
            if([str hasPrefix:@"Auth="]) {
                self.authToken = [str substringWithRange:(NSRange){5, [str length] - 5}];
                DDLogVerbose(@"GMapDataFetcher - AuthToken found: %@", self.authToken);
            }
        }

        if(self.authToken == nil) {
            *err = [self anError:@"Can't find Auth Token in response" withError:nil returnData:returnData];
        }

    }

    // Indica si consiguio el token o no
    return (self.authToken != nil);

}

// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) getServiceInfo:(NSString *)feedStrURL error:(NSError **)err {

    // DDLogVerbose(@"GMapDataFetcher - getServiceInfo");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;



    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:GMAPDataFetcher_Timeout];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"myCompany-myAppName-v1.0(gzip)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"2.0" forHTTPHeaderField:@"GData-Version"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    if(self.authToken != nil) {
        [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", self.authToken] forHTTPHeaderField:@"Authorization"];
    }


    NSDictionary *dictResult = nil;
    NSHTTPURLResponse *response = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:err];


    //NSString *content = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    //DDLogVerbose(@"content: %@", content);

    if(*err != nil || (response != nil && response.statusCode != 200)) {

        *err = [self anError:@"Calling GMap service" withError:*err returnData:returnData];

    } else {

        dictResult = [SimpleXMLReader dictionaryForXMLData:returnData error:err];
        // DDLogVerbose(@"NSDictionary object value: %@", dictResult);
    }

    // Retorna el resultado
    return dictResult;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) postServiceInfo:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError **)err {

    // DDLogVerbose(@"GMapDataFetcher - putServiceInfo");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;



    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:GMAPDataFetcher_Timeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/atom+xml;charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [request setValue:@"myCompany-myAppName-v1.0(gzip)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"2.0" forHTTPHeaderField:@"GData-Version"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];

    if(self.authToken != nil) {
        [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", self.authToken] forHTTPHeaderField:@"Authorization"];
    }

    [request setHTTPBody:[feedData dataUsingEncoding:NSUTF8StringEncoding]];


    NSDictionary *dictResult = nil;
    NSHTTPURLResponse *response = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:err];

    if(*err != nil || (response != nil && (response.statusCode != 200 && response.statusCode != 201))) {

        *err = [self anError:@"Calling GMap service" withError:*err returnData:returnData];

    } else {
        dictResult = [SimpleXMLReader dictionaryForXMLData:returnData error:err];
        // DDLogVerbose(@"NSDictionary object value: %@", dictResult);
    }

    // Retorna el resultado
    return dictResult;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) updateServiceInfo:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError **)err {

    // DDLogVerbose(@"GMapDataFetcher - putServiceInfo");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;



    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:GMAPDataFetcher_Timeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"PUT" forHTTPHeaderField:@"X-HTTP-Method-Override"];
    [request setValue:@"application/atom+xml;charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [request setValue:@"myCompany-myAppName-v1.0(gzip)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"2.0" forHTTPHeaderField:@"GData-Version"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];

    if(self.authToken != nil) {
        [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", self.authToken] forHTTPHeaderField:@"Authorization"];
    }

    [request setHTTPBody:[feedData dataUsingEncoding:NSUTF8StringEncoding]];


    NSDictionary *dictResult = nil;
    NSHTTPURLResponse *response = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:err];

    if(*err != nil || (response != nil && (response.statusCode != 200 && response.statusCode != 201))) {

        *err = [self anError:@"Calling GMap service" withError:*err returnData:returnData];

    } else {
        dictResult = [SimpleXMLReader dictionaryForXMLData:returnData error:err];
        // DDLogVerbose(@"NSDictionary object value: %@", dictResult);
    }

    // Retorna el resultado
    return dictResult;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteServiceInfo:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError **)err {

    // DDLogVerbose(@"GMapDataFetcher - deleteServiceInfo");


    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;



    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:GMAPDataFetcher_Timeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"DELETE" forHTTPHeaderField:@"X-HTTP-Method-Override"];
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
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:err];

    if(*err != nil || (response != nil && (response.statusCode != 200 && response.statusCode != 201))) {
        *err = [self anError:@"Calling GMap service" withError:*err returnData:returnData];
        return false;

    } else {
        return true;
    }
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSError *) anError:(NSString *)desc withError:(NSError *)prevErr returnData:(NSData *)returnData {

    NSString *content = returnData == nil ? @"" : [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             desc, NSLocalizedDescriptionKey,
                             [NSString stringWithFormat:@"Service response: %@", content], @"ServiceResponse",
                             [NSString stringWithFormat:@"%@", prevErr], @"PreviousErrorInfo", nil];
    NSError *myError = [NSError errorWithDomain:@"GMapServiceErrorDomain" code:100 userInfo:errInfo];
    return myError;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSData *) encodeParamsInDictionary:(NSDictionary *)dictionary {

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

@end
