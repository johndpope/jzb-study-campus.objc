//
// GMComparer.h
//
// Created by Jose Zarzuela.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------
typedef enum {
    CS_Equals      = 0,
    CS_CreateLocal = 1, CS_CreateRemote = 2,
    CS_DeleteLocal = 3, CS_DeleteRemote = 4,
    CS_UpdateLocal = 5, CS_UpdateRemote = 6
} GMCompStatus;

extern const NSString *GMCompStatusNames[];




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMCompareTuple : NSObject

@property (assign, nonatomic) GMCompStatus compStatus;
@property (strong, nonatomic) id<GMItem>   local;
@property (strong, nonatomic) id<GMItem>   remote;
@property (assign, nonatomic) BOOL         conflicted;

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMComparer : NSObject

// Returns an array of GMCompareTuple
+ (NSArray *) compareLocalItems:(NSArray *)localItems toRemoteItems:(NSArray *)remoteItems;


@end
