//
// MyCellView.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/09/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MyCellView.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark MyCellView Private interface definition
// *********************************************************************************************************************
@interface MyCellView ()

@property (nonatomic, assign) IBOutlet NSTextField *badgeTextField;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark MyCellView implementation
// *********************************************************************************************************************
@implementation MyCellView


// =====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
// ---------------------------------------------------------------------------------------------------------------------
+ (MyCellView *) instanceFromNIB {

    NSArray *views;

    [[NSBundle mainBundle] loadNibNamed:@"MyCellView" owner:self topLevelObjects:&views];
    for(id item in views) {
        if([item isKindOfClass:[MyCellView class]]) {
            return (MyCellView *)item;
        }
    }
    return nil;
}

- (id) initWithFrame:(NSRect)frameRect {
    return [super initWithFrame:frameRect];
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) labelText {
    return self.textField.stringValue;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setLabelText:(NSString *)value {
    self.textField.stringValue = value;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) badgeText {
    return self.badgeTextField.stringValue;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setBadgeText:(NSString *)value {

    if(value != nil) {
        self.badgeTextField.stringValue = value;
        [self.badgeTextField setHidden:false];
    } else {
        self.badgeTextField.stringValue = @"";
        [self.badgeTextField setHidden:true];
    }
}

// =====================================================================================================================
#pragma mark -
#pragma mark Public methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------

@end

