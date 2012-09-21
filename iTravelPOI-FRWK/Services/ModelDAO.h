//
//  ModelDAO.h
//  iTravelPOI
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "BaseCoreData.h"
#import "MDataView.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Service public enumerations & definitions
//---------------------------------------------------------------------------------------------------------------------
#define FOUND_POINTS_KEY @"foundPoints"
#define FOUND_GROUPS_KEY @"foundGroups"



//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelDAO interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface ModelDAO : NSObject


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) createInitialData:(NSManagedObjectContext *)moContext;
+ (NSDictionary *) searchEntitiesWithFilter:(NSArray *)filteringGroups inContext:(NSManagedObjectContext *)moContext;




@end
