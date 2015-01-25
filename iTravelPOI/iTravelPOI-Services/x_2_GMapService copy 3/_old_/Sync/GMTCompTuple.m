//
// GMCompTupleBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GMTCompTuple__IMPL__
#import "GMTCompTuple.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// ---------------------------------------------------------------------------------------------------------------------
const NSString *TCompStatus_Names[] = {
    @"ST_Comp_Create_Local", @"ST_Comp_Create_Remote",
    @"ST_Comp_Delete_Local", @"ST_Comp_Delete_Remote",
    @"ST_Comp_Update_Local", @"ST_Comp_Update_Remote"
};

const NSString *TRunStatus_Names[] = {
    @"ST_Run_None",
    @"ST_Run_Processing",
    @"ST_Run_OK",
    @"ST_Run_Failed"
};


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GMTCompTuple ()


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GMTCompTuple



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMTCompTuple *) tupleWithCompStatus:(TCompStatus)compStatus
                             localItem:(id<GMPComparable>)localItem
                            remoteItem:(id<GMPComparable>)remoteItem
                            conflicted:(BOOL)conflicted {

    GMTCompTuple *tuple = [[GMTCompTuple alloc] init];
    tuple.compStatus = compStatus;
    tuple.localItem = localItem;
    tuple.remoteItem = remoteItem;
    tuple.conflicted = conflicted;

    tuple.runStatus = ST_Run_None;
    tuple.error = nil;

    return tuple;
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *)description {
    return [NSString stringWithFormat:@"local = %@, remote = %@, compStatus = %@, runStatus = %@", self.localItem.name, self.remoteItem.name, TCompStatus_Names[self.compStatus], TRunStatus_Names[self.runStatus]];
}

@end
