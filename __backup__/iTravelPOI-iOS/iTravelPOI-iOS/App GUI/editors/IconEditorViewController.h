//
//  IconEditorViewController.h
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
@class IconEditorViewController;
@protocol IconEditorDelegate <NSObject>

- (BOOL) closeIconEditor:(IconEditorViewController *)senderEditor;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface IconEditorViewController : UIViewController

@property (nonatomic, strong) NSString *iconBaseHREF;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (IconEditorViewController *) startEditingIcon:(NSString *)iconBaseHREF delegate:(UIViewController<IconEditorDelegate> *)delegate;


@end
