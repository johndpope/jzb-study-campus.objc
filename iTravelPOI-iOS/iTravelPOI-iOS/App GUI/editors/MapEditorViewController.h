//
//  MapEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EntityEditorDelegate.h"
#import "EntityEditorViewController.h"
#import "MMap.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface MapEditorViewController : UIViewController <EntityEditorViewController>


@property (nonatomic, strong) MMap *map;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (UIViewController<EntityEditorViewController> *) startEditingMap:(MMap *)map
                                                          delegate:(UIViewController<EntityEditorDelegate> *)delegate;





@end
