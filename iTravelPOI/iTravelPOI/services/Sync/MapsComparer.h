//
//  MapsComparer.h
//  iTravelPOI
//
//  Created by JZarzuela on 05/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEMap.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MapsCompareItem : NSObject 

@property (nonatomic, retain) MEMap *localMap;
@property (nonatomic, retain) MEMap *remoteMap;
@property (nonatomic, assign) SyncStatusType syncStatus;


+ itemForLocalMap:(MEMap *)localMap remoteMap:(MEMap *)remoteMap;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MapsComparer : NSObject


+ (NSMutableArray *) compareLocals:(NSArray *)localMaps remoteMaps:(NSArray *)remoteMaps;


@end
