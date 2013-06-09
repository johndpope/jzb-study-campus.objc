//
//  VisualMapEditorViewController.h
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
#pragma mark <VisualMapEditorDelegate> Protocol
// *********************************************************************************************************************
@class VisualMapEditorViewController;
@protocol VisualMapEditorDelegate <NSObject>

- (BOOL) closeVisualMapEditor:(VisualMapEditorViewController *)senderEditor annotations:(NSArray *)annotations;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface VisualMapEditorViewController : UIViewController

@property (nonatomic, assign) UIViewController<VisualMapEditorDelegate> *delegate;
@property (nonatomic, strong) NSMutableArray *annotations;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (VisualMapEditorViewController *) startEditingMPoints:(NSArray *)mpoints delegate:(UIViewController<VisualMapEditorDelegate> *)delegate;
+ (VisualMapEditorViewController *) startEditingAnnotations:(NSArray *)annotations delegate:(UIViewController<VisualMapEditorDelegate> *)delegate;


@end

