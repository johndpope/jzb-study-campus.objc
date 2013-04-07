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

// ---------------------------------------------------------------------------------------------------------------------
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
- (NSString *) badgeText {
    return self.badgeTextField.stringValue;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setLabelText:(NSString *)labelText badgeText:(NSString *)badgeText image:(NSImage *)image {

    if(badgeText != nil) {
        self.badgeTextField.stringValue = badgeText;
        [self.badgeTextField setHidden:false];
        
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:labelText attributes:self.boldFontAttributes];
        self.textField.attributedStringValue = attrStr;
    } else {
        self.badgeTextField.stringValue = @"";
        [self.badgeTextField setHidden:true];

        self.textField.stringValue = labelText;
    }
    
    self.imageView.image = image;
}

// =====================================================================================================================
#pragma mark -
#pragma mark Public methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *) boldFontAttributes {
    
    static __strong NSDictionary *__boldFontAttrs = nil;
    
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        NSFont *font = [NSFont boldSystemFontOfSize:13.0];
        __boldFontAttrs = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    });
    return __boldFontAttrs;

}

@end

