//
//  GMapService.h
//  WCDTest
//
//  Created by jzarzuela on 11/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMap.h"
#import "TCategory.h"
#import "TPoint.h"

#define ASYNCHRONOUS void
typedef void (^TBlock_FetchUserMapListFinished)(NSArray *maps);



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@protocol GMapServiceCallback <NSObject>

@optional
- (NSArray *) fetchUserMapListDidFinished;

@end

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapService : NSObject {
}


//---------------------------------------------------------------------------------------------------------------------
+ (GMapService *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password;
- (void) logout;
- (BOOL) isLoggedIn;

- (ASYNCHRONOUS) fetchUserMapList:(TBlock_FetchUserMapListFinished)callbackBlock;

@end
