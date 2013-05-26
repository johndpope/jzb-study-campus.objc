//
//  TExpandableTableItem.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 25/05/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@class MCategory;
@interface TExpandableTableItem : NSObject


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (TExpandableTableItem *) expandableTableItemWithCategory:(MCategory *)cat isChecked:(BOOL) isChecked;

+ (UIImage *) imageChecked;
+ (UIImage *) imageUnchecked;



//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) fillCellView:(UITableViewCell *)cell withIndex:(NSInteger)index;
- (MCategory *) clickedAtIndex:(NSInteger)index selCats:(NSArray *)selCats excludedCat:(MCategory *)excludedCat;
- (NSInteger) currentSize;
- (BOOL) isChecked;
- (void) clearCheck;


@end
