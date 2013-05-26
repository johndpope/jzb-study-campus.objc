//
//  PointEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EntityEditorDelegate.h"
#import "EntityEditorViewController.h"
#import "MPoint.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface PointEditorViewController : UIViewController <EntityEditorViewController>

@property (nonatomic, strong) MPoint *point;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (UIViewController<EntityEditorViewController> *) startEditingPoint:(MPoint *)Point
                                                               delegate:(UIViewController<EntityEditorDelegate> *)delegate;




@end
