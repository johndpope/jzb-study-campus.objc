//
//  KmlBackup.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 28/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMap.h"
#import "GMTMap.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface KmlBackup : NSObject


@property (strong, nonatomic) NSManagedObjectContext *moContext;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) backupFolderWithDate:(NSDate *)date error:(NSError **)error;
+ (BOOL) backupRemoteMap:(GMTMap *)map inFolder:(NSString *)folder error:(NSError *__autoreleasing *)error;
+ (BOOL) backupLocalMap:(MMap *)map inFolder:(NSString *)folder error:(NSError * __autoreleasing *)error;



@end
