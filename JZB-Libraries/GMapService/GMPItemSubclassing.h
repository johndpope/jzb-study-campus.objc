//
// GMPItemSubclassing.h
// GMapService
//
// Created by Jose Zarzuela on 02/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>


// *********************************************************************************************************************
#pragma mark -
#pragma mark protocol definition
// *********************************************************************************************************************
@protocol GMPItemSubclassing <NSObject>

@optional

- (NSString *) __itemTypeName;
- (void) __atomEntryDataContent:(NSMutableString *)atomStr;
- (void) __verifyFieldsNotNil:(NSMutableArray *)result;
- (void) __descriptionPutExtraFields:(NSMutableString *)mutStr;


@end
