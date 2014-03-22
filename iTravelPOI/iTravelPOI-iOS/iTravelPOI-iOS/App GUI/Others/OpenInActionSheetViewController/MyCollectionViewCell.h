//
//  MyCollectionViewCell.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
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
@interface MyCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
