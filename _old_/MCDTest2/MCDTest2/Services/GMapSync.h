//
//  GMapSync.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 19/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GData/GData.h>

//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapSync definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapSync : NSObject


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public CLASS methods
//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password;
- (GDataFeedBase *)  fetchUserMapList:(NSError * __autoreleasing *)err;

@end
