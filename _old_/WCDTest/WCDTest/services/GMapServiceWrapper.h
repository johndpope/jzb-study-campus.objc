//
//  GMapServiceWrapper.h
//  WCDTest
//
//  Created by jzarzuela on 13/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GData.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface GMapServiceWrapper : NSObject


- (void)             setUserCredentialsWithUsername:(NSString *)email password:(NSString *)password;
- (GDataFeedBase *)  fetchUserMapList:(NSError **)err;
- (GDataFeedBase *)  fetchMapDataWithGID:(NSString *)mapGID error:(NSError **)err;
- (GDataEntryMap *) insertMapEntry:(GDataEntryMap *)gmapEntry userID:(NSString *)loggedID error:(NSError **)err;
- (GDataFeedBase *)  deleteMapDataWithGID:(NSString *)mapGID error:(NSError **)err;
- (GDataEntryMap *) fetchUpdatedMapDataWithGID:(NSString *)mapGID error:(NSError **)err;

- (GDataEntryMapFeature *) insertMapFeatureEntry:(GDataEntryMapFeature *)featureEntry  inMapWithGID:(NSString *)mapGID error:(NSError **)err;
- (GDataEntryMapFeature *) deleteMapFeatureEntryWithGID:(NSString *)featureGID  inMapWithGID:(NSString *)mapGID error:(NSError **)err;
- (GDataEntryMapFeature *) updateMapFeatureEntry:(GDataEntryMapFeature *)featureEntry  withGID:(NSString *)featureGID inMapWithGID:(NSString *)mapGID error:(NSError **)err;

@end
