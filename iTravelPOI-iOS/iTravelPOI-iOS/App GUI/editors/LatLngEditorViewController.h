//
//  LatLngEditorViewController.h
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





// *********************************************************************************************************************
#pragma mark -
#pragma mark <IconEditorPanelDelegate> Protocol
// *********************************************************************************************************************
@class LatLngEditorViewController;
@protocol LatLngEditorDelegate <NSObject>

- (BOOL) closeLatLngEditor:(LatLngEditorViewController *)senderEditor Lat:(CGFloat)latitude Lng:(CGFloat)longitude;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface LatLngEditorViewController : UIViewController


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (LatLngEditorViewController *) startEditingLat:(CGFloat)latitude Lng:(CGFloat)longitude delegate:(UIViewController<LatLngEditorDelegate> *)delegate;


@end

