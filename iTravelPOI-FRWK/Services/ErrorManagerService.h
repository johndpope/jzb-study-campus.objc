//
//  ErrorManagerService.h
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 03/09/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Service public enumerations & definitions
//---------------------------------------------------------------------------------------------------------------------




//*********************************************************************************************************************
#pragma mark -
#pragma mark ErrorManagerService Service interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface ErrorManagerService : NSObject



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (void) manageError:(NSError *)error compID:(NSString *)compID messageWithFormat:(NSString *)message, ...;


@end
