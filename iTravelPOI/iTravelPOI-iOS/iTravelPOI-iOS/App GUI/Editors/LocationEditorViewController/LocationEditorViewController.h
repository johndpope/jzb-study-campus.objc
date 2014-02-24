//
//  LocationEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MPoint.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
@class LocationEditorViewController;
@protocol LocationEditorViewControllerDelegate<NSObject>

@optional
- (void) locationEditorSave:(LocationEditorViewController *)sender  coord:(CLLocationCoordinate2D)coord;
- (void) locationEditorCancel:(LocationEditorViewController *)sender;

@end





//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface LocationEditorViewController : UIViewController

@property (weak, nonatomic)   id<LocationEditorViewControllerDelegate>  delegate;
@property (assign, nonatomic) CLLocationCoordinate2D                    coordinate;
@property (strong, nonatomic) UIImage                                   *image;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------



@end
