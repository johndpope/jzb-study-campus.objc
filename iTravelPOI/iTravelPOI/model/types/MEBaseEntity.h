//
//  MEBaseEntity.h
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GMapIcon.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Enumeration definitions
//---------------------------------------------------------------------------------------------------------------------
typedef enum {
    ST_Sync_OK = 0, 
    ST_Sync_Create_Local = 1, ST_Sync_Create_Remote = 2, 
    ST_Sync_Delete_Local = 3, ST_Sync_Delete_Remote = 4, 
    ST_Sync_Update_Local = 5, ST_Sync_Update_Remote = 6,
    ST_Sync_Error = 7, 
} SyncStatusType;

static const NSString *SyncStatusType_Names[8]={
    @"ST_Sync_OK", 
    @"ST_Sync_Create_Local", @"ST_Sync_Create_Remote", 
    @"ST_Sync_Delete_Local", @"ST_Sync_Delete_Remote", 
    @"ST_Sync_Update_Local", @"ST_Sync_Update_Remote",
    @"ST_Sync_Error"
};



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEBaseEntity interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEBaseEntity : NSManagedObject {
@private
    GMapIcon *_gmapIcon;
}

@property (nonatomic, retain)   NSString * GID;
@property (nonatomic, retain)   NSString * syncETag;
@property (nonatomic, retain)   NSString * name;
@property (nonatomic, retain)   NSString * desc;
@property (nonatomic, retain)   GMapIcon * gmapIcon;
@property (nonatomic, retain)   NSDate * ts_created;
@property (nonatomic, retain)   NSDate * ts_updated;
@property (nonatomic, assign)   BOOL changed;
@property (nonatomic, readonly) BOOL isLocal;
@property (nonatomic, assign)   SyncStatusType syncStatus;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEBaseEntity CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) calcRemoteCategotyETag;
+ (id) searchByGID:(NSString *)gid inArray:(NSArray *)collection;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEBaseEntity INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------

// A llamar para persistir una entidad recien creada DESPUES que se rellene su informacion adecuadamente
- (NSError *) commitChanges;

// Necesario para borrar DEFINITIVAMENTE una entidad del modelo
- (void) deleteFromModel;

// "Marca" la entidad como borrada y elimina sus relaciones con otras entidades.
// Quitar la marca no restaura las relaciones que antes existian
- (void) markAsDeleted;
- (void) unmarkAsDeleted;


// Representa en XML el contenido de la entidad
- (NSString *) toXmlString;
- (NSString *) toXmlString: (unsigned) ident;

@end
