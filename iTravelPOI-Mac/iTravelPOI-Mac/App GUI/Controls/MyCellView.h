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


@property (nonatomic, readonly) NSString *labelText;
@property (nonatomic, readonly) NSString *badgeText;
@property (nonatomic, readonly) NSImage  *image;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MyCellView *) instanceFromNIB;


// =====================================================================================================================
#pragma mark -
#pragma mark Public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) setLabelText:(NSString *)labelText badgeText:(NSString *)badgeText image:(NSImage *)image;

@end
