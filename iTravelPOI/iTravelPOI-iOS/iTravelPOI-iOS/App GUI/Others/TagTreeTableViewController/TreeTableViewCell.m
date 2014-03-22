//
//  TreeTableViewCell.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 27/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "TreeTableViewCell.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TreeTableViewCell ()

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TreeTableViewCell


//---------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews {

    self.accessoryView.frame = (CGRect){0,0,24,24};
    [super layoutSubviews];
    self.accessoryView.frame = (CGRect){self.frame.size.width-60,0,60,self.frame.size.height};

    /*
    tmpFrame = self.textLabel.frame;
    tmpFrame.origin.x = 60;
    tmpFrame.origin.x += self.indentationLevel * self.indentationWidth;
    self.textLabel.frame = tmpFrame;
    */
    
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
