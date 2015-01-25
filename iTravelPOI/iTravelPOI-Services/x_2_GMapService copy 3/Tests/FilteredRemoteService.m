//
// FilteredRemoteServiceBase.m
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __FilteredRemoteService__IMPL__
#define __FilteredRemoteService__PROTECTED__
#import "FilteredRemoteService.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------




// *********************************************************************************************************************
#pragma mark -
#pragma mark Interface Private Definition
// *********************************************************************************************************************
@interface FilteredRemoteService ()


@property (strong, nonatomic) NSString *mapNamePrefix;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation FilteredRemoteService




// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithEmail:(NSString *)email
                      password:(NSString *)password
                   itemFactory:(id<GMItemFactory>)itemFactory
                 mapNamePrefix:(NSString *)mapNamePrefix
                        errRef:(NSErrorRef *)errRef {
    
    
    if(self = [super initWithEmail:email password:password itemFactory:itemFactory errRef:errRef]) {
        self.mapNamePrefix = mapNamePrefix;
    }
    return self;
}




// =====================================================================================================================
#pragma mark -
#pragma mark GMItemFactory Protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) retrieveMapList:(NSErrorRef *)errRef {
    
    DDLogVerbose(@"FilteredRemoteService - retrieveMapList");

    if(!self.mapNamePrefix || self.mapNamePrefix.length==0) {
        [NSError setErrorRef:errRef domain:@"FilteredRemoteService" reason:@"Map name prefix shouldn't be nil or empty"];
        return FALSE;
    }
    
    NSArray *mapList = [super retrieveMapList:errRef];
    NSMutableArray *filteredMaps = [NSMutableArray array];
    for(id<GMMap> map in mapList) {
        if([map.name hasPrefix:self.mapNamePrefix]) {
            [filteredMaps addObject:map];
        }
    }
    return filteredMaps;
    
}


// ---------------------------------------------------------------------------------------------------------------------
// It should be able to process Maps created by another GMDataSource
- (BOOL) synchronizeMap:(id<GMMap>)map errRef:(NSErrorRef *)errRef {
    
    DDLogVerbose(@"FilteredRemoteService - synchronizeMap [%@]", map.name);
    
    if(self.mapNamePrefix && ![map.name hasPrefix:self.mapNamePrefix]) {
        [NSError setErrorRef:errRef domain:@"FilteredRemoteService" reason:@"Map name (%@) doesn't have the prefix '%@'", map.name, self.mapNamePrefix];
        return FALSE;
    }

    return [super synchronizeMap:map errRef:errRef];
}

@end
