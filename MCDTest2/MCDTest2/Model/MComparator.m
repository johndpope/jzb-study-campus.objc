//
//  MComparator.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 19/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MComparator.h"

/*
 
 * Compara OrigArray contra DestArray
 -------------------------------------
 
 Nota 1: Un elemento que nunca haya sido sincronizado (ETAG) no seria marcado como borrado, se borraria inmediatamente
 Nota 2: Un elemento marcado como borrado no tendra la marca de modificado/necesita sincronizacion
 Nota 3: Una actualizacion local siempre elimina la marca de borrado
 Nota 4: Haremos prevalecer el no perder informacion. Siempre se puede volver a borrar.
 Nota 5: El GID no existe hasta que no se sincroniza (mientras tiene un ID local del Store)
 
 --> ETAG != NULL ==> Que ha sido sincronizado
 --> MarkedAsDeleted
 --> ModifiedSinceLastSync
 --> GID
 
 
 Local - NULL
 
 Ha sido sincronizado
 NO * ---> CREATE_REMOTE
 SI * Marcado como borrado
 SI * ---> DELETE_LOCAL (Pseudo-conflicto: Se han borrado ambos por separado)
 NO * Modificado desde ultima sincronizacion
 SI * ---> CONFLITO (local ha sido modificado y el remoto ha sido eliminado)
 !! ===> CREATE_REMOTE - VOLVEMOS A CREAR EL REMOTO, IGUALAMOS ETAGS Y QUITAMOS MARCA DE MODIFICADO
 NO * ---> DELETE_LOCAL
 
 
 NULL - Remote
 
 ---> CREATE_LOCAL
 
 
 Local - Remote
 
 Marcado como borrado
 SI * Mismo ETAG
 SI * ---> DELETE_REMOTE
 NO * ---> CONFLICTO (Local borrado y remoto modificado)
 !! ===> UPDATE_LOCAL - QUITAMOS LA MARCA DE BORRADO, IGUALAMOS ETAGS Y QUITAMOS MARCA DE MODIFICADO
 NO * Modificado desde ultima sincronizacion
 SI * Mismo ETAG
 SI * ---> UPDATE_REMOTE
 NO * ---> CONFLICTO (Ambos elementos han sufrido modificaciones simultameamente)
 !! ===> UPDATE_REMOTE - ACTUALIZAMOS EL REMOTO, IGUALAMOS ETAGS Y QUITAMOS MARCA DE MODIFICADO
 NO * Mismo ETAG
 SI * ---> NADA
 NO * ---> UPDATE_LOCAL
 
 
 
 */

//*********************************************************************************************************************
#pragma mark -
#pragma mark MComparationTuple implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MComparationTuple

@synthesize local = _local;
@synthesize remote = _remote;
@synthesize action = _action;

+ (MComparationTuple *) tupleWithLocal:(id<MComparable>)local remote:(id<MComparable>)remote action:(TCompAction) action {
    
    MComparationTuple *tuple = [[MComparationTuple alloc] init];
    tuple.local = local;
    tuple.remote = remote;
    tuple.action = action;
    return tuple;
}

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark MComparator private implementation
//---------------------------------------------------------------------------------------------------------------------
@interface MComparator()

+ (id<MComparable>) searchByGID:(NSString *)gID inArray:(NSArray *)elements;
+ (TCompAction) compareLocal:(id<MComparable>)local withRemote:(id<MComparable>)remote;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark MComparator implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MComparator

//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSArray *) compareLocals:(NSArray *)locals withRemotes:(NSArray *)remotes {
    
    NSMutableArray *result = [NSMutableArray array];
    
    // Compara todos los locales con los remotos
    for(id<MComparable> local in locals) {
        
        id<MComparable> remote = [self searchByGID:local.gID inArray:remotes];
        TCompAction compAction = [self compareLocal:local withRemote:remote];
        [result addObject:[MComparationTuple tupleWithLocal:local remote:remote action:compAction]];
    }
    
    // Compara solo los NUEVOS remotos con los locales (el resto ya fueron comparados)
    for(id<MComparable> remote in remotes) {
        
        id<MComparable> local = [self searchByGID:remote.gID inArray:locals];
        if(local==nil) {
            TCompAction compAction = [self compareLocal:local withRemote:remote];
            [result addObject:[MComparationTuple tupleWithLocal:local remote:remote action:compAction]];
        }
    }
    
    return result;
    
}




//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (id<MComparable>) searchByGID:(NSString *)gID inArray:(NSArray *)elements {
    
    // No se puede encontrar el equivalente de "nad"
    if(gID!=nil) {
        
        // Itera los elementos
        for(id<MComparable> obj in elements) {
            if([obj.gID isEqualTo:gID]) {
                return obj;
            }
        }
        
    }
    
    // No se encontro
    return nil;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (TCompAction) compareLocal:(id<MComparable>)local withRemote:(id<MComparable>)remote {
    
    
    // ------------------------------------------------------
    // EXISTE EL LOCAL PERO NO EL REMOTO
    if(local!=nil && remote==nil) {
        
        // Se crea REMOTE si LOCAL es de nueva creacion
        if(local.etag==nil) {
            return REMOTE_CREATE;
        }
        
        // Si no fue modificado o ya fue marcado como borrado se elimina LOCAL
        if(!local.modifiedSinceLastSync || local.markedAsDeleted) {
            return LOCAL_DELETE;
        }
        
        // Conflicto!! -> El LOCAL fue modificado y el REMOTE borrado
        return REMOTE_CREATE;
    }
    
    
    
    // ------------------------------------------------------
    // NO EXISTE EL LOCAL PERO SI EL REMOTO
    if(local==nil && remote!=nil) {
        return LOCAL_CREATE;
    }
    
    
    
    // ------------------------------------------------------
    // EXISTE EL LOCAL Y EL REMOTO
    if([local.etag isEqualTo:remote.etag]) {
        
        if(local.modifiedSinceLastSync) {
            return REMOTE_UPDATE;
        } else {
            if(local.markedAsDeleted) {
                return REMOTE_DELETE;
            } else {
                return NOTHING;
            }
        }
        
    } else {
        
        if(local.modifiedSinceLastSync) {
            // Conflicto!! -> El LOCAL y el REMOTE fueron ambos modificados
            return REMOTE_UPDATE;
        } else {
            if(local.markedAsDeleted) {
                // Conflicto!! -> El LOCAL fue borrado y el REMOTE fue modificado
                return LOCAL_UPDATE;
            } else {
                return LOCAL_UPDATE;
            }
        }
        
    }
    
}





@end
