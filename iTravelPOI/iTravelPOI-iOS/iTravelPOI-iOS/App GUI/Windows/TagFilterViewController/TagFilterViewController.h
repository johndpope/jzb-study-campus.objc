//
//  TagFilterViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 03/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagTreeTableViewController.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface TagFilterViewController : UIViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (TagFilterViewController *) createInstanceWithDelegate:(id<TagTreeTableViewControllerDelegate>) tagTreeDelegate;



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setTagList:(NSSet *)tagList selectedTags:(NSSet *)selectedTags expandedTags:(NSSet *)expandedTags;
- (void) toggleShowFilter;

@end
