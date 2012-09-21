//
//  GroupEditWindowController.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 31/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "GroupEditWindowController.h"
#import "Model.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Private enumerations & definitions
//---------------------------------------------------------------------------------------------------------------------




//*********************************************************************************************************************
#pragma mark -
#pragma mark GroupEditWindowController Private interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GroupEditWindowController ()

@property (weak) IBOutlet NSTextField *txtName;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark GroupEditWindowController implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation GroupEditWindowController


@synthesize txtName = _txtName;


@synthesize group = _group;
@synthesize delegate = _delegate;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setGroup2:(MGroup *)value {
    _group = value;
    
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark NSWindowController methods
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    NSLog(@"initWithWindow");
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSLog(@"windowDidLoad");

}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark NSWindowDelegate methods
//---------------------------------------------------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"windowWillClose");
}

//---------------------------------------------------------------------------------------------------------------------
- (void)windowDidExpose:(NSNotification *)notification {
    NSLog(@"windowDidExpose");
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)showWindow:(id)sender {
    NSLog(@"showWindow");
}

//---------------------------------------------------------------------------------------------------------------------
- (void)windowDidBecomeKey:(NSNotification *)notification {
    NSLog(@"windowDidBecomeKey");
    self.txtName.stringValue = self.group.name;
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark OUTLET ACTION methods
//------------------------------------------------------------------------------------------------------------------
- (IBAction)saveGroupAction:(NSToolbarItem *)sender {
    [self.delegate endSaving:self.group sender:self];
}

//------------------------------------------------------------------------------------------------------------------
- (IBAction)cancelGroupAction:(NSToolbarItem *)sender {
    [self.delegate endCanceling:self.group sender:self];
}


//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private methods
//------------------------------------------------------------------------------------------------------------------




@end
