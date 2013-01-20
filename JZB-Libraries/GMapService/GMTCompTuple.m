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
const NSString *TCompStatusType_Names[] = {
    @"ST_Comp_Create_Local", @"ST_Comp_Create_Remote",
    @"ST_Comp_Delete_Local", @"ST_Comp_Delete_Remote",
    @"ST_Comp_Update_Local", @"ST_Comp_Update_Remote"
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


@synthesize status = _status;
@synthesize localItem = _localItem;
@synthesize remoteItem = _remoteItem;
@synthesize conflicted = _conflicted;


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GMTCompTuple *) tupleWithStatus:(TCompStatusType)status
                         localItem:(id<GMPComparableLocal>)localItem
                        remoteItem:(id<GMPComparable>)remoteItem
                        conflicted:(BOOL)conflicted {

    GMTCompTuple *tuple = [[GMTCompTuple alloc] init];
    tuple.status = status;
    tuple.localItem = localItem;
    tuple.remoteItem = remoteItem;
    tuple.conflicted = conflicted;

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


@end
