//
//  GMTPlacemark_Protected.h
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
#pragma mark GMTPlacemark_Protected Public protocol definition
//*********************************************************************************************************************
@protocol GMTPlacemark_Protected <NSObject>

#ifdef __GMTPlacemark__PROTECTED__

- (NSString *) __inner_atomEntryContentWithErrRef:(NSErrorRef *)errRef;

#endif

@end
