//
//  DelegateMapEntityMerger.m
//  iTravelPOI
//
//  Created by JZarzuela on 06/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DelegateMapEntityMerger.h"
#import "MergeEntityCat.h"




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
MEBaseEntity * _createNewLocalEntity(MEMap *localMap, MEBaseEntity *remoteEntity);
BOOL _needToBeUpdatedAfterCreateLocally(MEBaseEntity *item1, MEBaseEntity *item2);



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation DelegateMapEntityMerger


@synthesize localMap = _localMap;
@synthesize items = _items;


//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
        self.items = [NSMutableArray array];
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_localMap release];
    [_items release];
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) processTuple:(MECompareTuple *) tuple {
    
    switch (tuple.syncStatus) {
            
            // -----------------------------------------------------
        case ST_Sync_OK:
            tuple.localEntity.syncStatus = ST_Sync_OK;
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Create_Local:
            
            tuple.localEntity = _createNewLocalEntity(self.localMap, tuple.remoteEntity);
            [tuple.localEntity mergeFrom:tuple.remoteEntity withConflict:false];
            tuple.localEntity.syncStatus = ST_Sync_Create_Local;
            
            // Si no quedaron iguales, porque faltaban dependencias, hay que actualizar el remoto tambien
            if(_needToBeUpdatedAfterCreateLocally(tuple.localEntity, tuple.remoteEntity)){
                NSLog(@"Created local entity differs from the original remote and the later must be updated: %@",tuple.remoteEntity.name);
                tuple.localEntity.syncStatus = ST_Sync_Update_Remote;
            }
            
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Create_Remote:
            tuple.localEntity.syncStatus = ST_Sync_Create_Remote;
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Delete_Local:
            tuple.localEntity.syncStatus = ST_Sync_Delete_Local;
            [tuple.localEntity markAsDeleted];
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Delete_Remote:
            tuple.localEntity.syncStatus = ST_Sync_Delete_Remote;
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Update_Local:
            [tuple.localEntity mergeFrom:tuple.remoteEntity withConflict:false];
            tuple.localEntity.syncStatus = ST_Sync_Update_Local;
            break;
            
            // -----------------------------------------------------
        case ST_Sync_Update_Remote:
            if(tuple.localEntity.isMarkedAsDeleted) {
                [tuple.localEntity unmarkAsDeleted];
            }
            if(tuple.withConflict) {
                [tuple.localEntity mergeFrom:tuple.remoteEntity withConflict:true];
            }
            tuple.localEntity.syncStatus = ST_Sync_Update_Remote;
            break;
            
            // -----------------------------------------------------
        default:
            break;
    }
    
    
    // Añade a los elementos a procesas
    [self.items addObject:tuple.localEntity];
}

//---------------------------------------------------------------------------------------------------------------------
MEBaseEntity * _createNewLocalEntity(MEMap *localMap, MEBaseEntity *remoteEntity) {
    
    if([remoteEntity isKindOfClass: [MEMap class]]) {
        return [MEMap map];
    } else if([remoteEntity isKindOfClass: [MECategory class]]) {
        return [MECategory categoryInMap:localMap];
    } else if([remoteEntity isKindOfClass: [MEPoint class]]) {
        return [MEPoint pointInMap:localMap];
    } else {
        return nil;
    }
    
}

// ----------------------------------------------------------------------------------------------------
BOOL _needToBeUpdatedAfterCreateLocally(MEBaseEntity *item1, MEBaseEntity *item2) {
    
    // Solo comprueba que las categorias terminan teniendo el mismo numero de subelementos
    if([item1 isKindOfClass:[MECategory class]]) {
        MECategory *c1 = (MECategory *)item1;
        MECategory *c2 = (MECategory *)item2;
        BOOL eq1 = [c1.points count] == [c2.points count];
        BOOL eq2 = [c1.subcategories count] == [c2.subcategories count];
        return eq1 && eq2;
    }else {
        return false;
    }
}


@end
