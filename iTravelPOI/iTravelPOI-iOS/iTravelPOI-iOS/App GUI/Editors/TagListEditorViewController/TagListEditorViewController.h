//
//  TagListEditorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseKeyboardViewController.h"

@class MPoint;




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
@class TagListEditorViewController;
@protocol TagListEditorViewControllerDelegate <NSObject>

@optional
- (void) tagListEditor:(TagListEditorViewController *)sender assignedTags:(NSArray *)assignedTags;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface TagListEditorViewController : BaseKeyboardViewController


@property (nonatomic, strong) id<TagListEditorViewControllerDelegate> delegate;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setContext:(NSManagedObjectContext *)moContext assignedTags:(NSSet *)assignedTags availableTags:(NSMutableSet *)availableTags;


@end
