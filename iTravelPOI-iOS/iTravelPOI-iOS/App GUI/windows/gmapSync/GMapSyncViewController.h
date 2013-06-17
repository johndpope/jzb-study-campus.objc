//
//  GMapSyncViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
typedef void (^TCloseCallback)();




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface GMapSyncViewController: UIViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (GMapSyncViewController *) gmapSyncViewControllerWithContext:(NSManagedObjectContext *)moContext;
- (void) showModalWithController:(UIViewController *)controller closeCallback:(TCloseCallback)closeCallback;


@end
