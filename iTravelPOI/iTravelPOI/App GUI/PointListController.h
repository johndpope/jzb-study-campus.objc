//
//  PointListController.h
//  iTravelPOI
//
//  Created by JZarzuela on 11/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MEMap.h"
#import <UIKit/UIKit.h>



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
//---------------------------------------------------------------------------------------------------------------------
typedef enum {
    showCategorized = 0,
    showFlat = 1
} PointListShowMode;



//*********************************************************************************************************************
#pragma mark -
#pragma mark PointListController interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface PointListController : UIViewController

@property (nonatomic, retain) MEMap *map;
@property (nonatomic, retain) NSArray *filteringCategories;
@property (nonatomic, assign) PointListShowMode showMode;


@end
