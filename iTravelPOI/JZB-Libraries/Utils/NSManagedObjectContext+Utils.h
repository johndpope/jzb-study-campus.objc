//
// NSManagedObjectContext+Utils.h
// iTravelPOI-FRWK
//
// Created by Jose Zarzuela on 29/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>



// *********************************************************************************************************************
#pragma mark -
#pragma mark Service public enumerations & definitions
// ---------------------------------------------------------------------------------------------------------------------



// *********************************************************************************************************************
#pragma mark -
#pragma mark NSManagedObjectContext Category
// ---------------------------------------------------------------------------------------------------------------------
@interface NSManagedObjectContext(Utils)

- (BOOL) saveChanges;

- (NSManagedObjectContext *) childContext;
- (NSManagedObjectContext *) ChildContextASync;


@end

