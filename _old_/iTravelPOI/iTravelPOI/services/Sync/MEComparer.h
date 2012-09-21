//
//  MapEntitiesComparer.h
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEBaseEntity.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Comparation Tuple
//---------------------------------------------------------------------------------------------------------------------
@interface MECompareTuple : NSObject 

@property (nonatomic, retain) MEBaseEntity *localEntity;
@property (nonatomic, retain) MEBaseEntity *remoteEntity;
@property (nonatomic, assign) SyncStatusType syncStatus;
@property (nonatomic, assign) BOOL withConflict;


+ tupleForLocal:(MEBaseEntity *) local 
        remote:(MEBaseEntity *)  remote 
    syncStatus:(SyncStatusType)  syncStatus
   withConflict:(BOOL)            withConflict;


@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark Comparation delegate
//---------------------------------------------------------------------------------------------------------------------
@protocol MEComparerDelegate <NSObject>

- (void) processTuple:(MECompareTuple *) tuple;

@end

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MEComparer : NSObject

+ (void) compareLocals:(NSArray *)locals remotes:(NSArray *)remotes compDelegate:(id <MEComparerDelegate>)compDelegate;

@end
