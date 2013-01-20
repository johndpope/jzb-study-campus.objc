//
//  MGroup+Extension.m
//  iTravelPOI
//
//  Created by Jose Zarzuela on 03/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MGroup+Extension.h"
#import "ErrorManagerService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark MGroup+Extension category implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MGroup (Extension)


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MGroup+Extension CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MGroup *) createGroupWithName:(NSString *)name parentGrp:(MGroup *)parent inContext:(NSManagedObjectContext *)moContext {
    
    MGroup *grp = [NSEntityDescription insertNewObjectForEntityForName:@"MGroup" inManagedObjectContext:moContext];
    
    grp.name = name;
    
    UInt32 uid = [MBase calcUID];
    NSString *strUID = [MBase stringForUID:uid];
    
    if(parent) {
        grp.parent = parent;
        grp.treeUID = parent.treeUID;
        grp.treePath = [NSString stringWithFormat:@"%@%@",parent.treePath, strUID];
    } else {
        grp.parent = nil;
        grp.treeUID = strUID;
        grp.treePath = strUID;
    }
    
    return grp;
    
}


//---------------------------------------------------------------------------------------------------------------------
// TODO: Podría ser bueno cachear esta busqueda
+ (NSArray *) rootGroupsInContext:(NSManagedObjectContext *)moContext {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MGroup"];
    
    NSPredicate *query = [NSPredicate predicateWithFormat:@"parent=NIL"];
    [request setPredicate:query];
    
    NSError *error = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&error];
    if (array == nil) {
        [ErrorManagerService manageError:error compID:@"MGroup+Extension" messageWithFormat:@"Error searching root MGroups (no ancestors)"];
        return nil;
    } else {
        return array;
        
    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (MGroup *)  searchGroupByName:(NSString *)name inContext:(NSManagedObjectContext *)moContext {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MGroup"];
    NSPredicate *query = [NSPredicate predicateWithFormat:@"name=%@", name];
    [request setPredicate:query];
    
    NSError *error = nil;
    NSArray *array = [moContext executeFetchRequest:request error:&error];
    if (array == nil) {
        [ErrorManagerService manageError:error compID:@"MGroup+Extension" messageWithFormat:@"Error searching MGroup by name '%@'",name];
        return nil;
    } else {
        return [array count]>0?[array objectAtIndex:0]:nil;
    }
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark PUBLIC general methods
//---------------------------------------------------------------------------------------------------------------------
- (MGroup *)root {
    MGroup *group = self;
    while(group.parent!=nil) {
        group = group.parent;
    }
    return group;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isAncestorOf:(MGroup *)group {
    BOOL isAncestor = (self.treeUID==group.treeUID) && (self.treePath.length<group.treePath.length) && [group.treePath hasPrefix:self.treePath];
    return isAncestor;
}





@end
