//
//  ModelServiceAsync.h
//  WCDTest
//
//  Created by jzarzuela on 13/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelService.h"


#define ASYNCHRONOUS void
typedef void (^TBlock_getUserMapListFinished)(NSArray *maps, NSError *error);



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface ModelServiceAsync : NSObject


//---------------------------------------------------------------------------------------------------------------------
+ (ModelServiceAsync *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
- (ASYNCHRONOUS) getUserMapList:(TBlock_getUserMapListFinished)callbackBlock;


@end
