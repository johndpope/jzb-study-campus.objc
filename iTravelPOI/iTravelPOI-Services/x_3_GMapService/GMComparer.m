//
// GMComparer.m
//
// Created by Jose Zarzuela.
//

#import "GMComparer.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark Private Constants and Definitions
// ---------------------------------------------------------------------------------------------------------------------
const NSString *GMCompStatusNames[] = {
    @"CS_Equals",
    @"CS_CreateLocal", @"CS_CreateRemote",
    @"CS_DeleteLocal", @"CS_DeleteRemote",
    @"CS_UpdateLocal", @"CS_UpdateRemote"
};




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMCompareTuple Implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMCompareTuple

// ---------------------------------------------------------------------------------------------------------------------
+ (GMCompareTuple *) tupleWitLocal:(id<GMItem>)local remote:(id<GMItem>)remote {

    GMCompareTuple *me = [[GMCompareTuple alloc] init];
    me.compStatus = CS_Equals;
    me.local = local;
    me.remote = remote;
    me.conflicted = FALSE;
    return  me;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {

    return [NSString stringWithFormat:@"[GMCompareTuple: Status = '%@', conflicted = %d, local = '%@', remote = '%@']",
            GMCompStatusNames[self.compStatus],
            self.conflicted,
            self.local.name,
            self.remote.name];
}

@end




// *********************************************************************************************************************
#pragma mark -
#pragma mark GMComparer Interface Private Definition
// ---------------------------------------------------------------------------------------------------------------------
@interface GMComparer ()

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark GMComparer Implementation
// ---------------------------------------------------------------------------------------------------------------------
@implementation GMComparer




// =====================================================================================================================
#pragma mark -
#pragma mark Init && CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) compareLocalItems:(NSArray *)localItems toRemoteItems:(NSArray *)remoteItems {

    NSMutableArray *tuples = [NSMutableArray array];
    
    
    // Primero se itera la lista de elementos locales
    for(id<GMItem> local in localItems) {
        
        id<GMItem> remote = [self _findByGID:local.gID items:remoteItems];
        
        if(!remote) {
            // Procesa solo los items locales que no tienen un elemento remoto correspondiente
            [self _processUnpairedLocal:local toTuples:tuples];
        } else {
            // Procesa solo los items para los que existe el local y el remotor correspondiente
            [self _processPairedLocal:local remote:remote toTuples:tuples];
        }
    }
    
    
    // Segundo se itera la lista de elementos remotos buscando los que no tienen equivalente
    for(id<GMItem> remote in remoteItems) {
        
        if([self _findByGID:remote.gID items:localItems]==nil) {
            [self _processUnpairedRemote:remote toTuples:tuples];
        }
    }

    
    // Retorna el resultado
    return tuples;
}



// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
// Procesa solo los items locales que no tienen un elemento remoto correspondiente
+ (void) _processUnpairedLocal:(id<GMItem>)local toTuples:(NSMutableArray *)allTuples {
 
    // Crea la tupla
    GMCompareTuple *tuple = [GMCompareTuple tupleWitLocal:local remote:nil];
    [allTuples addObject:tuple];
    
        
    // El resultado dependera del estado del elemento [Ante conflicto, prevalece el estado remoto]
    // BORRADO  MODIFICADO  SINCRONIZADO   ACCION
    //   NO        NO            NO        CREATE_REMOTE
    //   NO        NO            YES       DELETE_LOCAL
    //   NO        YES           NO        CREATE_REMOTE
    //   NO        YES           YES       CREATE_REMOTE (* recreate *)
    //   YES       NO            NO        DELETE_LOCAL
    //   YES       NO            YES       DELETE_LOCAL
    //   YES       YES           NO        DELETE_LOCAL
    //   YES       YES           YES       DELETE_LOCAL
    if(local.markedAsDeleted) {
        DDLogVerbose(@"GMComparer - CS_DeleteLocal: Delete local item as it was marked as deleted and remote didn't exist: %@", local.name);
        tuple.compStatus = CS_DeleteLocal;
        
    } else if(!local.markedAsDeleted && local.wasSynchronized && !local.markedForSync) {
        DDLogVerbose(@"GMComparer - CS_DeleteLocal: Delete local item as remote was deleted: %@", local.name);
        tuple.compStatus = CS_DeleteLocal;
        
    } else if(!local.markedAsDeleted && local.wasSynchronized && local.markedForSync) {
        DDLogVerbose(@"GMComparer - CS_CreateRemote[WARNING!]: Recreate deleted remote item from local because the later was modified: %@", local.name);
        tuple.compStatus = CS_CreateRemote;
        tuple.conflicted = TRUE;
        
    } else if(!local.markedAsDeleted && !local.wasSynchronized /* modified doesn't matter */) {
        DDLogVerbose(@"GMComparer - CS_CreateRemote: Create remote from NEW local item: %@", local.name);
        tuple.compStatus = CS_CreateRemote;
        
    } else {
        // NO DEBERIA LLEGAR AQUI
        @throw [NSException exceptionWithName:@"GMComparer" reason:@"ProcessJustNewLocalItems: Error in comparer algorithm" userInfo:nil];
    }
    
}


