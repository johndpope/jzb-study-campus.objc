//
//  MyTableViewCell.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 27/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "MyTableViewCell.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MyTableViewCell ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MyTableViewCell


//---------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect tmpFrame = self.imageView.frame;
    tmpFrame.origin.x += self.indentationLevel * self.indentationWidth;
    self.imageView.frame = tmpFrame;
    
    tmpFrame = self.textLabel.frame;
    tmpFrame.origin.x = 60;
    self.textLabel.frame = tmpFrame;
    /*
    tmpFrame = self.textLabel.frame;
    tmpFrame.origin.x += self.indentationLevel * self.indentationWidth;
    self.textLabel.frame = tmpFrame;
    
    tmpFrame = self.detailTextLabel.frame;
    tmpFrame.origin.x += self.indentationLevel * self.indentationWidth;
    self.detailTextLabel.frame = tmpFrame;
     */
}

@end
