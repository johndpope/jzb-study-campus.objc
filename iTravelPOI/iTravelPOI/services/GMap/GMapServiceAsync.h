//
//  GMapServiceAsync.h
//  WCDTest
//
//  Created by jzarzuela on 13/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMapService.h"


#define ASYNCHRONOUS void
typedef void (^TBlock_FetchUserMapListFinished)(NSArray *maps, NSError *error);
typedef void (^TBlock_FetchMapDataFinished)(MEMap *map, NSError *error);
typedef void (^TBlock_CreateMapDataFinished)(MEMap *map, NSError *error);
typedef void (^TBlock_DeleteMapDataFinished)(MEMap *map, NSError *error);
typedef void (^TBlock_UpdateMapDataFinished)(MEMap *map, NSError *error);



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapServiceAsync : NSObject


//---------------------------------------------------------------------------------------------------------------------
+ (GMapServiceAsync *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password;
- (void) logout;
- (BOOL) isLoggedIn;

- (ASYNCHRONOUS) fetchUserMapList:(TBlock_FetchUserMapListFinished)callbackBlock;
- (ASYNCHRONOUS) fetchMapData:(MEMap *)map callback:(TBlock_FetchMapDataFinished)callbackBlock;
- (ASYNCHRONOUS) createNewEmptyGMap:(MEMap *)map callback:(TBlock_CreateMapDataFinished)callbackBlock;
- (ASYNCHRONOUS) deleteGMap:(MEMap *)map callback:(TBlock_DeleteMapDataFinished)callbackBlock;
- (ASYNCHRONOUS) updateGMap:(MEMap *)map callback:(TBlock_UpdateMapDataFinished)callbackBlock;


@end
