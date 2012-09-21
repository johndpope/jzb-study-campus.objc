//
//  TBaseEntity_Protected.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//*********************************************************************************************************************

//---------------------------------------------------------------------------------------------------------------------
@interface TBaseEntity(ProtectedMethods)

- (void) resetEntity;

- (void) _xmlStringBody: (NSMutableString*) sb ident:(NSString *) ident;
- (void) _xmlStringBTag: (NSMutableString*) sb ident:(NSString *) ident;
- (void) _xmlStringETag: (NSMutableString*) sb ident:(NSString *) ident;

@end
