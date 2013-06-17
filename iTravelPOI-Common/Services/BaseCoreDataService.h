//
// BaseCoreDataService.h
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
#pragma mark BaseCoreDataService Service interface definition
// ---------------------------------------------------------------------------------------------------------------------
@interface BaseCoreDataService : NSObject



// ---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSManagedObjectContext *) moContext;


+ (NSEntityDescription *) entityByName:(NSString *)name;
+ (BOOL) initCDStack:(NSString *)modelName;


@end
