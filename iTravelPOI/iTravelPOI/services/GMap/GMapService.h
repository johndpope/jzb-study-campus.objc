//
//  GMapService.h
//  WCDTest
//
//  Created by jzarzuela on 11/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseService-Protected.h"
#import "MEBaseEntity.h"
#import "MEMap.h"
#import "MEBaseEntity.h"
#import "MECategory.h"
#import "MEPoint.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
//---------------------------------------------------------------------------------------------------------------------
typedef void (^TBlock_FetchUserMapListFinished)(NSArray *maps, NSError *error);
typedef void (^TBlock_FetchMapDataFinished)(MEMap *map, NSError *error);
typedef void (^TBlock_CreateMapDataFinished)(MEMap *map, NSError *error);
typedef void (^TBlock_DeleteMapDataFinished)(MEMap *map, NSError *error);
typedef void (^TBlock_UpdateMapDataFinished)(MEMap *map, NSError *error);


//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapService interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapService : BaseService


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark GMapService CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (GMapService *)sharedInstance;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark GMapService INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) loginWithUser:(NSString *)email password:(NSString *)password;
- (void) logout;
- (BOOL) isLoggedIn;


// Asynchronous methods
- (SRVC_ASYNCHRONOUS) asyncFetchUserMapList:(TBlock_FetchUserMapListFinished)callbackBlock;
- (SRVC_ASYNCHRONOUS) asyncFetchMapData:(MEMap *)map callback:(TBlock_FetchMapDataFinished)callbackBlock;
- (SRVC_ASYNCHRONOUS) asyncCreateNewEmptyGMap:(MEMap *)map callback:(TBlock_CreateMapDataFinished)callbackBlock;
- (SRVC_ASYNCHRONOUS) asyncDeleteGMap:(MEMap *)map callback:(TBlock_DeleteMapDataFinished)callbackBlock;
- (SRVC_ASYNCHRONOUS) asyncUpdateGMap:(MEMap *)map callback:(TBlock_UpdateMapDataFinished)callbackBlock;

// Synchrouns methods
- (NSArray *)  fetchUserMapList: (NSError **)error;
- (MEMap *)    fetchMapData:(MEMap *)map error:(NSError **)error;
- (MEMap *)    createNewEmptyGMap: (MEMap *)map error:(NSError **)error;
- (MEMap *)    deleteGMap: (MEMap *)map error:(NSError **)error;
- (MEMap *)    updateGMap: (MEMap *)map error:(NSError **)error;


@end
