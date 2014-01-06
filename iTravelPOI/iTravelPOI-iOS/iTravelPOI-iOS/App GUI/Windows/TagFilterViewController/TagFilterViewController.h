//
//  TagFilterViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MComplexFilter.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark TagFilterViewControllerDelegate Public protocol definition
//*********************************************************************************************************************
@class TagFilterViewController;
@protocol TagFilterViewControllerDelegate <NSObject>

@optional
- (void)filterHasChanged:(TagFilterViewController *)sender filter:(MComplexFilter *)filter;

@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface TagFilterViewController : UIViewController

@property (nonatomic, weak)             id<TagFilterViewControllerDelegate> delegate;

@property (nonatomic, strong)           NSManagedObjectContext              *moContext;
@property (nonatomic, strong, readonly) MComplexFilter                      *filter;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------


@end
