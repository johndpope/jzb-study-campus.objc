//
//  MyCollectionViewCell.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/03/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import "MyCollectionViewCell.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define IS_APPLE_MAPS_APP(appName) [appName isEqualToString:@"Apple Maps"]
#define APPLE_MAPS_TAG 5001
#define DISMISS_NO_APP -1




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************

//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MyCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
