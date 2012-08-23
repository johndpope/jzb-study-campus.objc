//
//  ModelUtils.m
//  CDFindTest
//
//  Created by Jose Zarzuela on 28/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "ModelUtils.h"
#import "AppDelegate.h"

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@interface ModelUtils ()

@end


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@implementation ModelUtils

static UInt32 _counter = 0;
static NSManagedObjectContext *_moctx = nil;


//------------------------------------------------------------------------------------------------------------------
NSManagedObjectContext* _context() {
    
    if(_moctx==nil) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        _moctx = appDelegate.managedObjectContext;
    }
    return _moctx;
}

//------------------------------------------------------------------------------------------------------------------
NSString * _calcID() {
    NSString *uid = [NSString stringWithFormat:@"UID-%08lu",_counter++];
    return uid;
}

//------------------------------------------------------------------------------------------------------------------
+ (MGroup *) createGroupWithName:(NSString *)name parentGrp:(MGroup *)parent {
    
    NSManagedObjectContext *moc = _context();
    
    MGroup *grp = [NSEntityDescription insertNewObjectForEntityForName:@"MGroup" inManagedObjectContext:moc];
    grp.uID = _calcID();
    grp.name = name;
    grp.root = parent ? parent.root : nil;
    grp.level = parent ? parent.level+1 : 0;
    
    [parent addDescendantsObject:grp];
    for(MGroup *ancestorGroup in parent.ancestors) {
        [ancestorGroup addDescendantsObject:grp];
    }
    
    NSError *error = nil;
    [moc save:&error];
    if(error) {
        NSLog(@"Error creating & saving MGroup- %@",error);
    }
    
    return grp;
    
}

//------------------------------------------------------------------------------------------------------------------
+ (MPoint *) createPointWithName:(NSString *)name {
    
    NSManagedObjectContext *moc = _context();
    
    MPoint *point = [NSEntityDescription insertNewObjectForEntityForName:@"MPoint" inManagedObjectContext:moc];
    point.name = name;
    
    
    NSError *error = nil;
    [moc save:&error];
    if(error) {
        NSLog(@"Error creating & saving MPoint- %@",error);
    }
    
    return point;
    
}

//------------------------------------------------------------------------------------------------------------------
NSString* _calcIntersectionID(NSSet *groups) {
    
    if([groups count]<=0){
        return nil;
    }
    
    NSArray *sortedGroups = [groups sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uID" ascending:TRUE]]];
    
    NSMutableString *uid = [NSMutableString stringWithString:@"INTERSECT"];
    for(MGroup *grp in sortedGroups) {
        [uid appendFormat:@"|%@",grp.uID];
    }
    
    return [uid copy];
}

//------------------------------------------------------------------------------------------------------------------
MIntersection * _getIntersection(NSSet *groups) {
    
    NSString *uid = _calcIntersectionID(groups);
    if(uid==nil || [uid length]<=0) {
        return nil;
    }
    
    NSManagedObjectContext *moc = _context();
    
    
    NSFetchRequest *request = [NSFetchRequest new];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MIntersection" inManagedObjectContext:moc];
    [request setEntity:entityDescription];
    
    NSPredicate *query = [NSPredicate predicateWithFormat:@"uID='%@'", uid];
    [request setPredicate:query];
    
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil) {
        NSLog(@"Error searching for MIntersection with name = '%@'",uid);
        return nil;
    } else {
        if([array count]>0) {
            return [array objectAtIndex:0];
        } else {
            MIntersection *intersection = [NSEntityDescription insertNewObjectForEntityForName:@"MIntersection" inManagedObjectContext:moc];
            intersection.uID = uid;
            
            NSError *error = nil;
            NSManagedObjectContext *moc = _context();
            [moc save:&error];
            if(error) {
                NSLog(@"Error saving new MIntersection - %@",error);
            }
            
            return intersection;
        }
    }
}

//------------------------------------------------------------------------------------------------------------------
+ (void) updatePoint:(MPoint *)point withGroups:(NSSet *)groups {
    
    NSSet *previousGroups = [NSSet setWithSet:point.groups];
    
    NSMutableSet *deletedGroups = [NSMutableSet setWithSet:point.groups];
    [deletedGroups minusSet:groups];
    
    NSMutableSet *newGroups = [NSMutableSet setWithSet:groups];
    [newGroups minusSet:point.groups];
    
    
    for(MGroup *grp in deletedGroups) {
        [grp removePointsObject:point];
        grp.count--;
    }
    
    for(MGroup *grp in newGroups) {
        [grp addPointsObject:point];
        grp.count++;
    }
    
    MIntersection *prevInt = _getIntersection(previousGroups);
    prevInt.count--;
    if(prevInt.count<=0) {
        NSSet *groups = [NSSet setWithSet:prevInt.groups];
        [prevInt removeGroups:groups];
    }
    
    MIntersection *actInt = _getIntersection(point.groups);
    actInt.count++;
    if(actInt.count==1) {
        [actInt addGroups:point.groups];
    }
    
    NSError *error = nil;
    NSManagedObjectContext *moc = _context();
    [moc save:&error];
    if(error) {
        NSLog(@"Error updating groups in MPoint- %@",error);
    }
    
}




@end
