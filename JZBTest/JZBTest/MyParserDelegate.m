//
//  MyParserDelegate.m
//  JZBTest
//
//  Created by Snow Leopard User on 14/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyParserDelegate.h"


@implementation MyParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"parserDidStartDocument");    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"parserDidEndDocument");    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"parseErrorOccurred %@", [parseError localizedDescription]);     
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    NSLog(@"validationErrorOccurred %@", [validationError localizedFailureReason]);    
}

@end
