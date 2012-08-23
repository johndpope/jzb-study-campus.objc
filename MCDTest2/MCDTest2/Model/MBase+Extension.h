//
//  MBase+Extension.h
//  MCDTest2
//
//  Created by Jose Zarzuela on 03/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "Model.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark MBase+Extension category definition
//---------------------------------------------------------------------------------------------------------------------
@interface MBase (Extension)



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MBase+Extension CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (UInt32) calcUID;
+ (NSString *) stringForUID:(UInt32)uid;

@end
