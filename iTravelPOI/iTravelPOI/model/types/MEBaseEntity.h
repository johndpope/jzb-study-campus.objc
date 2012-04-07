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


typedef enum {
    ME_SORT_BY_NAME = 0,
    ME_SORT_BY_CREATING_DATE = 1,
    ME_SORT_BY_UPDATING_DATE = 2
} ME_SORTING_METHOD;

typedef enum {
    ME_SORT_ASCENDING = 0,
    ME_SORT_DESCENDING = 1
} ME_SORTING_ORDER;



//*********************************************************************************************************************
#pragma mark -
#pragma mark MEBaseEntity interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MEBaseEntity : NSManagedObject 

@property (nonatomic, retain)   NSString * GID;
@property (nonatomic, retain)   NSString * syncETag;
@property (nonatomic, retain)   NSString * name;
@property (nonatomic, retain)   NSString * desc;
@property (nonatomic, retain)   GMapIcon * icon;
@property (nonatomic, retain)   NSDate * ts_created;
@property (nonatomic, retain)   NSDate * ts_updated;

@property (nonatomic, assign)   BOOL changed;
@property (nonatomic, assign)   SyncStatusType syncStatus;

@property (nonatomic, readonly) BOOL isLocal;
@property (nonatomic, readonly) BOOL isMarkedAsDeleted;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEBaseEntity CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (id) searchByGID:(NSString *)gid inArray:(NSArray *)collection;

+ (NSArray *) sortMEArray:(NSArray *)elements orderBy:(ME_SORTING_METHOD)orderBy sortOrder:(ME_SORTING_ORDER)sortOrder;

+ (NSString *) defaultIconURL;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MEBaseEntity INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------

// Persiste los cambios
- (NSError *) commitChanges;


// "Marca" la entidad como borrada y elimina sus relaciones con otras entidades.
// Quitar la marca no restaura las relaciones que antes existian
- (void) markAsDeleted;
- (void) unmarkAsDeleted;
- (BOOL) isMarkedAsDeleted;


// Representa en XML el contenido de la entidad
- (NSString *) toXmlString;
- (NSString *) toXmlString: (unsigned) ident;

@end
