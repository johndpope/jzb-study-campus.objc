//
//  MEBaseEntity_Protected.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEBaseEntity PROTECTED methods definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEBaseEntity(ProtectedMethods)

// Metodos para poder ser utilizados por subclases
+ (NSString *) _calcRemoteCategoryETag;


- (void) resetEntity;


// Lee y escribe la informacion a un diccionario
- (void) readFromDictionary:(NSDictionary *)dic;
- (void) writeToDictionary:(NSMutableDictionary *)dic;


- (void) _xmlStringBody: (NSMutableString*) sb ident:(NSString *) ident;
- (void) _xmlStringBTag: (NSMutableString*) sb ident:(NSString *) ident;
- (void) _xmlStringETag: (NSMutableString*) sb ident:(NSString *) ident;

@end
