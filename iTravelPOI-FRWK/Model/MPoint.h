//
//  MPoint.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 30/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MBaseNamed.h"

@class MAssignment;

@interface MPoint : MBaseNamed

@property (nonatomic, retain) NSSet *assignments;
@end

@interface MPoint (CoreDataGeneratedAccessors)

- (void)addAssignmentsObject:(MAssignment *)value;
- (void)removeAssignmentsObject:(MAssignment *)value;
- (void)addAssignments:(NSSet *)values;
- (void)removeAssignments:(NSSet *)values;

@end
