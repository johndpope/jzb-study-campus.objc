//
//  MComparable.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 19/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>

//*********************************************************************************************************************
#pragma mark -
#pragma mark MComparable definition
//---------------------------------------------------------------------------------------------------------------------
@protocol MComparable <NSObject>

@required
@property (nonatomic) NSString * etag;
@property (nonatomic) NSString * gID;

@optional
@property (nonatomic) BOOL markedAsDeleted;
@property (nonatomic) BOOL modifiedSinceLastSync;

@end
