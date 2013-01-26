//
// PointEditorPanel.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointEditorPanel__IMPL__
#import "PointEditorPanel.h"
#import "GMapIcon.h"
#import "GMTItem.h"
#import "MCategory.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface PointEditorPanel () <NSTextFieldDelegate, NSTextViewDelegate>


@property (nonatomic, assign) IBOutlet NSImageView *iconImageField;
@property (nonatomic, assign) IBOutlet NSTextField *pointNameField;
@property (nonatomic, assign) IBOutlet NSTextField *pointCategoryField;
@property (nonatomic, assign) IBOutlet NSTextView *pointDescrField;
@property (nonatomic, assign) IBOutlet NSTextField *pointExtraInfo;

@property (nonatomic, strong) NSManagedObjectContext *pointContext;

@property (nonatomic, strong) PointEditorPanel *myself;

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation PointEditorPanel



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (PointEditorPanel *) startEditPoint:(MPoint *)Point delegate:(id<PointEditorPanelDelegate>)delegate {

    if(Point == nil || delegate == nil) {
        return nil;
    }

    PointEditorPanel *me = [[PointEditorPanel alloc] init];

    BOOL allOK = [NSBundle loadNibNamed:@"PointEditorPanel" owner:me];

    if(allOK) {

        me.myself = me;
        me.delegate = delegate;
        me.Point = Point;
        // No se por que se debe crear una referencia fuerte al contexto si el Pointa esta dentro
        me.PointContext = Point.managedObjectContext;
        [me setFieldValuesFromPoint];


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
        [self setPointFromFieldValues];
        NSLog(@"--- panel point save ---");
        [self.delegate pointPanelSaveChanges:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseCancel:(id)sender {

    if(self.delegate) {
        [self.delegate pointPanelCancelChanges:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) closePanel {

    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
    self.point = nil;
    self.pointContext = nil;
    self.delegate = nil;
    self.myself = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setFieldValuesFromPoint {

    if(self.point) {

        GMapIcon *icon = [GMapIcon iconForHREF:self.point.iconHREF];
        self.iconImageField.image = icon.image;

        NSString *catPath = nil;
        [MCategory parseIconHREF:self.point.iconHREF baseURL:nil catPath:&catPath];
        [self.pointCategoryField setStringValue:catPath];

        [self.pointNameField setStringValue:self.point.name];
        [self.pointDescrField setString:self.point.descr];
        [self.pointExtraInfo setStringValue:[NSString stringWithFormat:@"Published: %@\tUpdated: %@\nETAG: %@",
                                             [GMTItem stringFromDate:self.point.published_Date],
                                             [GMTItem stringFromDate:self.point.updated_Date],
                                             self.point.etag]];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setPointFromFieldValues {

    
    if(self.point) {
        // *** CONTROL DE SEGURIDAD (@name) PARA NO TOCAR Points BUENOS ***
        NSString *name = self.pointNameField.stringValue;
        if([name hasPrefix:@"@"]) {
            self.point.name = name;
        } else {
            self.point.name = [NSString stringWithFormat:@"@%@", name];
        }
        self.point.descr = [self.pointDescrField string];
        self.point.updated_Date = [NSDate date];

        NSString *baseURL = nil;
        [MCategory parseIconHREF:self.point.iconHREF baseURL:&baseURL catPath:nil];
        NSString *iconHREF = [NSString stringWithFormat:@"%@%@", baseURL, self.pointCategoryField.stringValue];
        [self.point moveToIconHREF:iconHREF];
    }
}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------

@end
