//
//  PersistenceManager.h
//  iTravelPOI
//
//  Created by JZarzuela on 07/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MEMap.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
//---------------------------------------------------------------------------------------------------------------------
#define MY_CONSTANT @"a constant"

typedef enum {
    XSORT_ASCENDING = YES,
    XSORT_DESCENDING = NO
} XSORTING_ORDER;

typedef NSString * (^TBlock_blockDefinition)(NSArray *p1, NSError *error);



//*********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface PersistenceManager : NSObject 


@property (nonatomic, readonly) NSError *lastError;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (PersistenceManager *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) listMapHeaders;

- (BOOL) loadMapData:(MEMap *)map;
- (BOOL) saveMap:(MEMap *)map;
- (BOOL) removeMap:(MEMap *)map;


@end
