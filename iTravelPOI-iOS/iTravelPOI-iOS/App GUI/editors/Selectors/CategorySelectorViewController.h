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
typedef void (^CSCloseCallback)(NSArray *selectedCategories);




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface CategorySelectorViewController : UIViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (CategorySelectorViewController *) categoriesSelectorInContext:(NSManagedObjectContext *)moContext
                                                     selectedMap:(MMap *)selectedMap
                                             currentSelectedCats:(NSArray *)currentSelectedCats
                                                  multiSelection:(BOOL)multiSelection;

- (void) showModalWithController:(UIViewController *)controller closeCallback:(CSCloseCallback)closeCallback;


@end
