//
//  NSDataExtensions.h
//  WCDTest
//
//  Created by jzarzuela on 12/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface NSData (NSDataExtensions)


//---------------------------------------------------------------------------------------------------------------------
// Base 64 coding/decoding
+ (NSData *) dataWithB64EncodedString:(NSString *) string;
- (id) initWithB64EncodedString:(NSString *) string;

- (NSString *) b64Encoding;
- (NSString *) b64EncodingWithLineLength:(NSUInteger) lineLength;


//---------------------------------------------------------------------------------------------------------------------
// gzip compression utilities
- (NSData *)gzipInflate;
- (NSData *)gzipDeflate;

@end
