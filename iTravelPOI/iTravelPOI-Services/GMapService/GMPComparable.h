//
// GMTItemSubclassing.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>


// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// *********************************************************************************************************************
@protocol GMPComparable <NSObject>

- (NSString *) name;
- (NSString *) gID;
- (NSString *) etag;

@end

// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// *********************************************************************************************************************
@protocol GMPComparableLocal <GMPComparable>

- (BOOL) markedAsDeletedValue;
- (BOOL) wasSynchronizedValue;
- (BOOL) modifiedSinceLastSyncValue;

@end
