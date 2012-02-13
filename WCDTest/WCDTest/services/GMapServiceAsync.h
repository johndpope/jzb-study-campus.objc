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
typedef void (^TBlock_FetchMapDataFinished)(TMap *map, NSError *error);
typedef void (^TBlock_CreateMapDataFinished)(TMap *map, NSError *error);
typedef void (^TBlock_DeleteMapDataFinished)(TMap *map, NSError *error);



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
- (ASYNCHRONOUS) fetchMapData:(TMap *)map callback:(TBlock_FetchMapDataFinished)callbackBlock;

@end
