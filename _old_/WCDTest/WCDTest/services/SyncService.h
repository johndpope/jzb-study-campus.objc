//
//  ModelService.h
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMap.h"
#import "TCategory.h"
#import "TPoint.h"

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface SyncService : NSObject 

//---------------------------------------------------------------------------------------------------------------------
+ (SyncService *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
- (void) syncLocalMap:(TMap *) localMap withRemote:(TMap *)remoteMap;
- (void) syncLocalMaps:(NSArray *)localMaps withRemotes:(NSArray *)remoteMaps;


@end
