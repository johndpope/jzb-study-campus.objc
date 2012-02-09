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
    ST_Sync_Create_Local, ST_Sync_Create_Remote, ST_Sync_Delete_Local, ST_Sync_Delete_Remote, 
    ST_Sync_Error, ST_Sync_OK, ST_Sync_Update_Local, ST_Sync_Update_Remote
} SyncStatusType;



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TBaseEntity : NSManagedObject {
}

@property (nonatomic, retain) NSString * GID;
@property (nonatomic, retain) NSString * syncETag;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, assign) BOOL wasDeleted;
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, retain) NSString * iconURL;
@property (nonatomic, retain) NSNumber * ts_created;
@property (nonatomic, retain) NSNumber * ts_updated;
@property (nonatomic, assign) SyncStatusType syncStatus;
@property (readonly, nonatomic, assign) BOOL isLocal;

// ---------------------------------------------------------------------------------
+ (NSString *) calcRemoteCategotyETag;

- (NSString *) toXmlString;
- (NSString *) toXmlString: (unsigned) ident;


@end
