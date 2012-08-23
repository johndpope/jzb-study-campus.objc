//
//  ModelDAO.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Model/Model.h"
    


//*********************************************************************************************************************
#pragma mark -
#pragma mark Util Data Entities
//---------------------------------------------------------------------------------------------------------------------
@interface GroupAndCount : NSObject

// Referencia a NSManagedObjectID o a MGroup
@property (strong) id group;
@property UInt count;

+ (GroupAndCount *) withGroup:(MGroup *)group;

@end

//---------------------------------------------------------------------------------------------------------------------
@interface GroupsAndPoints : NSObject

// Referencia a NSManagedObjectID o a MPoint
@property (strong) NSMutableArray *points;
@property (strong) NSArray *groupsAndCounts;


+ (GroupsAndPoints *) withGroupsAndCounts:(NSArray *)groupsAndCounts points:(NSMutableArray *)points;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark ModelDAO interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface ModelDAO : NSObject


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (void) createInitialData;
+ (GroupsAndPoints *) searchEntitiesWithFilter:(NSArray *)filteringGroups;




@end
