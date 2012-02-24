//
//  PointListController.h
//  iTravelPOI
//
//  Created by jzarzuela on 19/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointCatEditorController.h"
#import "TMap.h"
#import "TCategory.h"

typedef enum {
    showCategorized = 0,
    showFlat = 1
} PointListShowMode;

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface PointListController : UITableViewController <PointCatEditorDelegate> {
    
}

@property (nonatomic, retain) TMap *map;
@property (nonatomic, retain) NSArray *filteringCategories;
@property (nonatomic, assign) PointListShowMode showMode;

@end
