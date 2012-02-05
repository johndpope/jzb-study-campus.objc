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


#define LOCAL_ETAG_PREFIX  @"@Local-"
#define LOCAL_ID_PREFIX    @"@cafe-"
#define REMOTE_ETAG_PREFIX @"@Sync-"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------

static long  s_idCounter        = -1;


//---------------------------------------------------------------------------------------------------------------------
//synchronized 
long _getNextIdCounter() {
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




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TBaseEntity() {
}

@end

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation TBaseEntity

@dynamic name;
@dynamic desc;
@dynamic deleted;
@dynamic changed;
@dynamic ts_created;
@dynamic syncETag;
@dynamic GID;
@dynamic ts_updated;
@dynamic NoSe;
@dynamic icon;



//---------------------------------------------------------------------------------------------------------------------
/*
+ (TBaseEntity *) insertNew {
    
    m_type = type;
    m_id = _calcLocalId();
    m_name = "";
    m_shortName = null;
    m_description = "";
    m_icon = getDefaultIcon();
    m_changed = false;
    m_markedAsDeleted = false;
    m_syncETag = _calcLocalETag();
    t_syncStatus = SyncStatusType.Sync_OK;
    
    m_ts_created = m_ts_updated = TDateTime.now();
    
}
 */

@end
