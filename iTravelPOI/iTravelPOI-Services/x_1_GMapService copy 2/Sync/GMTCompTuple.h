//
// GMTCompTuple.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMPComparable.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************
typedef enum {
    ST_Comp_Create_Local = 0, ST_Comp_Create_Remote = 1,
    ST_Comp_Delete_Local = 2, ST_Comp_Delete_Remote = 3,
    ST_Comp_Update_Local = 4, ST_Comp_Update_Remote = 5
} TCompStatus;

extern const NSString *TCompStatus_Names[];

typedef enum {
    ST_Run_None = 0,
    ST_Run_Processing = 1,
    ST_Run_OK = 2,
    ST_Run_Failed = 3,
} TRunStatus;

extern const NSString *TRunStatus_Names[];



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMTCompTuple : NSObject

@property (assign, nonatomic) TCompStatus            compStatus;
@property (strong, nonatomic) id<GMPComparable>      localItem;
@property (strong, nonatomic) id<GMPComparable>      remoteItem;
@property (assign, nonatomic) BOOL                   conflicted;

@property (assign, nonatomic) TRunStatus             runStatus;
@property (strong, nonatomic) NSError                *error;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMTCompTuple__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GMTCompTuple *) tupleWithCompStatus:(TCompStatus)compStatus
                             localItem:(id<GMPComparable>)localItem
                            remoteItem:(id<GMPComparable>)remoteItem
                            conflicted:(BOOL)conflicted;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------

@end
