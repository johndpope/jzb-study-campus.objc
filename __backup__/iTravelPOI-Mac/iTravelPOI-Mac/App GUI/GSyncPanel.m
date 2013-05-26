//
// GSyncPanel.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GSyncPanel__IMPL__
#import "GSyncPanel.h"
#import "SyncDataService.h"
#import "IconEditorPanel.h"
#import "ImageManager.h"
#import "NSString+JavaStr.h"


// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
// *********************************************************************************************************************
#define TABLE_STATUS_PENDING    [NSNumber numberWithInt:0]
#define TABLE_STATUS_SYNCING    [NSNumber numberWithInt:1]
#define TABLE_STATUS_DONE_OK    [NSNumber numberWithInt:2]
#define TABLE_STATUS_DONE_ERROR [NSNumber numberWithInt:3]

NSString *STATUS_ICON_NAME[] = {@"SyncIcon_Pending", @"SyncIcon_Syncing", @"SyncIcon_doneOK", @"SyncIcon_dondeError"};



// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface GSyncPanel () <PSyncDataDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, assign) IBOutlet NSTableView *tableViewItems;
@property (nonatomic, assign) IBOutlet NSTextField *extraInfo;
@property (nonatomic, assign) IBOutlet NSButton *btnOK;
@property (nonatomic, assign) IBOutlet NSButton *btnCancel;


@property (nonatomic, strong) GSyncPanel *myself;
@property (nonatomic, strong) SyncDataService *syncDataService;

@property (nonatomic, strong) NSMutableArray *itemNames;
@property (nonatomic, strong) NSMutableArray *itemStatus;

@end


// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation GSyncPanel



// =====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
// ---------------------------------------------------------------------------------------------------------------------
+ (GSyncPanel *) startSyncWithMOContext:(NSManagedObjectContext *)moContext delegate:(id<GSyncPanelDelegate>)delegate {

    if(moContext == nil || delegate == nil) {
        return nil;
    }

    GSyncPanel *panel = [[GSyncPanel alloc] initWithWindowNibName:@"GSyncPanel"];

    if(panel) {
        panel.myself = panel;
        panel.delegate = delegate;
        panel.moContext = moContext;

        
        [NSApp beginSheet:panel.window
           modalForWindow:[delegate window]
            modalDelegate:nil
           didEndSelector:nil
              contextInfo:nil];


        return panel;
        
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
    [self setFieldValuesFromEntity];
    
    self.syncDataService = [SyncDataService syncDataServiceWithMOContext:self.moContext delegate:self];
    [self.syncDataService startMapsSync];
}




// =====================================================================================================================
#pragma mark -
#pragma mark Getter/Setter methods
// ---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark General PUBLIC methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseOK:(id)sender {

    if(self.delegate && [self.delegate respondsToSelector:@selector(editorPanelSaveChanges:)]) {
        [self setEntityFromFieldValues];
        [self.delegate gsyncPanelClose:self];
    }
    [self closePanel];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) btnCloseCancel:(id)sender {

    self.extraInfo.stringValue = @"Cancelling GMap synchronization";
    [self.syncDataService cancelSync];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) closePanel {

    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
    self.syncDataService = nil;
    self.moContext = nil;
    self.delegate = nil;
    self.myself = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setFieldValuesFromEntity {

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) setEntityFromFieldValues {

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) startMapsSync {

    self.extraInfo.stringValue = @"Connecting to GMap service";
    [self.btnOK setEnabled:false];
    [self.btnCancel setEnabled:true];
}



// =====================================================================================================================
#pragma mark -
#pragma mark <PSyncDataDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) syncFinished:(BOOL)allOK {
    
    if(allOK) {
        self.extraInfo.stringValue = @"Sync finished successfully";
    } else {
        self.extraInfo.stringValue = @"Sync finished with errors";
    }
    [self.btnOK setEnabled:true];
    [self.btnCancel setEnabled:false];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willGetRemoteMapList {
    self.extraInfo.stringValue = @"Fetching remote maps list...";
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) didGetRemoteMapList {
    self.extraInfo.stringValue = @"Successfully fetched remote maps list";
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willSyncMapTupleList:(NSArray *)compTuples {
    
    self.itemNames = [NSMutableArray arrayWithCapacity:compTuples.count];
    self.itemStatus = [NSMutableArray arrayWithCapacity:compTuples.count];
    
    for(GMTCompTuple *tuple in compTuples) {
        NSString *text = [self textFromTuple:tuple];
        [self.itemNames addObject:text];
        [self.itemStatus addObject:TABLE_STATUS_PENDING];
    }
    
    self.extraInfo.stringValue = @"Synchronizing maps";
    [self.tableViewItems reloadData];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int) index {
    
    self.itemStatus[index] = TABLE_STATUS_SYNCING;
    [self.tableViewItems selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:false];
    [self.tableViewItems scrollRowToVisible:index];
    [self.tableViewItems reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) didSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int) index syncOK:(BOOL)syncOK {
    
    self.itemStatus[index] = syncOK ? TABLE_STATUS_DONE_OK : TABLE_STATUS_DONE_ERROR;
    [self.tableViewItems selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:false];
    [self.tableViewItems scrollRowToVisible:index];
    [self.tableViewItems reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}


// =====================================================================================================================
#pragma mark -
#pragma mark <NSTableViewDataSource> methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView {
    return self.itemNames.count;
}


// =====================================================================================================================
#pragma mark -
#pragma mark <NSTableViewDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    
    NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    NSNumber *status = self.itemStatus[row];
    cell.imageView.image = [ImageManager imageForName:STATUS_ICON_NAME[status.intValue]];
    cell.textField.stringValue = self.itemNames[row];
    
    return cell;
}






// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) textFromTuple:(GMTCompTuple *)tuple {
    
    const NSString *TupleStatusNames[] = {@"+", @"+", @"-", @"-", @"*", @"*"};
    
    NSString *localName = tuple.localItem ? tuple.localItem.name : @"<empty>";
    NSString *remoteName = tuple.remoteItem ? tuple.remoteItem.name : @"<empty>";
    NSString *text = [NSString stringWithFormat:@"%@ / %@ / %@", localName, remoteName, TupleStatusNames[tuple.status]];
    return text;
}

@end
