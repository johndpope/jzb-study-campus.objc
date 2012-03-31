//
//  GMapSyncWrapper.h
//  iTravelPOI
//
//  Created by JZarzuela on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GData.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark GMapSyncWrapper interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GMapSyncWrapper : NSObject



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark GMapSyncWrapper CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) extract_Logged_UserID_fromFeed:(GDataFeedBase *) feed;
+ (NSString *) extract_MapID_fromEntry:(GDataEntryMap *) entry;
+ (NSString *) extract_PointID_fromEntry:(GDataEntryMapFeature *) entry;
+ (NSString *) get_KML_fromEntry:(GDataEntryMapFeature *) entry;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark GMapSyncWrapper INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void)             setUserCredentialsWithUsername:(NSString *)email password:(NSString *)password;

- (GDataFeedBase *)  fetchUserMapList:(NSError **)err;
- (GDataFeedBase *)  fetchMapDataWithGID:(NSString *)mapGID error:(NSError **)err;
- (GDataEntryMap *)  inserMapEntry:(GDataEntryMap *)gmapEntry userID:(NSString *)loggedID error:(NSError **)err;
- (GDataEntryMap *)  deleteMapWithGID:(NSString *)mapGID error:(NSError **)err;
- (GDataEntryMap *)  fetchUpdatedMapDataWithGID:(NSString *)mapGID error:(NSError **)err;

- (GDataEntryMapFeature *) inserMapFeatureEntry:(GDataEntryMapFeature *)featureEntry  inMapWithGID:(NSString *)mapGID error:(NSError **)err;
- (GDataEntryMapFeature *) deleteMapFeatureEntryWithGID:(NSString *)featureGID  inMapWithGID:(NSString *)mapGID error:(NSError **)err;
- (GDataEntryMapFeature *) updateMapFeatureEntry:(GDataEntryMapFeature *)featureEntry  withGID:(NSString *)featureGID inMapWithGID:(NSString *)mapGID error:(NSError **)err;


@end
