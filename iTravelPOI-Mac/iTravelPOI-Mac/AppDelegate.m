//
// AppDelegate.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 31/12/12.
// Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "DDLog.h"
#import "DDTTYLogger.h"

#import "AppDelegate.h"
#import "BaseCoreData.h"

#import "MockUp.h"

#import "MapMainWindow.h"




// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface AppDelegate ()

@property (strong) NSWindowController *mainWndCtrlr;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation AppDelegate



// ------------------------------------------------------------------------------------------------------------------
- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [self initDataModel];
    [self showMainWindow];
        
}


// ------------------------------------------------------------------------------------------------------------------
- (void) showMainWindow {
    self.mainWndCtrlr = [MapMainWindow mapMainWindow];
}






// =====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) initDataModel {

    // ---------------------------------------
    // ---------------------------------------
    [MockUp resetModel:@"iTravelPOI"];
    // ---------------------------------------
    // ---------------------------------------


    if(![BaseCoreData initCDStack:@"iTravelPOI"]) {
        [[NSApplication sharedApplication] terminate:nil];
    }

    /*
     if(![ModelDAO createInitialData:BaseCoreData.moContext]) {
     [[NSApplication sharedApplication] terminate:nil];
     }
     */


    // ---------------------------------------
    // ---------------------------------------

    [MockUp populateModel];
    /*
     [AppTesting excuteTestWithMOContext:BaseCoreData.moContext];
     */
    // ---------------------------------------
    // ---------------------------------------

}

// ------------------------------------------------------------------------------------------------------------------
- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.

    if(!BaseCoreData.moContext) {
        return NSTerminateNow;
    }

    if(![BaseCoreData.moContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if(![BaseCoreData.moContext hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if(![BaseCoreData.moContext save:&error]) {

        // Customize this code block to include application-specific recovery steps.
        BOOL result2 = [sender presentError:error];
        if(result2) {
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
        if(answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
