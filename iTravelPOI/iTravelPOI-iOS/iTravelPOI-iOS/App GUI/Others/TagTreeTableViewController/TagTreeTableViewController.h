//
//  TagTreeTableViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagTree.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark TagTreeTableViewControllerDelegate Public protocol definition
//*********************************************************************************************************************
@class TagTreeTableViewController;
@protocol TagTreeTableViewControllerDelegate <NSObject>

@optional
- (void)tagTreeTable:(TagTreeTableViewController *)sender tappedTagTreeNode:(TagTreeNode *)tappedNode;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface TagTreeTableViewController : UIViewController

@property (weak, nonatomic) id<TagTreeTableViewControllerDelegate> delegate;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setTagList:(NSSet *)tagList selectedTags:(NSSet *)selectedTags expandedTags:(NSSet *)expandedTags;
- (void) clearTagList;
- (void) deleteBranchForTag:(MTag *)tag;


//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------



@end
