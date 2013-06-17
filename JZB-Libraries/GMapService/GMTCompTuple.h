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
} TCompStatusType;

extern const NSString *TCompStatusType_Names[];

typedef enum {
    ST_Run_None = 0,
    ST_Run_Processing = 1,
    ST_Run_OK = 2,
    ST_Run_Failed = 3,
} TRunStatusType;

extern const NSString *TRunStatusType_Names[];



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMTCompTuple : NSObject

@property (nonatomic, assign) TCompStatusType        compStatus;
@property (nonatomic, assign) TRunStatusType         runStatus;
@property (nonatomic, strong) id<GMPComparableLocal> localItem;
@property (nonatomic, strong) id<GMPComparable>      remoteItem;
@property (nonatomic, assign) BOOL                   conflicted;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
#ifndef __GMTCompTuple__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (GMTCompTuple *) tupleWithCompStatus:(TCompStatusType)compStatus
                             localItem:(id<GMPComparableLocal>)localItem
                            remoteItem:(id<GMPComparable>)remoteItem
                            conflicted:(BOOL)conflicted;


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------

@end
