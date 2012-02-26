//
//  ModelService.h
//  CDTest
//
//  Created by Snow Leopard User on 03/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEMap.h"
#import "MECategory.h"
#import "MEPoint.h"

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface SyncService : NSObject 

//---------------------------------------------------------------------------------------------------------------------
+ (SyncService *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
- (void) syncLocalMap:(MEMap *) localMap withRemote:(MEMap *)remoteMap;
- (void) syncLocalMaps:(NSArray *)localMaps withRemotes:(NSArray *)remoteMaps;


@end
