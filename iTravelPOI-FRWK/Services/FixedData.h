//
//  FixedData.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 19/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark FixedData definition
//---------------------------------------------------------------------------------------------------------------------
@interface FixedData : NSObject

@property (nonatomic, strong, readonly) MGroup *fixedGroupGMaps;


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (BOOL) initFixedData:(NSManagedObjectContext *)moContext;
+ (FixedData *) fixedDataWithMOContext:(NSManagedObjectContext *)moContext;

@end
