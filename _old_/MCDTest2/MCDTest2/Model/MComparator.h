//
//  MComparator.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 19/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MComparable.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Definitions and Constants
//---------------------------------------------------------------------------------------------------------------------

enum {
    NOTHING       = 0,
    LOCAL_CREATE  = 1,
    LOCAL_UPDATE  = 2,
    LOCAL_DELETE  = 3,
    REMOTE_CREATE = 4,
    REMOTE_UPDATE = 5,
    REMOTE_DELETE = 6
};
typedef NSUInteger TCompAction;




//*********************************************************************************************************************
#pragma mark -
#pragma mark MComparationTuple definition
//---------------------------------------------------------------------------------------------------------------------
@interface MComparationTuple : NSObject

@property (nonatomic, strong) id<MComparable> local;
@property (nonatomic, strong) id<MComparable> remote;
@property (nonatomic, assign) TCompAction action;

+ (MComparationTuple *) tupleWithLocal:(id<MComparable>)local remote:(id<MComparable>)remote action:(TCompAction) action;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark MComparator definition
//---------------------------------------------------------------------------------------------------------------------
@interface MComparator : NSObject



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public CLASS methods
//---------------------------------------------------------------------------------------------------------------------
// Returns MComparationTuple[]
+ (NSArray *) compareLocals:(NSArray *)locals withRemotes:(NSArray *)remotes;


@end
