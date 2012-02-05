//
//  TBaseEntity.m
//  CDTest
//
//  Created by Snow Leopard User on 04/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TBaseEntity.h"
#import "TIcon.h"
//#include "stdlib.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------

#define LOCAL_ETAG_PREFIX  @"@Local-"
#define LOCAL_ID_PREFIX    @"@cafe-"
#define REMOTE_ETAG_PREFIX @"@Sync-"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------

//synchronized 
long _getNextIdCounter();
NSString* _calcLocalETag();
NSString* _calcRemoteCategoryETag();
NSString* _calcLocalGID();




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TBaseEntity() {
}

@property (nonatomic, retain) NSNumber * _i_deleted;
@property (nonatomic, retain) NSNumber * _i_changed;

- (void) initEntity;


@end

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation TBaseEntity

@dynamic name;
@dynamic desc;
@dynamic _i_deleted;
@dynamic _i_changed;
@dynamic ts_created;
@dynamic syncETag;
@dynamic GID;
@dynamic ts_updated;
@dynamic icon;
@synthesize syncStatus = _syncStatus;


//---------------------------------------------------------------------------------------------------------------------
- (void) initEntity
{
    self.GID = _calcLocalGID(); 
    self.name = @"";
    self.desc = @"";
    self.icon = nil; // Hay que crear un icono por defecto ( getDefaultIcon(); )
    self.changed = false;
    self.deleted = [NSNumber numberWithBool:false];
    self.syncETag = _calcLocalETag();
    self.syncStatus = ST_Sync_OK;
    self.ts_created = [NSNumber numberWithLong:time(0L)];
    self.ts_updated = [NSNumber numberWithLong:time(0L)];
}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL) changed {
    return [self._i_changed boolValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setChanged:(BOOL)value {
    self._i_changed = [NSNumber numberWithBool:value];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleted {
    return [self._i_deleted boolValue];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setDeleted:(BOOL)value {
    self._i_deleted = [NSNumber numberWithBool:value];
}

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
//synchronized 
long _getNextIdCounter() {

    static long  s_idCounter        = -1;

    if(s_idCounter<0) {
        srand((unsigned)time(0L));
        s_idCounter = 100*rand();
    }
    return s_idCounter++;
}


//---------------------------------------------------------------------------------------------------------------------
NSString* _calcLocalETag() {
    
    long nCounter = _getNextIdCounter();
    NSString * lEtag = [NSString stringWithFormat:@"%@-%u-%u", LOCAL_ETAG_PREFIX,time(0L),nCounter];
    return lEtag;
}


//---------------------------------------------------------------------------------------------------------------------
NSString* _calcRemoteCategoryETag() {
    long nCounter = _getNextIdCounter();
    NSString * lEtag = [NSString stringWithFormat:@"%@-%u-%u", REMOTE_ETAG_PREFIX,time(0L),nCounter];
    return lEtag;
}

//---------------------------------------------------------------------------------------------------------------------
NSString* _calcLocalGID() {
    long nCounter = _getNextIdCounter();
    NSString * lGID = [NSString stringWithFormat:@"%@-%u-%u", LOCAL_ID_PREFIX,time(0L),nCounter];
    return lGID;
}
