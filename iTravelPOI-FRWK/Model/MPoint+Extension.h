//
//  MPoint+Extension.h
//  iTravelPOI
//
//  Created by Jose Zarzuela on 03/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//


#import "Model.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark MPoint+Extension category definition
//---------------------------------------------------------------------------------------------------------------------
@interface MPoint (Extension)

//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MPoint+Extension CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) createPointWithName:(NSString *)name groups:(NSSet *)groups inContext:(NSManagedObjectContext *)moContext;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MPoint+Extension INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) updatePointAssignmentsWithGroups:(NSSet *)groups;

@end
