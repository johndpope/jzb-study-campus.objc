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
@property (strong, nonatomic) UILabel     *viewDistanceLabel;

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
        // Control para poder marcar/seleccionar una celda
        UIImage *img = [PointListViewCell leftCheckedImage:self.tintColor];
        self.leftCheckedView = [[UIImageView alloc] initWithFrame:CGRectMake(-img.size.width, 15, img.size.width, img.size.height)];
        [self.contentView addSubview:self.leftCheckedView];

        // Pone varias lineas para el texto de detalle
        self.detailTextLabel.numberOfLines = 2;
        
        // Crea la etiqueta que contendra la distancia del punto
        UIFont *lblFont = [UIFont italicSystemFontOfSize:10.0f];
        NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:@"99,999 Km" attributes:@{NSFontAttributeName: lblFont}];
        CGRect lblFrm = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];

        self.viewDistanceLabel = [[UILabel alloc] initWithFrame:lblFrm];
        self.viewDistanceLabel.font = lblFont;
        self.viewDistanceLabel.textColor = [UIColor colorWithIntRed:150 intGreen:150 intBlue:150 alpha:1.0];
        self.viewDistanceLabel.textAlignment = NSTextAlignmentCenter;

        [self.imageView.superview addSubview:self.viewDistanceLabel];
        

	}
	return self;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) viewDistance {
    return  self.viewDistanceLabel.text;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setViewDistance:(NSString *)value {
    self.viewDistanceLabel.text = value;
}

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
        self.leftCheckedView.image = self.checked ? [PointListViewCell leftCheckedImage:self.tintColor] : [PointListViewCell leftUncheckedImage:self.tintColor];
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
    
    
    CGPoint lblOrig = self.imageView.frame.origin;
    lblOrig.x = self.imageView.frame.origin.x - (self.viewDistanceLabel.frame.size.width-self.imageView.frame.size.width)/2;
    lblOrig.y = 4 + self.imageView.frame.origin.y + self.imageView.frame.size.height;
    self.viewDistanceLabel.frame = CGRectMake(lblOrig.x, lblOrig.y, self.viewDistanceLabel.frame.size.width, self.viewDistanceLabel.frame.size.height);

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

    static __strong UIImage *__leftcheckedImage = nil;
    static __strong UIColor *__tintColor = nil;
    
    if(__leftcheckedImage == nil || (__tintColor && ![__tintColor isEqual:tintColor])) {
        __tintColor = tintColor;
        __leftcheckedImage = [UIImage imageNamed:@"checkedMark" burnTint:tintColor];
    }
    return __leftcheckedImage;
}


//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) leftUncheckedImage:(UIColor *)tintColor {
    
    static __strong UIImage *__leftuncheckedImage = nil;
    static __strong UIColor *__tintColor = nil;

    if(__leftuncheckedImage == nil || (__tintColor && ![__tintColor isEqual:tintColor])) {
        __leftuncheckedImage = [UIImage imageNamed:@"uncheckedMark" burnTint:tintColor];
    }
    return __leftuncheckedImage;
}


@end
