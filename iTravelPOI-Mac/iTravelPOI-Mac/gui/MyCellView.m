//
//  MyCellView.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 13/09/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MyCellView.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark MyCellView Private interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MyCellView()

@property (nonatomic,weak) IBOutlet NSTextField *badgeLabel;


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark MyCellView implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MyCellView


@synthesize badgeLabel = _badgeLabel;
@synthesize badgeText = _badgeText;




//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (MyCellView *) instanceFromNIB {
    
    NSArray *views;
    
    [[NSBundle mainBundle] loadNibNamed: @"MyCellView" owner: self topLevelObjects:&views];
    NSView *myself = (NSView *)[views objectAtIndex:0];
    return (MyCellView *)myself;
}


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) badgeText {
    return self.badgeLabel.stringValue;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setBadgeText:(NSString *)value {
    self.badgeLabel.stringValue = value;
    BOOL shouldBeHidden = (value==nil);
    [self.badgeLabel setHidden: shouldBeHidden];
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------

@end

