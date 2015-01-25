//
//  Cypher.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface Cypher : NSObject



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) encryptString:(NSString *)plaintext withKey:(NSString *)key;
+ (NSString *) decryptString:(NSString *)ciphertext withKey:(NSString *)key;

+ (NSString *) encryptString:(NSString *)plaintext;
+ (NSString *) decryptString:(NSString *)ciphertext;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------



@end
