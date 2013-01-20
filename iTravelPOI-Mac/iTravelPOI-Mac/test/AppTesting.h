//
//  AppTesting.h
//  iTravelPOI
//
//  Created by Jose Zarzuela on 16/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>


//*********************************************************************************************************************
#pragma mark -
#pragma mark AppTesting interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface AppTesting : NSObject


// =====================================================================================================================
#pragma mark -
#pragma mark AppTesting CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
#ifndef __AppTesting__IMPL__
- (id) init __attribute__ ((unavailable ("init not available")));
#endif

+ (void) excuteTestWithMOContext:(NSManagedObjectContext *) moContext;


@end
