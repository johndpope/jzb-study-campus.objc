//
// MyCellView.h
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/09/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>



// *********************************************************************************************************************
#pragma mark -
#pragma mark Public enumerations & definitions
// *********************************************************************************************************************
#define  MyCellView_ID "MyCellViewID"



// *********************************************************************************************************************
#pragma mark -
#pragma mark MyCellView interface definition
// *********************************************************************************************************************
@interface MyCellView : NSTableCellView


@property (nonatomic, assign) NSString *labelText;
@property (nonatomic, assign) NSString *badgeText;
@property (nonatomic, assign) NSString *image;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MyCellView *) instanceFromNIB;


// =====================================================================================================================
#pragma mark -
#pragma mark Public methods
// ---------------------------------------------------------------------------------------------------------------------


@end
