//
//  MGroup+Extension.h
//  MCDTest2
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
+ (MGroup *)  createGroupWithName:(NSString *)name parentGrp:(MGroup *)parent;
+ (NSArray *) rootGroups;
+ (MGroup *)  searchGroupByName:(NSString *)name;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MGroup+Extension INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (MGroup *)root;
- (BOOL) isAncestorOf:(MGroup *)group;


@end
