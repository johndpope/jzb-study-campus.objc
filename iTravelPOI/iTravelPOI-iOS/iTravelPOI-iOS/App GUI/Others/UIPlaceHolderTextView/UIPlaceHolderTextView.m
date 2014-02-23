//
//  UIPlaceHolderTextView.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 08/06/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "UIPlaceHolderTextView.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface UIPlaceHolderTextView ()

@property (strong, nonatomic) UILabel *placeholder;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation UIPlaceHolderTextView


// ---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)setup
{
    
    if ([self placeholder]) {
        [[self placeholder] removeFromSuperview];
        [self setPlaceholder:nil];
    }
    
    CGRect frame = CGRectMake(8, 8, self.bounds.size.width - 16, 0.0);
    UILabel *placeholder = [[UILabel alloc] initWithFrame:frame];
    [placeholder setLineBreakMode:NSLineBreakByWordWrapping];
    [placeholder setNumberOfLines:0];
    [placeholder setBackgroundColor:[UIColor clearColor]];
    [placeholder setAlpha:1.0];
    [placeholder setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [placeholder setTextColor:[UIColor lightGrayColor]];
    [placeholder setText:@""];
    [self addSubview:placeholder];
    [self sendSubviewToBack:placeholder];
    
    self.placeholder=placeholder;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFocus:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lostFocus:) name:UITextViewTextDidEndEditingNotification object:nil];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

// ---------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)textChanged:(NSNotification *)notification
{
    if (self.placeholder.text.length == 0) {
        return;
    }
    
    if (self.text.length == 0) {
        self.placeholder.alpha=1.0;
    } else {
        self.placeholder.alpha=0.0;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)getFocus:(NSNotification *)notification
{
    self.placeholder.alpha=0.0;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)lostFocus:(NSNotification *)notification
{
    if (self.text.length == 0) {
        self.placeholder.alpha=1.0;
    } else {
        self.placeholder.alpha=0.0;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.text.length== 0 && self.placeholder.text.length > 0) {
        self.placeholder.alpha=1.0;
    } else {
        self.placeholder.alpha=0.0;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.placeholder.font=font;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *)placeholderText
{
    return self.placeholder.text;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)setPlaceholderText:(NSString *)placeholderText
{
    
    self.placeholder.text = placeholderText;
    
    CGSize textSize = [placeholderText sizeWithAttributes:@{NSFontAttributeName:self.placeholder.font}];
    CGRect frame = _placeholder.frame;
    frame.size.height = textSize.height;
    
    [_placeholder setFrame:frame];
}

// ---------------------------------------------------------------------------------------------------------------------
- (UIColor *)placeholderColor
{
    return self.placeholder.textColor;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    self.placeholder.textColor=placeholderColor;
}

@end