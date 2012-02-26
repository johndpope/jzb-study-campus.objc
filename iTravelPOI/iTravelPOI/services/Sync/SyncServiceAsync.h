//
//  SyncServiceAsync.h
//  WCDTest
//
//  Created by jzarzuela on 16/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEMap.h"


#define ASYNCHRONOUS void
typedef void (^TBlock_SyncFinished)();



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface SyncServiceAsync : NSObject {
}

//---------------------------------------------------------------------------------------------------------------------
+ (SyncServiceAsync *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) syncLocalMap:(MEMap *) localMap withRemote:(MEMap *)remoteMap callback:(TBlock_SyncFinished)callbackBlock;
- (ASYNCHRONOUS) syncLocalMaps:(NSArray *)localMaps withRemotes:(NSArray *)remoteMaps callback:(TBlock_SyncFinished)callbackBlock;

@end
