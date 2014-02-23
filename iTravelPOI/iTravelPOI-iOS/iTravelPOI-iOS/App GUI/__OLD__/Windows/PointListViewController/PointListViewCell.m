//
//  PointListViewCell.m
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointListViewCell__IMPL__
#import "PointListViewCell.h"
#import "UIImage+Tint.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointListViewCell ()

@property (strong, nonatomic) UIImageView *leftCheckedView;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation PointListViewCell


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
        UIImage *img = [UIImage imageNamed:@"checkmark0" burnTint:self.tintColor];
        self.leftCheckedView = [[UIImageView alloc] initWithFrame:CGRectMake(-img.size.width, 15, img.size.width, img.size.height)];
        [self.contentView addSubview:self.leftCheckedView];
	}
	return self;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if(!self.editing) {
        CGRect rect = self.leftCheckedView.frame;
        rect.origin.x = -rect.size.width;
        self.leftCheckedView.frame = rect;
        self.leftCheckedView.image = nil;
    } else {
        CGRect rect = self.leftCheckedView.frame;
        rect.origin.x = -(self.contentView.frame.origin.x+rect.size.width)/2;
        rect.origin.y = 15;
        self.leftCheckedView.frame = rect;
        self.leftCheckedView.image = self.checked ? [UIImage imageNamed:@"checkmark2" burnTint:self.tintColor] : [UIImage imageNamed:@"checkmark0" burnTint:self.tintColor];
    }
    
    CGRect r = self.imageView.frame;
    CGFloat diff = 15 - r.origin.y;
    r.origin.y += diff;
    self.imageView.frame = r;
    
    r = self.textLabel.frame;
    r.origin.y += diff;
    self.textLabel.frame = r;

    r = self.detailTextLabel.frame;
    r.origin.y += diff;
    self.detailTextLabel.frame = r;
}

//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) leftCheckedImage:(UIColor *)tintColor {
    
    static UIImage *__leftcheckedImage = nil;
    if(__leftcheckedImage == nil) {
        __leftcheckedImage = [UIImage imageNamed:@"checkmark1" burnTint:tintColor];
    }
    return __leftcheckedImage;
}


//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) leftUncheckedImage:(UIColor *)tintColor {
    
    static UIImage *__leftuncheckedImage = nil;
    if(__leftuncheckedImage == nil) {
        __leftuncheckedImage = [UIImage imageNamed:@"checkmark0"];
    }
    return __leftuncheckedImage;
}


@end
