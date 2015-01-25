//
// GMapService_Assertions.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "GMModel.h"
#import "GMRemoteService.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC Enumeration & definitions
// *********************************************************************************************************************




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// *********************************************************************************************************************
@interface GMapService_Assertions : XCTestCase

- (void) assertInfoIsSyncForMap:(id<GMMap>)map gmapService:(GMRemoteService *)gmapService skipDeleteLocal:(BOOL)skipDeleteLocal;

- (void) assert_RemoteItem:(id<GMItem>)item skipDeleteLocal:(BOOL)skipDeleteLocal;
- (void) assert_LocalItem:(id<GMItem>)item;



@end
