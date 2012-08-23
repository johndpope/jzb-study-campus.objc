//
//  MPoint+Extension.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 03/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MPoint+Extension.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark MPoint+Extension category implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MPoint (Extension)


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MPoint+Extension CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MPoint *) createPointWithName:(NSString *)name groups:(NSSet *)groups {
    
    MPoint *point = [NSEntityDescription insertNewObjectForEntityForName:@"MPoint" inManagedObjectContext:BaseCoreData.moContext];
    point.name = name;
    [point updatePointAssignmentsWithGroups:groups];
    
    return point;
    
}

//*********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC general methods
//---------------------------------------------------------------------------------------------------------------------
- (void) updatePointAssignmentsWithGroups:(NSSet *)groups {
    
    // Busca asignaciones que tengan grupos que ya no estan para eliminarlas
    for(MAssignment *assignment in self.assignments.allObjects) {

        if(![groups containsObject:assignment.group]) {
            [[assignment managedObjectContext] deleteObject:assignment];
        }
        
    }
    
    // Busca grupos que no esten asignados para crear la asignacion correspondiente
    for(MGroup *group in groups) {
    
        BOOL found = false;
        for(MAssignment *assignment in self.assignments) {
            if([assignment.group isEqual:group]) {
                found = true;
                break;
            }
        }
        
        if(!found) {
            [MAssignment createAssignmentWithPoint:self group:group];
        }
        
    }
    
}



@end
