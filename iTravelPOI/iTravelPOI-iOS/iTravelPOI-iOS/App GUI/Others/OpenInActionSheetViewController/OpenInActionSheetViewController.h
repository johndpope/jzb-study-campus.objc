//
//  OpenInActionSheetViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPoint.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface OpenInActionSheetViewController : UIViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (void) showOpenInActionSheetWithControllerWithPoint:(MPoint *)point;


@end
