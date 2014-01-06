//
//  POIEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseKeyboardViewController.h"
#import "MPoint.h"
#import "MMap.h"

@class POIEditorViewController;




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
@protocol POIEditorViewControllerDelegate<NSObject>

@optional
- (void) pointEdiorSavePoint:(POIEditorViewController *)sender;
- (void) pointEdiorCancelPoint:(POIEditorViewController *)sender;

@end





//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface POIEditorViewController : BaseKeyboardViewController

@property (nonatomic, weak) id<POIEditorViewControllerDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext *moContext;
@property (nonatomic, strong) MMap *map;
@property (nonatomic, strong) MPoint *point;




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------



@end
