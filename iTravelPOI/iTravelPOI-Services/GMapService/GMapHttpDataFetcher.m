//
// GMapHttpDataFetcher.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "GMapHttpDataFetcher.h"
#import "DDLog.h"
#import "SimpleXMLReader.h"
#import "NetworkProgressWheelController.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
#define GMapHttpDataFetcher_Timeout 10



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMapHttpDataFetcher ()

@property (strong, nonatomic) NSString *authToken;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMapHttpDataFetcher





// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) loginWithEmail:(NSString *)email password:(NSString *)password error:(NSError * __autoreleasing *)err {

    // DDLogVerbose(@"GMapHttpDataFetcher - loginWithEmail");


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
    [request setTimeoutInterval:GMapHttpDataFetcher_Timeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[self _encodeParamsInDictionary:paramsDict]];

    NSHTTPURLResponse *response = nil;
    [NetworkProgressWheelController start];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:err];
    [NetworkProgressWheelController stop];

    if(*err != nil || (response != nil && response.statusCode != 200)) {

        *err = [self _createError:@"Login user" withError:*err returnData:returnData];

    } else {

        NSString *content = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSArray *splittedStr = [content componentsSeparatedByString:@"\n"];
        for(NSString *str in splittedStr) {
            if([str hasPrefix:@"Auth="]) {
                self.authToken = [str substringWithRange:(NSRange){5, [str length] - 5}];
                DDLogVerbose(@"GMapHttpDataFetcher - AuthToken found: %@", self.authToken);
            }
        }

        if(self.authToken == nil) {
            *err = [self _createError:@"Can't find Auth Token in response" withError:nil returnData:returnData];
        }

    }

    // Indica si consiguio el token o no
    return (self.authToken != nil);

}

// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) gmapGET:(NSString *)feedStrURL error:(NSError * __autoreleasing *)err {

    // DDLogVerbose(@"GMapHttpDataFetcher - getServiceInfo");

    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setHTTPMethod:@"GET"];

    NSDictionary *dictResult = [self _processNetworkRequest:request error:err];
    return dictResult;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) gmapPOST:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError * __autoreleasing *)err {

    // DDLogVerbose(@"GMapHttpDataFetcher - putServiceInfo");

    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;


    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[feedData dataUsingEncoding:NSUTF8StringEncoding]];

    NSDictionary *dictResult = [self _processNetworkRequest:request error:err];
    return dictResult;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) gmapUPDATE:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError * __autoreleasing *)err {

    // DDLogVerbose(@"GMapHttpDataFetcher - putServiceInfo");

    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"PUT" forHTTPHeaderField:@"X-HTTP-Method-Override"];
    [request setHTTPBody:[feedData dataUsingEncoding:NSUTF8StringEncoding]];

    NSDictionary *dictResult = [self _processNetworkRequest:request error:err];
    return dictResult;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) gmapDELETE:(NSString *)feedStrURL feedData:(NSString *)feedData error:(NSError * __autoreleasing *)err {

    // DDLogVerbose(@"GMapHttpDataFetcher - deleteServiceInfo");

    __autoreleasing NSError *localError = nil;
    if(err == nil) err = &localError;
    *err = nil;

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feedStrURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"DELETE" forHTTPHeaderField:@"X-HTTP-Method-Override"];

    [self _processNetworkRequest:request error:err];
    return *err==nil;
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSError *) _createError:(NSString *)desc withError:(NSError *)prevErr returnData:(NSData *)returnData {

    NSString *content = returnData == nil ? @"" : [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             desc, NSLocalizedDescriptionKey,
                             [NSString stringWithFormat:@"Service response: %@", content], @"ServiceResponse",
                             [NSString stringWithFormat:@"%@", prevErr], @"PreviousErrorInfo", nil];
    NSError *myError = [NSError errorWithDomain:@"GMapServiceErrorDomain" code:100 userInfo:errInfo];
    return myError;
}

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
- (NSDictionary *) _processNetworkRequest:(NSMutableURLRequest *)request error:(NSError * __autoreleasing *)err {
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:GMapHttpDataFetcher_Timeout];
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
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:err];
    [NetworkProgressWheelController stop];

    //NSString *content = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    //DDLogVerbose(@"content: %@", content);

    
    if(*err != nil || (response != nil && (response.statusCode != 200 && response.statusCode != 201))) {
        *err = [self _createError:@"Calling GMap service" withError:*err returnData:returnData];
        return nil;
    } else {
        NSDictionary *dictResult = [SimpleXMLReader dictionaryForXMLData:returnData error:err];
        // DDLogVerbose(@"NSDictionary object value: %@", dictResult);
        return dictResult;
    }
}


@end
