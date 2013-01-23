//
// CategoryEditorPanel.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __CategoryEditorPanel__IMPL__
#import "CategoryEditorPanel.h"
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
@interface CategoryEditorPanel () <NSTextFieldDelegate, NSTextViewDelegate>


@property (nonatomic, assign) IBOutlet NSImageView *iconImageField;
@property (nonatomic, assign) IBOutlet NSTextField *categoryNameField;
@property (nonatomic, assign) IBOutlet NSTextField *categoryPathField;
@property (nonatomic, assign) IBOutlet NSTextView *categoryDescrField;
@property (nonatomic, assign) IBOutlet NSTextField *categoryExtraInfo;

@property (nonatomic, strong) NSManagedObjectContext *categoryContext;

@property (nonatomic, strong) CategoryEditorPanel *myself;

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation CategoryEditorPanel



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (CategoryEditorPanel *) startEditCategory:(MCategory *)category inMap:(MMap *)map delegate:(id<CategoryEditorPanelDelegate>)delegate {

    if(category == nil || delegate == nil) {
        return nil;
    }

    CategoryEditorPanel *me = [[CategoryEditorPanel alloc] init];

    BOOL allOK = [NSBundle loadNibNamed:@"CategoryEditorPanel" owner:me];

    if(allOK) {

        me.myself = me;
        me.delegate = delegate;
        me.category = category;
        me.map = map;
        // No se por que se debe crear una referencia fuerte al contexto si el categorya esta dentro
        me.categoryContext = category.managedObjectContext;
        [me setFieldValuesFromCategory];


        [NSApp beginSheet:me.window
           modalForWindow:[[NSApp delegate] window]
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
        [self setCategoryFromFieldValues];
        [self.delegate categoryPanelSaveChanges:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseCancel:(id)sender {

    if(self.delegate) {
        [self.delegate categoryPanelCancelChanges:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) closePanel {

    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
    self.category = nil;
    self.categoryContext = nil;
    self.delegate = nil;
    self.myself = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setFieldValuesFromCategory {

    if(self.category) {

        GMapIcon *icon = [GMapIcon iconForHREF:self.category.iconHREF];
        self.iconImageField.image = icon.image;

        NSString *catPath = nil;
        [MCategory parseIconHREF:self.category.iconHREF baseURL:nil catPath:&catPath];
        [self.categoryPathField setStringValue:catPath];

        [self.categoryNameField setStringValue:self.category.name];
        [self.categoryDescrField setString:@""];
        [self.categoryExtraInfo setStringValue:[NSString stringWithFormat:@"Published: %@\tUpdated: %@\nETAG: %@",
                                             [GMTItem stringFromDate:self.category.published_Date],
                                             [GMTItem stringFromDate:self.category.updated_Date],
                                             self.category.etag]];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setCategoryFromFieldValues {

    if(self.category) {
        
        NSString *baseURL = nil;
        [MCategory parseIconHREF:self.category.iconHREF baseURL:&baseURL catPath:nil];
        NSString *newIconHREF = [NSString stringWithFormat:@"%@%@", baseURL, self.categoryPathField.stringValue];
        
        // Los cambios en esta entidad son, REALMENTE, CAMBIOS EN LOS PUNTOS ASOCIADOS
        [self.category movePointsToCategoryWithIconHREF:newIconHREF inMap:self.map];
        
    }
}

// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------

@end
