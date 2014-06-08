//
//  PointListViewCell.h
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
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
@interface PointListViewCell : UITableViewCell

@property (assign, nonatomic) BOOL      checked;
@property (weak, nonatomic)   NSString *viewDistance;

@end
