//
// GMItemValidator.h
// GMItemValidator
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
@interface GMItemValidator: NSObject



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Init && CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (BOOL) validateFieldsAreNotNil:(id<GMItem>)item errRef:(NSErrorRef *)errRef; // FALSE if any is NIL


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------



@end