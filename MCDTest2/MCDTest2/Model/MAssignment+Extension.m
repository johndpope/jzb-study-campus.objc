//
//  MAssignment+Extension.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MAssignment+Extension.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark MAssignment+Extension category implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MAssignment (Extension)



//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MAssignment *) createAssignmentWithPoint:(MPoint *)point group:(MGroup *)group {

    // Chequea si no esta ya creado
    for(MAssignment *assignment in point.assignments) {
        if([assignment.group isEqual:group]) {
            return assignment;
        }
    }
    
    MAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"MAssignment" inManagedObjectContext:BaseCoreData.moContext];
    
    assignment.etag= [NSString stringWithFormat:@"%@-%@", group.name, point.name];
    assignment.point = point;
    assignment.group = group;
    
    return assignment;
    
}

@end
