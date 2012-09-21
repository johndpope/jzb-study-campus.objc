//
//  MAssignment+Extension.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "Model.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark MAssignment+Extension category definition
//---------------------------------------------------------------------------------------------------------------------
@interface MAssignment (Extension)


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MAssignment+Extension CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MAssignment *) createAssignmentWithPoint:(MPoint *)point group:(MGroup *)group;

@end
