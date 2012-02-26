//
//  PointListController.h
//  iTravelPOI
//
//  Created by jzarzuela on 19/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointCatEditorController.h"
#import "MEMap.h"
#import "MECategory.h"

typedef enum {
    showCategorized = 0,
    showFlat = 1
} PointListShowMode;

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface PointListController : UITableViewController <PointCatEditorDelegate> {
    
}

@property (nonatomic, retain) MEMap *map;
@property (nonatomic, retain) NSArray *filteringCategories;
@property (nonatomic, assign) PointListShowMode showMode;

- (void) changeShowMode:(PointListShowMode) mode;

@end
