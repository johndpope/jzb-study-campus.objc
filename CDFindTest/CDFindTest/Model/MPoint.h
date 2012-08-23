//
//  MPoint.h
//  CDFindTest
//
//  Created by Jose Zarzuela on 28/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGroup;

@interface MPoint : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *groups;
@end

@interface MPoint (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(MGroup *)value;
- (void)removeGroupsObject:(MGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
