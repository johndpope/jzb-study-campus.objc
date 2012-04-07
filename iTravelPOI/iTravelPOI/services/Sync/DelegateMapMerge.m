//
//  DelegateMapMerge.m
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DelegateMapMerge.h"

#import "MEMap.h"
#import "MergeEntityCat.h"
#import "DelegateMapEntityMerger.h"

#import "GMapService.h"
#import "ModelService.h"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface DelegateMapMerge()

@property (nonatomic, assign) DelegateMapEntityMerger * meMerger;

- (void) _syncLocalMap:(MEMap *) localMap withRemote:(MEMap *)remoteMap;

@end


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation DelegateMapMerge


@synthesize error = _error;
@synthesize meMerger = _meMerger;


//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        self.error = nil;
        self.meMerger = [[DelegateMapEntityMerger alloc] init];
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_meMerger release];
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) processTuple:(MECompareTuple *) tuple {
    
    
    // Variables para simplificar el codigo y hacerlo mas legible
    MEMap *localMap = (MEMap *)tuple.localEntity;
    MEMap *remoteMap = (MEMap *)tuple.remoteEntity;
    
    
    // De momento no hay error
    self.error = nil;
    
    
    // Procesa segun el estado de sincronizacion
    switch (tuple.syncStatus) {
            
            // -----------------------------------------------------
        case ST_Sync_OK:
            // No hay que hacer nada
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Create_Local:
            localMap = [MEMap map];
            [localMap mergeFrom:remoteMap withConflict:false];
            [[GMapService sharedInstance] fetchMapData:remoteMap error:&_error];
            [self _syncLocalMap:localMap withRemote:remoteMap];
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Create_Remote:
            _error = [[ModelService sharedInstance] loadMapData:localMap];
            
            for(MEPoint *point in localMap.points) {
                point.syncStatus = ST_Sync_Create_Remote;
            }
            for(MECategory *cat in localMap.categories) {
                cat.syncStatus = ST_Sync_Create_Remote;
            }
            [[GMapService sharedInstance] createNewEmptyGMap:localMap error:&_error];
            [[GMapService sharedInstance] updateGMap:localMap error:&_error];
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Delete_Local:
            [localMap markAsDeleted];
            _error = [[ModelService sharedInstance] removeMap:localMap];
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Delete_Remote:
            [[GMapService sharedInstance] deleteGMap:localMap error:&_error];
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Update_Local:
        case ST_Sync_Update_Remote:
            _error = [[ModelService sharedInstance] loadMapData:localMap];
            if(localMap.isMarkedAsDeleted) {
                [localMap unmarkAsDeleted];
            }
            [localMap mergeFrom:remoteMap withConflict:false];
            [[GMapService sharedInstance] fetchMapData:remoteMap error:&_error];
            [self _syncLocalMap:localMap withRemote:remoteMap];
            [[GMapService sharedInstance] updateGMap:localMap error:&_error];
            break;
            
        default:
            break;
    }
    
    // Graba los cambios en el mapa local
    [localMap markAsSynchronized];
    _error = [[ModelService sharedInstance] storeMap:localMap];
    
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _syncLocalMap:(MEMap *) localMap withRemote:(MEMap *)remoteMap {
    
    NSLog(@"SyncService - _syncLocalMap [%@ - %@] witn [%@ - %@]", localMap.name, localMap.GID, remoteMap.name, remoteMap.GID);
    
    // Prepara el delegate
    self.meMerger.localMap = localMap;
    
    // Mezcla primero los puntos de ambos mapas sobre el mapa local
    NSMutableArray *allLocalPoints = [NSMutableArray arrayWithArray:[localMap.points allObjects]];
    [allLocalPoints addObjectsFromArray:[localMap.deletedPoints allObjects]];
    NSMutableArray *allRemotePoints = [NSMutableArray arrayWithArray:[remoteMap.points allObjects]];
    [allRemotePoints addObjectsFromArray:[remoteMap.deletedPoints allObjects]];
    [MEComparer compareLocals:allLocalPoints remotes:allRemotePoints compDelegate:self.meMerger];
    
    // A continuación, mezcla las categorias. Pero primero las ordena poniendo primero a quien es subcategoria de otro
    NSMutableArray *allLocalCats = [NSMutableArray arrayWithArray:[MECategory sortCategorized:localMap.categories]];
    [allLocalCats addObjectsFromArray:[localMap.deletedCategories allObjects]];
    NSMutableArray *allRemoteCats = [NSMutableArray arrayWithArray:[MECategory sortCategorized:remoteMap.categories]]; 
    [allRemoteCats addObjectsFromArray:[remoteMap.deletedCategories allObjects]];
    [MEComparer compareLocals:allLocalCats remotes:allRemoteCats compDelegate:self.meMerger];
    
    // Por ultimo el ExtInfoPoint
    MEPoint *leip = localMap.extInfo;
    MEPoint *reip = remoteMap.extInfo;
    NSString *xml = leip.desc;
    [leip mergeFrom:reip withConflict:true]; 
    leip.desc = xml;
}


@end
