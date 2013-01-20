//
//  MGroup+Extension.h
//  iTravelPOI
//
//  Created by Jose Zarzuela on 03/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "Model.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark MGroup+Extension category definition
//---------------------------------------------------------------------------------------------------------------------
@interface MGroup (Extension)


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MGroup+Extension CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MGroup *)  createGroupWithName:(NSString *)name parentGrp:(MGroup *)parent inContext:(NSManagedObjectContext *)moContext;
+ (NSArray *) rootGroupsInContext:(NSManagedObjectContext *)moContext;
+ (MGroup *)  searchGroupByName:(NSString *)name inContext:(NSManagedObjectContext *)moContext;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MGroup+Extension INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MGroup *)root;
- (BOOL) isAncestorOf:(MGroup *)group;


@end
