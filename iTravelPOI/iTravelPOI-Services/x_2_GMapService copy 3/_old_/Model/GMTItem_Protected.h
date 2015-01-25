//
//  GMTItem_Protected.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 18/08/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Protocol Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark GMTItem_Protected Public protocol definition
//*********************************************************************************************************************
@protocol GMTItem_Protected <NSObject>

#ifdef __GMTItem__PROTECTED__

- (void) __parseInfoFromFeed:(NSDictionary *)feedDict;
- (NSMutableArray *) __assertNotNilProperties;
- (NSString *) __cleanXMLText:(NSString *)text;

#endif

@end
