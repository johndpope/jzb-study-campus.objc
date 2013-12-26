//
// MockUp.h
// iTravelPOI
//
// Created by Jose Zarzuela on 16/08/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>

// *********************************************************************************************************************
#pragma mark -
#pragma mark MockUp interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface MockUp : NSObject

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MockUp CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (void) resetModel:(NSString *)modelName;
+ (void) populateModel;
+ (void) populateModelFromPListFiles;
+ (void) listModel;


@end
