//
//  ModelServiceAsync.h
//  WCDTest
//
//  Created by jzarzuela on 13/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelService.h"
#import "TMap.h"


#define ASYNCHRONOUS void
typedef void (^TBlock_saveContextFinished)(NSError *error);
typedef void (^TBlock_getUserMapListFinished)(NSArray *maps, NSError *error);
typedef void (^TBlock_getAllElemensInMapFinished)(NSArray *elements, NSError *error);



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface ModelServiceAsync : NSObject


//---------------------------------------------------------------------------------------------------------------------
+ (ModelServiceAsync *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) saveContext:(TBlock_saveContextFinished)callbackBlock;
- (ASYNCHRONOUS) getUserMapList:(TBlock_getUserMapListFinished)callbackBlock;
- (ASYNCHRONOUS) getAllElemensInMap:(TMap *)map callback:(TBlock_getAllElemensInMapFinished)callbackBlock;


@end
