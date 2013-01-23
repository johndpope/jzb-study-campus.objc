//
// PCachingViewCount.h
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 20/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>



// *********************************************************************************************************************
#pragma mark -
#pragma mark Protocol Enumerations & definitions
// *********************************************************************************************************************



// *********************************************************************************************************************
#pragma mark -
#pragma mark PCachingViewCount Public protocol definition
// *********************************************************************************************************************
@protocol PCachingViewCount <NSObject>

@required

@property (nonatomic, strong) NSString *viewCount;

- (NSManagedObjectID *) objectID;
- (NSString *) updateViewCount;


@end
