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
#import "MyImageView.h"
#import "NSString+JavaStr.h"
#import "ImageManager.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************
#define ICON_OFFSET 2.5
#define ICON_SIZE 45.0
#define ICONS_PER_ROW 7
#define ICON_ROWS 14


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface IconEditorPanel () <MyImageViewDelegate, NSTextFieldDelegate, NSTextViewDelegate>


@property (nonatomic, assign) IBOutlet NSScrollView *scrollView;
@property (nonatomic, assign) IBOutlet NSImageView *allIconsImage;
@property (nonatomic, assign) IBOutlet NSImageView *selectedImage;
@property (nonatomic, assign) IBOutlet NSTextField *selectedName;


@property (nonatomic, strong) IconEditorPanel *myself;


@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation IconEditorPanel

@synthesize baseHREF = _baseHREF;



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (IconEditorPanel *) startEditIconBaseHREF:(NSString *)baseHREF delegate:(id<IconEditorPanelDelegate>)delegate {

    if(baseHREF == nil || delegate == nil) {
        return nil;
    }

    IconEditorPanel *me = [[IconEditorPanel alloc] initWithWindowNibName:@"IconEditorPanel"];
    if(me) {
        me.myself = me;
        me.delegate = delegate;
        me.baseHREF = baseHREF;
        
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
- (void) windowDidLoad {
    
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.allIconsImage.target = self;
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"IconEditorPanelBg" ofType:@"tiff"];
    NSImage *imgColor = [[NSImage alloc] initWithContentsOfFile:imagePath];
    self.scrollView.backgroundColor = [NSColor colorWithPatternImage:imgColor];
    
    [self setSelectedIconHREF:self.baseHREF];
    [self scrollToSelectedIcon:self.baseHREF];
}


// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) setBaseHREF:(NSString *)value {
    _baseHREF = value;
}

// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseOK:(id)sender {

    if(self.delegate) {
        [self.delegate iconPanelClose:self];
    }
    [self closePanel];
}



// ---------------------------------------------------------------------------------------------------------------------
- (void) closePanel {

    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
    self.baseHREF = nil;
    self.delegate = nil;
    self.myself = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setSelectedIconHREF:(NSString *)baseIconHREF {
    
    IconData *icon = [ImageManager iconDataForHREF:baseIconHREF];
    self.selectedName.stringValue = icon.shortName;
    self.selectedImage.image = icon.image;
    self.baseHREF = baseIconHREF;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) myImageViewClicked:(MyImageView *)sender inPoint:(NSPoint)point {

    int xPos = floor((point.x-ICON_OFFSET)/ICON_SIZE);
    int yPos = floor((sender.frame.size.height-point.y-ICON_OFFSET)/ICON_SIZE);
    
    if(xPos>=0 && xPos<ICONS_PER_ROW && yPos>=0 && yPos<ICON_ROWS) {
        unsigned iconIndex = xPos + yPos * ICONS_PER_ROW;
        NSString *iconHREF = [self urlFromIndex:iconIndex];
        [self setSelectedIconHREF:iconHREF];
    }

}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) urlFromIndex:(unsigned) index {
    
    if(indexForURL==nil) {
        [self loadGMapIconInfoList];
    }
    
    if(index < [indexForURL count])
        return [indexForURL objectAtIndex:index];
    else
        return  nil; //?????SEGURO????
}

static __strong NSArray *indexForURL = nil;
static __strong NSDictionary *urlForIndex = nil;


//---------------------------------------------------------------------------------------------------------------------
- (void) loadGMapIconInfoList {
    
    NSMutableArray *_indexForURL = [NSMutableArray array];
    NSMutableDictionary *_urlForIndex = [NSMutableDictionary dictionary];
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"allGMapIconsInfo" ofType:@"plist"];
    NSDictionary *iconsInfo = [NSDictionary dictionaryWithContentsOfFile:thePath];
    NSArray *iconsData = [iconsInfo valueForKey:@"iconsData"];
    
    unsigned index = 0;
    for(NSDictionary *iconData in iconsData) {
        NSString *iconURL = [iconData valueForKey:@"url"];
        NSNumber *cIndex = [NSNumber numberWithUnsignedInt:index++];
        
        [_indexForURL addObject:iconURL];
        [_urlForIndex setValue:cIndex forKey:iconURL];
    }
    
    indexForURL = _indexForURL;
    urlForIndex = _urlForIndex;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) scrollToSelectedIcon:(NSString *) url {
    
    // Scroll the vertical scroller to top
    if ([_scrollView hasVerticalScroller]) {
        // _scrollView.verticalScroller.floatValue = 0;
    }
    
    
    if(url) {
        if(urlForIndex==nil) {
            [self loadGMapIconInfoList];
        }
        
        NSNumber *index = [urlForIndex objectForKey:url];
        if(index) {
            unsigned yPos = [index unsignedIntValue] / ICONS_PER_ROW;
            float pos = ((NSView*)_scrollView.documentView).frame.size.height-_scrollView.contentSize.height-ICON_OFFSET-ICON_SIZE*yPos;
            [_scrollView.contentView scrollToPoint:NSMakePoint(0, pos)];
        }
    }
}





// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------

@end
