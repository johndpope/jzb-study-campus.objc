//
//  MGroup.h
//  CDFindTest
//
//  Created by Jose Zarzuela on 28/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGroup, MIntersection, MPoint;

@interface MGroup : NSManagedObject

@property (nonatomic) int32_t count;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uID;
@property (nonatomic) int32_t level;
@property (nonatomic, retain) NSSet *ancestors;
@property (nonatomic, retain) NSSet *descendants;
@property (nonatomic, retain) NSSet *intersections;
@property (nonatomic, retain) NSSet *points;
@property (nonatomic, retain) MGroup *root;
@end

@interface MGroup (CoreDataGeneratedAccessors)

- (void)addAncestorsObject:(MGroup *)value;
- (void)removeAncestorsObject:(MGroup *)value;
- (void)addAncestors:(NSSet *)values;
- (void)removeAncestors:(NSSet *)values;

- (void)addDescendantsObject:(MGroup *)value;
- (void)removeDescendantsObject:(MGroup *)value;
- (void)addDescendants:(NSSet *)values;
- (void)removeDescendants:(NSSet *)values;

- (void)addIntersectionsObject:(MIntersection *)value;
- (void)removeIntersectionsObject:(MIntersection *)value;
- (void)addIntersections:(NSSet *)values;
- (void)removeIntersections:(NSSet *)values;

- (void)addPointsObject:(MPoint *)value;
- (void)removePointsObject:(MPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end
