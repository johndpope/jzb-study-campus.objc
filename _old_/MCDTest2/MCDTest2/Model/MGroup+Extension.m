//
//  MGroup+Extension.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 03/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MGroup+Extension.h"
#import "../Services/BaseCoreData.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark MGroup+Extension category implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MGroup (Extension)


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MGroup+Extension CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MGroup *) createGroupWithName:(NSString *)name parentGrp:(MGroup *)parent {
    
    
    MGroup *grp = [NSEntityDescription insertNewObjectForEntityForName:@"MGroup" inManagedObjectContext:BaseCoreData.moContext];
    
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
+ (NSArray *) rootGroups {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MGroup"];
    
    NSPredicate *query = [NSPredicate predicateWithFormat:@"parent=NIL"];
    [request setPredicate:query];
    
    NSError *error = nil;
    NSArray *array = [BaseCoreData.moContext executeFetchRequest:request error:&error];
    if (array == nil) {
        BaseCoreData.lastError= error;
        NSLog(@"Error searching root MGroups (no ancestors). Error = %@, %@", error, [error userInfo]);
        return nil;
    } else {
        return array;
        
    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (MGroup *) searchGroupByName:(NSString *)name {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MGroup"];
    
    //    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MGroup" inManagedObjectContext:BaseCoreData.moContext];
    //    [request setEntity:entityDescription];
    
    NSPredicate *query = [NSPredicate predicateWithFormat:@"name=%@", name];
    [request setPredicate:query];
    
    NSError *error = nil;
    NSArray *array = [BaseCoreData.moContext executeFetchRequest:request error:&error];
    if (array == nil) {
        BaseCoreData.lastError= error;
        NSLog(@"Error searching MGroup by name '%@'. Error = %@, %@", name, error, [error userInfo]);
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
