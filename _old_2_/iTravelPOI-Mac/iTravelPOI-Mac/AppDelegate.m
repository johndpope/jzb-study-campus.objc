//
//  AppDelegate.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "AppDelegate.h"
#import "MockUp.h"
#import "ModelDAO.h"
#import "DataListWindowController.h"

@interface AppDelegate()

@property (strong) NSWindowController *mainWnd;

@end



@implementation AppDelegate



@synthesize mainWnd = _mainWnd;




//------------------------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self initDataModel];
    [self showMainWindow];
}

//------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib {
}


//------------------------------------------------------------------------------------------------------------------
- (void) showMainWindow {
    
    self.mainWnd = [[DataListWindowController alloc] initWithWindowNibName:@"DataListWindowController"];
    
    [self.mainWnd.window makeKeyAndOrderFront:self];
    [self.mainWnd showWindow:self];
}

//------------------------------------------------------------------------------------------------------------------
- (void) initDataModel {
    
    //---------------------------------------
    [MockUp resetModel:@"iTravelPOI"];
    
    
    
    if(![BaseCoreData initCDStack:@"iTravelPOI"]) {
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    if(![ModelDAO createInitialData:BaseCoreData.moContext]) {
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    
    //---------------------------------------
    [MockUp populateModel];
    
    
}


//------------------------------------------------------------------------------------------------------------------
// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [BaseCoreData.moContext undoManager];
}

//------------------------------------------------------------------------------------------------------------------
// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![BaseCoreData.moContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![BaseCoreData.moContext save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

//------------------------------------------------------------------------------------------------------------------
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!BaseCoreData.moContext) {
        return NSTerminateNow;
    }
    
    if (![BaseCoreData.moContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![BaseCoreData.moContext hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![BaseCoreData.moContext save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result2 = [sender presentError:error];
        if (result2) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

@end
