//
//  BaseCoreData.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
    
    
//*********************************************************************************************************************
#pragma mark -
#pragma mark BaseCoreData interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface BaseCoreData : NSObject



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark BaseCoreData CLASS public methods
//---------------------------------------------------------------------------------------------------------------------

+ (NSError *)lastError;
+ (void) setLastError:(NSError *)err;

+ (NSManagedObjectContext *)moContext;

+ (NSEntityDescription *) entityByName:(NSString *)name;

+ (BOOL) initCDStack:(NSString *)modelName;

+ (BOOL) saveContext;




@end
