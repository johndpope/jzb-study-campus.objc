//
//  PointListController.h
//  iTravelPOI
//
//  Created by JZarzuela on 11/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelService.h"
#import <UIKit/UIKit.h>



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
//---------------------------------------------------------------------------------------------------------------------
typedef enum {
    SHOW_CATEGORIZED = 0,
    SHOW_FLAT = 1
} PointListShowMode;



//*********************************************************************************************************************
#pragma mark -
#pragma mark PointListController interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface PointListController : UIViewController

@property (nonatomic, retain) MEMap *map;
@property (nonatomic, retain) NSArray *filteringCategories;

@property (nonatomic, assign) PointListShowMode showMode;
@property (nonatomic, assign) ME_SORTING_METHOD    sortedBy;
@property (nonatomic, assign) ME_SORTING_ORDER     sortOrder;

@end
