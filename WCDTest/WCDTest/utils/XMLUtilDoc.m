//
//  XMLUtil.m
//  TTSync_Test
//
//  Created by jzarzuela on 03/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "XMLUtilDoc.h"
#import "RegexKitLite.h"


@implementation XMLUtilDoc

@synthesize doc, nss, err;

//****************************************************************************
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//****************************************************************************
- (void)dealloc
{
    [doc autorelease];
    [nss autorelease];
    [err autorelease];
    [super dealloc];
}

//****************************************************************************
+ (XMLUtilDoc *)withXMLStrAndNS:(NSString *)str ns:(NSString *)ns {
    
    NSError *err;
    
    XMLUtilDoc *me = [[XMLUtilDoc alloc] init];
    
    me.doc = [[GDataXMLDocument alloc] initWithXMLString:str options:0 error: &err];
    me.nss = [NSDictionary dictionaryWithObject:ns forKey:@"ns1"];
    me.err = err;
    
    return me;
}

//****************************************************************************
+ (XMLUtilDoc *)withDataAndNS:(NSData *)data ns:(NSString *)ns {
    
    NSError *err;
    
    XMLUtilDoc *me = [[XMLUtilDoc alloc] init];
    
    me.doc = [[GDataXMLDocument alloc] initWithData:data options:0 error: &err];
    me.nss = [NSDictionary dictionaryWithObject:ns forKey:@"ns1"];
    me.err = err;
    
    return me;
}

//****************************************************************************
+ (NSString *) cleanHTML: (NSString *)str {
    
    NSMutableString *cleanStr = [NSMutableString new];
    NSArray  *listItems = [str componentsSeparatedByRegex:@"<[^<>]*>"];    
    for(int n=1;n<[listItems count];n++) {
        NSString *item = [listItems objectAtIndex: n];
        if([item length]>0) {
            [cleanStr appendString: item];
        }
    }
    
    [cleanStr replaceOccurrencesOfString:@"&lt;"   withString:@"<" options:0 range:(NSRange){0, [cleanStr length]}];
    [cleanStr replaceOccurrencesOfString:@"&gt;"   withString:@">" options:0 range:(NSRange){0, [cleanStr length]}];
    [cleanStr replaceOccurrencesOfString:@"&amp;"  withString:@"&" options:0 range:(NSRange){0, [cleanStr length]}];
    [cleanStr replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:0 range:(NSRange){0, [cleanStr length]}];
    
    NSString *result = [NSString stringWithString:cleanStr];
    
    return result;

}

//****************************************************************************
- (NSArray *) nodesForXPath:(NSString *)xpath {
    return [self nodesForXPath:xpath node:doc];
}

//****************************************************************************
- (NSArray *) nodesForXPath:(NSString *)xpath node:(GDataXMLNode*)node {

    NSArray *children = [node nodesForXPath: xpath namespaces:nss error: &err];
    return children;
}

//****************************************************************************
- (NSString *) nodeStrValue: (NSString *)xpath {
    return [self nodeStrValue:xpath node:doc];
}

//****************************************************************************
- (NSString *) nodeStrValue: (NSString *)xpath node:(GDataXMLNode*)node {
    
    NSArray *children = [node nodesForXPath:xpath namespaces:nss error:&err];
    if([children count]>0) {
        return [[children objectAtIndex:0] stringValue]; 
    }
    else {
        return @"";
    }
    
}

//****************************************************************************
- (NSString *) nodeStrCleanValue: (NSString *)xpath {
    return [self nodeStrCleanValue:xpath node:doc];
}

//****************************************************************************
- (NSString *) nodeStrCleanValue: (NSString *)xpath node:(GDataXMLNode*)node {
    
    NSArray *children = [node nodesForXPath:xpath namespaces:nss error:&err];
    if([children count]>0) {
        NSString *val = [[children objectAtIndex:0] stringValue]; 
        return [XMLUtilDoc cleanHTML: val];
    }
    else {
        return @"";
    }
    
}

@end
