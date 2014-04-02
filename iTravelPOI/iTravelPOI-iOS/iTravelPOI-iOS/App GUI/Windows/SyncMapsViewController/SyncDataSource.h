//
//  SyncDataSource.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 28/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
#define MY_CONSTANT @"a constant"

typedef enum {
    SORT_ASCENDING = YES,
    SORT_DESCENDING = NO
} SORTING_ORDER;

typedef NSString * (^TBlock_blockDefinition)(NSArray *p1, NSError *error);




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface SyncDataSource : NSObject


@property (nonatomic, strong) NSString *publicProperty;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
#ifndef __SyncDataSource__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (void) publicClassMethod;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) publicMethod;



@end
