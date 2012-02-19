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

//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface PointListController : UITableViewController <PointCatEditorDelegate> {
    
}

@property (nonatomic, retain) TMap *map;

@end
