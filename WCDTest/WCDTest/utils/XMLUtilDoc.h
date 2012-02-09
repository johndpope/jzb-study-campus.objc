//
//  XMLUtil.h
//  TTSync_Test
//
//  Created by jzarzuela on 03/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GData/GDataXMLNode.h"

@interface XMLUtilDoc : NSObject {
    
@private
    GDataXMLNode *doc;
    NSDictionary *nss;
    NSError *err;
}

//@TODO: que ando haciendo
@property (nonatomic, assign) GDataXMLNode *doc;
@property (nonatomic, copy) NSDictionary *nss;
@property (nonatomic, copy) NSError *err;


+ (XMLUtilDoc *)withXMLStrAndNS:(NSString *)str ns:(NSString *)ns;

+ (XMLUtilDoc *)withDataAndNS:(NSData *)data ns:(NSString *)ns;

+ (NSString *) cleanHTML: (NSString *)str;

- (NSArray *) nodesForXPath:(NSString *)xpath;

- (NSArray *) nodesForXPath:(NSString *)xpath node:(GDataXMLNode*)node;

- (NSString *) nodeStrValue: (NSString *)xpath;

- (NSString *) nodeStrValue: (NSString *)xpath node:(GDataXMLNode*)node;

- (NSString *) nodeStrCleanValue: (NSString *)xpath;

- (NSString *) nodeStrCleanValue: (NSString *)xpath node:(GDataXMLNode*)node;

@end
