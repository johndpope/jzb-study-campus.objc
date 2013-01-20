//
//  BaseCoreData.h
//  iTravelPOI-FRWK
//
//  Created by Jose Zarzuela on 29/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Service public enumerations & definitions
//---------------------------------------------------------------------------------------------------------------------




//*********************************************************************************************************************
#pragma mark -
#pragma mark BaseCoreData Service interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface BaseCoreData : NSObject



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSManagedObjectContext *)moContext;

+ (NSEntityDescription *) entityByName:(NSString *)name;

+ (BOOL) initCDStack:(NSString *)modelName;

+ (BOOL) saveContext;
+ (BOOL) saveMOContext:(NSManagedObjectContext *)moContext;


@end
