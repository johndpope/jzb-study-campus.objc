//
//  CategorySelectorViewController.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCategory.h"
#import "MMap.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Delegate Protocol
//*********************************************************************************************************************
@class CategorySelectorViewController;
@protocol CategorySelectorDelegate <NSObject>

- (BOOL) closeCategorySelector:(CategorySelectorViewController *)senderEditor
            selectedCategories:(NSArray *)selectedCategories;

@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface CategorySelectorViewController : UIViewController


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (CategorySelectorViewController *) startCategoriesSelectorInContext:(NSManagedObjectContext *)moContext
                                                          selectedMap:(MMap *)selectedMap
                                                  currentSelectedCats:(NSArray *)currentSelectedCats
                                                  excludeFromCategory:(MCategory *)excludeFromCategory
                                                       multiSelection:(BOOL)multiSelection
                                                             delegate:(UIViewController<CategorySelectorDelegate> *)delegate;



@end
