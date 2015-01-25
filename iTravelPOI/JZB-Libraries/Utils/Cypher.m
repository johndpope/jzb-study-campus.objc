//
//  Cypher.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "Cypher.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define DEFAULT_KEY @"#One$Very#Hard$Password#To$Cypher"


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface Cypher()


@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation Cypher


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) encryptString:(NSString *)plaintext withKey:(NSString *)key {
    
    NSData *data = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSString *b64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return b64;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) decryptString:(NSString *)ciphertext withKey:(NSString *)key {
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:ciphertext options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *plaintext = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
    return plaintext;
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) encryptString:(NSString *)plaintext {
    return [Cypher encryptString:plaintext withKey:DEFAULT_KEY];
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) decryptString:(NSString *)ciphertext {
    return [Cypher decryptString:ciphertext withKey:DEFAULT_KEY];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------


@end
