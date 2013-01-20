//
//  AppDelegate.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 31/12/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "DDLog.h"
#import "DDTTYLogger.h"

#import "AppDelegate.h"
#import "BaseCoreData.h"
#import "MapEditorPanel.h"
#import "MyCellView.h"

#import "MockUp.h"
#import "AppTesting.h"



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface AppDelegate() <MapEditorPanelDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (strong) NSWindowController *mainWnd;
@property (strong) MapEditorPanel *mapEditorPanel;
@property (strong) NSArray *items;


@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation AppDelegate



@synthesize mainWnd = _mainWnd;
@synthesize mapEditorPanel = _mapEditorPanel;
@synthesize items = _items;




//------------------------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [self initDataModel];
    //[self showMainWindow];
}

//------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib {
}


//------------------------------------------------------------------------------------------------------------------
- (void) showMainWindow {
    
    /*
    self.mainWnd = [[DataListWindowController alloc] initWithWindowNibName:@"DataListWindowController"];
    
    [self.mainWnd.window makeKeyAndOrderFront:self];
    [self.mainWnd showWindow:self];
     */
}



// =====================================================================================================================
#pragma mark -
#pragma mark <NSTableViewDataSource> methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView {
    NSUInteger count = self.items.count;
    count=5;
    return count;
}


//---------------------------------------------------------------------------------------------------------------------
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
        
    MyCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    /***
    NSNib *cellNib = [[NSNib alloc] initWithNibNamed:@"MyCell" bundle:nil];
    [tableView registerNib:cellNib forIdentifier:@"SomeIdentifier"];
    ***/
    
    //result.imageView.image = item.itemIcon;
    
    NSString *name = @"pepe";
    result.labelText = name;
    result.badgeText = @"000";
    
    return result;
}



// =====================================================================================================================
#pragma mark -
#pragma mark <NSTableViewDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------






//------------------------------------------------------------------------------------------------------------------
- (void) initDataModel {
    
    //---------------------------------------
    //---------------------------------------
    //[MockUp resetModel:@"iTravelPOI"];
    //---------------------------------------
    //---------------------------------------
    
    
    
    if(![BaseCoreData initCDStack:@"iTravelPOI"]) {
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    /*
    if(![ModelDAO createInitialData:BaseCoreData.moContext]) {
        [[NSApplication sharedApplication] terminate:nil];
    }
     */
    
    
    //---------------------------------------
    //---------------------------------------
    /*
    [MockUp populateModel];
    NSManagedObjectContext *moContext = BaseCoreData.moContext;
    [AppTesting excuteTestWithMOContext:moContext];
     */
    //---------------------------------------
    //---------------------------------------
    
    
}


//------------------------------------------------------------------------------------------------------------------
- (void) mapPanelSaveChanges:(MapEditorPanel *)sender {
    
    NSManagedObjectContext *moc =sender.map.managedObjectContext;
    [BaseCoreData saveMOContext:moc];
    [BaseCoreData saveContext];
}

//------------------------------------------------------------------------------------------------------------------
- (void) mapPanelCancelChanges:(MapEditorPanel *)sender {
    // Nothing to do
}

//------------------------------------------------------------------------------------------------------------------
- (IBAction) addItemAction:(id)sender {

    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    moc.parentContext =[BaseCoreData moContext];
    
    MMap *newMap = [MMap emptyMapInContext:moc];
    
    self.mapEditorPanel = [MapEditorPanel beginEditMapInfo:newMap delegate:self];
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
