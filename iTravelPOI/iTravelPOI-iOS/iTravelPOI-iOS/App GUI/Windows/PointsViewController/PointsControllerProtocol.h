//
//  PointsControllerProtocol.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 15/02/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Protocol Enumerations & definitions
//*********************************************************************************************************************
#define MY_CONSTANT @"a constant"

typedef enum {
    SORT_ASCENDING = YES,
    SORT_DESCENDING = NO
} SORTING_ORDER;

typedef NSString * (^TBlock_blockDefinition)(NSArray *p1, NSError *error);




//*********************************************************************************************************************
#pragma mark -
#pragma mark PointsControllerProtocol Public protocol definition
//*********************************************************************************************************************
@protocol PointsControllerProtocol <NSObject>

@end
