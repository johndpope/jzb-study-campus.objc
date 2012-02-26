//
//  GMapService.h
//  WCDTest
//
//  Created by jzarzuela on 11/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEMap.h"
#import "MECategory.h"
#import "MEPoint.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapService : NSObject

//---------------------------------------------------------------------------------------------------------------------
+ (GMapService *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password;
- (void) logout;
- (BOOL) isLoggedIn;

- (NSArray *) fetchUserMapList: (NSError **)error;
- (MEMap *)    fetchMapData:(MEMap *)map error:(NSError **)error;
- (MEMap *)    createNewEmptyGMap: (MEMap *)map error:(NSError **)error;
- (MEMap *)    deleteGMap: (MEMap *)map error:(NSError **)error;
- (MEMap *)    updateGMap: (MEMap *)map error:(NSError **)error;

@end
