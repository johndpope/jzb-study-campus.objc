//
//  TBaseEntity.h
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


//*********************************************************************************************************************
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
//---------------------------------------------------------------------------------------------------------------------
@interface TBaseEntity : NSManagedObject

@property (nonatomic, retain) NSString * GID;
@property (nonatomic, retain) NSString * syncETag;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * desc;
@property (readonly, nonatomic, assign) BOOL wasDeleted;
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, retain) NSString * iconURL;
@property (nonatomic, retain) NSDate * ts_created;
@property (nonatomic, retain) NSDate * ts_updated;
@property (nonatomic, assign) SyncStatusType syncStatus;
@property (readonly, nonatomic, assign) BOOL isLocal;

// ---------------------------------------------------------------------------------
+ (NSString *) calcRemoteCategotyETag;
+ (id) searchByGID:(NSString *)gid inArray:(NSArray *)collection;

// Explicitado porque el marcado implica borrar sus relaciones
// Quitar la marca no restaura las relaciones que antes existian
- (void) markAsDeleted;
- (void) unmarkAsDeleted;

- (void) deleteFromModel;

- (NSString *) toXmlString;
- (NSString *) toXmlString: (unsigned) ident;

@end
