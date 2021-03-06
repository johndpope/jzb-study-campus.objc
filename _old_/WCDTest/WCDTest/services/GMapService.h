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


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapService : NSObject

//---------------------------------------------------------------------------------------------------------------------
+ (GMapService *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password;
- (void) logout;
- (BOOL) isLoggedIn;

- (NSArray *) fetchUserMapList: (NSError * __autoreleasing *)error;
- (TMap *)    fetchMapData:(TMap *)map error:(NSError * __autoreleasing *)error;
- (TMap *)    createNewEmptyGMap: (TMap *)map error:(NSError * __autoreleasing *)error;
- (TMap *)    deleteGMap: (TMap *)map error:(NSError * __autoreleasing *)error;
- (TMap *)    updateGMap: (TMap *)map error:(NSError * __autoreleasing *)error;

@end
