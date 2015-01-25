//
// GMAtomGenerator.h
// GMAtomGenerator
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration & definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMAtomGenerator: NSObject



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Init && CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
// NIL can be returned in case of error
+ (NSString *) partialAtomEntryFromItem:(id<GMItem>)item;
+ (NSString *) fullAtomEntryFromItem:(id<GMItem>)item;


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------



@end
