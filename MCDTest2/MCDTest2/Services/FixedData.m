//
//  FixedData.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 19/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "FixedData.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Definitions and Constants
//---------------------------------------------------------------------------------------------------------------------

#define FIXED_GROUP_GMAPS  @"FIXED_GROUP_GMAPS"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private FixedData definition
//---------------------------------------------------------------------------------------------------------------------
@interface FixedData()

@property (nonatomic,strong) NSManagedObjectContext *moContext;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark FixedData implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation FixedData


@synthesize moContext = _moContext;

static NSManagedObjectID *_fixedGroupGMapsID = nil;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) initFixedData {
    
    NSDictionary *fixedGroupIDs = [FixedData requestFixedGroups];
    if(!fixedGroupIDs) return FALSE;
    
    _fixedGroupGMapsID = [fixedGroupIDs objectForKey:FIXED_GROUP_GMAPS];
    if(_fixedGroupGMapsID==nil) {
        MGroup *grp = [MGroup createGroupWithName:FIXED_GROUP_GMAPS parentGrp:nil];
        grp.fixed = TRUE;
        if(grp==nil || ![BaseCoreData saveContext]) {
            NSLog(@"Error initializing fixed MGroup '%@'", FIXED_GROUP_GMAPS);
            return FALSE;
        }
        _fixedGroupGMapsID = grp.objectID;
    }
    
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
+ (FixedData *) fixedDataWithMOContext:(NSManagedObjectContext *)moContext {
    
    FixedData *instance = [[FixedData alloc] init];
    instance.moContext = moContext;
    return instance;
}




//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private CLASS methods
//---------------------------------------------------------------------------------------------------------------------
- (MGroup *) fixedGroupGMaps {
    MGroup *group = (MGroup *)[self.moContext objectWithID:_fixedGroupGMapsID];
    return group;
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSDictionary *) requestFixedGroups {
    
    
    NSError *error = nil;
    
    // Filtro a aplicar a la busqueda
    NSPredicate *filterQuery = [NSPredicate predicateWithFormat:@"fixed==TRUE"];
    
    // Se crea la peticion indicando que solo se quieren los MGroup "fixed"
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MGroup"];
    [request setPredicate:filterQuery];
    
    // Ejecuta la peticion
    NSArray *requestResults = [BaseCoreData.moContext executeFetchRequest:request error:&error];
    if (requestResults == nil) {
        BaseCoreData.lastError= error;
        NSLog(@"Error searching MGroups that are fixed. Error = %@, %@", error, [error userInfo]);
        return nil;
    }
    
    // Retorna el ID y el nombre
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    for(MGroup *group in requestResults) {
        [resultDict setObject:group.objectID forKey:group.name];
    }
    
    // retorna el resultado
    return resultDict;
}



@end