// ---------------------------------------------------------------------------------------------------------------------
// Procesa solo los items para los que existe el local y el remotor correspondiente
+ (void) _processPairedLocal:(id<GMItem>)local remote:(id<GMItem>)remote toTuples:(NSMutableArray *)allTuples {
    
    // Crea la tupla
    GMCompareTuple *tuple = [GMCompareTuple tupleWitLocal:local remote:remote];
    [allTuples addObject:tuple];
    
    
    BOOL sameETags = [local.etag isEqualToString:remote.etag];
    
    // El resultado dependera del estado del elemento [Ante conflicto, prevalece el estado remoto]
    // BORRADO  MODIFICADO    SAME-ETAG    ACCION
    //   NO        NO            NO        UPDATE_LOCAL
    //   NO        NO            YES       NOTHING
    //   NO        YES           NO        UPDATE_LOCAL (* info lost *)
    //   NO        YES           YES       UPDATE_REMOTE
    //   YES       NO            NO        UPDATE_LOCAL (* recreate *)
    //   YES       NO            YES       DELETE_REMOTE
    //   YES       YES           NO        UPDATE_LOCAL (* recreate *)
    //   YES       YES           YES       DELETE_REMOTE
    if(sameETags && !local.markedAsDeleted && !local.markedForSync) {
        DDLogVerbose(@"GMComparer - CS_Equals: Nothing to do because both local and remote are equal: %@", local.name);
        tuple.compStatus = CS_Equals;
        
    } else if(sameETags && !local.markedAsDeleted && local.markedForSync) {
        DDLogVerbose(@"GMComparer - CS_UpdateRemote: Update remote item as local was modified: %@", local.name);
        tuple.compStatus = CS_UpdateRemote;
        
    } else if(sameETags && local.markedAsDeleted) {
        DDLogVerbose(@"GMComparer - CS_DeleteRemote: Delete remote item as both have same ETag and local was deleted: %@", local.name);
        tuple.compStatus = CS_DeleteRemote;
        
    } else if(!sameETags && !local.markedAsDeleted && !local.markedForSync) {
        DDLogVerbose(@"GMComparer - CS_UpdateLocal: Update local item as remote has different ETAG: %@", local.name);
        tuple.compStatus = CS_UpdateLocal;
        
    } else if(!sameETags && local.markedAsDeleted) {
        DDLogVerbose(@"GMComparer - CS_UpdateLocal[WARNING!]: Force update local item as remote has different ETAG and local was deleted: %@", local.name);
        tuple.compStatus = CS_UpdateLocal;
        tuple.conflicted = TRUE;
        
    } else if(!sameETags && local.markedForSync) {
        DDLogVerbose(@"GMComparer - CS_UpdateLocal[WARNING!]: Force update local item as remote has different ETAG and local was modified: %@", local.name);
        tuple.compStatus = CS_UpdateLocal;
        tuple.conflicted = TRUE;
        
    } else {
        // NO DEBERIA LLEGAR AQUI
        @throw [NSException exceptionWithName:@"GMComparer" reason:@"ProcessJustPairedLocalItems: Error in comparer algorithm" userInfo:nil];
    }
    
    
}


// ---------------------------------------------------------------------------------------------------------------------
// Procesa solo los items remotos que no tienen un elemento local correspondiente
+ (void) _processUnpairedRemote:(id<GMItem>)remote toTuples:(NSMutableArray *)allTuples {
    
    // Crea la tupla
    GMCompareTuple *tuple = [GMCompareTuple tupleWitLocal:nil remote:remote];
    [allTuples addObject:tuple];
    
    // El resultado dependera del estado del elemento
    // CREATE-LOCAL: UNICA ACCION POSIBLE
    DDLogVerbose(@"GMComparer - CS_CreateLocal: Create NEW local item from remote: %@", remote.name);
    tuple.compStatus = CS_CreateLocal;
}



// ---------------------------------------------------------------------------------------------------------------------
// Busca un item por su gID
+ (id<GMItem>) _findByGID:(NSString *)gID items:(NSArray *)items {
    
    for(id<GMItem> item in items) {
        if([item.gID isEqualToString:gID]) return item;
    }
    return nil;
}



@end
