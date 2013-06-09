//
//  BreadcrumbBar.h
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



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Delegate Protocol definition
//*********************************************************************************************************************
@class BreadcrumbBar;
@protocol BreadcrumbBarDelegate <UIScrollViewDelegate>

@optional
- (void) itemRemovedFromBreadcrumbBar:(BreadcrumbBar *)sender
                        removedItemTitle:(NSString *)title
                         removedItemData:(id)data;

- (void) activeItemUptatedInBreadcrumbBar:(BreadcrumbBar *)sender
                             activeItemTitle:(NSString *)title
                              activeItemData:(id)data
                           removedItemsCount:(NSUInteger)removedItemsCount;

@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface BreadcrumbBar : UIView

@property (nonatomic, weak) id<BreadcrumbBarDelegate> delegate;
@property (nonatomic, assign, getter = isEnabled, setter = setEnabled:) BOOL enabled;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) addItemWithTitle:(NSString *)title image:(UIImage *)image data:(id)data;
- (NSUInteger) count;


@end
