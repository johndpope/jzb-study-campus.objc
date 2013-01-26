//
// IconEditorPanel.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __IconEditorPanel__IMPL__
#import "IconEditorPanel.h"
#import "GMTItem.h"

#import "PointEditorPanel.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface IconEditorPanel () <NSTextFieldDelegate, NSTextViewDelegate>


@property (nonatomic, assign) IBOutlet NSScrollView *scrollView;
@property (nonatomic, assign) IBOutlet NSImageView *allIconsImage;


@property (nonatomic, strong) IconEditorPanel *myself;

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation IconEditorPanel



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (IconEditorPanel *) startEditIcon:(NSString *)iconHREF delegate:(id<IconEditorPanelDelegate>)delegate {

    if(iconHREF == nil || delegate == nil) {
        return nil;
    }

    IconEditorPanel *me = [[IconEditorPanel alloc] init];

    BOOL allOK = [NSBundle loadNibNamed:@"IconEditorPanel" owner:me];

    if(allOK) {
        me.myself = me;
        me.delegate = delegate;
        me.iconHREF = iconHREF;

        [me setFieldValuesFromIcon];

        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"IconEditorPanelBg" ofType:@"tiff"];
        NSImage *imgColor = [[NSImage alloc] initWithContentsOfFile:imagePath];
        me.scrollView.backgroundColor = [NSColor colorWithPatternImage:imgColor];

        [NSApp beginSheet:me.window
           modalForWindow:[delegate window]
            modalDelegate:nil
           didEndSelector:nil
              contextInfo:nil];

        return me;
    } else {
        return nil;
    }

}

// =====================================================================================================================
#pragma mark -
#pragma mark Initialization & finalization
// ---------------------------------------------------------------------------------------------------------------------
- (id) initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if(self) {
        // Initialization code here.
    }

    return self;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) windowDidLoad {
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseSave:(id)sender {

    if(self.delegate) {
        [self setIconFromFieldValues];
        [self.delegate iconPanelSaveChanges:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseCancel:(id)sender {

    if(self.delegate) {
        [self.delegate iconPanelCancelChanges:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) closePanel {

    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
    self.iconHREF = nil;
    self.delegate = nil;
    self.myself = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setFieldValuesFromIcon {

    if(self.iconHREF) {
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setIconFromFieldValues {
    
}



// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------

@end
