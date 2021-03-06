//
//  MGroup.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 30/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MBaseNamed.h"

@class MAssignment, MGroup;

@interface MGroup : MBaseNamed

@property (nonatomic) BOOL fixed;
@property (nonatomic, retain) NSString * treePath;
@property (nonatomic, retain) NSString * treeUID;
@property (nonatomic, retain) NSSet *assignments;
@property (nonatomic, retain) MGroup *parent;
@property (nonatomic, retain) NSSet *subgroups;
@end

@interface MGroup (CoreDataGeneratedAccessors)

- (void)addAssignmentsObject:(MAssignment *)value;
- (void)removeAssignmentsObject:(MAssignment *)value;
- (void)addAssignments:(NSSet *)values;
- (void)removeAssignments:(NSSet *)values;

- (void)addSubgroupsObject:(MGroup *)value;
- (void)removeSubgroupsObject:(MGroup *)value;
- (void)addSubgroups:(NSSet *)values;
- (void)removeSubgroups:(NSSet *)values;

@end
