//
// GSyncPanel.m
// iTravelPOI-Mac
//
// Created by Jose Zarzuela on 13/01/13.
// Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __GSyncPanel__IMPL__
#import "GSyncPanel.h"
#import "IconEditorPanel.h"
#import "GMapSyncService.h"
#import "GMTItem.h"
#import "GMTMap.h"
#import "GMTPoint.h"
#import "MMap.h"
#import "MPoint.h"
#import "GMTCompTuple.h"
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
@interface GSyncPanel () <GMPSyncDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, assign) IBOutlet NSTableView *tableViewItems;
@property (nonatomic, assign) IBOutlet NSTextField *extraInfo;
@property (nonatomic, assign) IBOutlet NSButton *btnOK;
@property (nonatomic, assign) IBOutlet NSButton *btnCancel;


@property (nonatomic, strong) GSyncPanel *myself;
@property (nonatomic, strong) GMapSyncService *syncSrvc;

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
    
    [self startMapsSync];
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
    [self.syncSrvc cancelSync];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) closePanel {

    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
    self.syncSrvc = nil;
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


    __block BOOL allOK = true;
    
    self.extraInfo.stringValue = @"Connecting to GMap service";
    [self.btnOK setEnabled:false];
    [self.btnCancel setEnabled:true];
    
    [self.moContext performBlock:^{
        
        DDLogVerbose(@"****** START: excuteTest ******");
        
        
        NSError *error;
        
        self.syncSrvc = [GMapSyncService serviceWithEmail:@"jzarzuela@gmail.com" password:@"#webweb1971" delegate:self error:&error];
        if(!self.syncSrvc) {
            allOK = false;
            DDLogError(@"Error en sincronizacion(login) %@", error);
        }
        
        if(![self.syncSrvc syncMaps:&error]) {
            allOK = false;
            DDLogError(@"Error en sincronizacion %@", error);
        }
        
        DDLogVerbose(@"****** END: excuteTest ******");
        dispatch_async(dispatch_get_main_queue(), ^{
            if(allOK) {
                [self cleanDeletedMaps];
                self.extraInfo.stringValue = @"Sync finished successfully";
            } else {
                self.extraInfo.stringValue = @"Sync finished with errors";
            }
            [self.btnOK setEnabled:true];
            [self.btnCancel setEnabled:false];
        });
    }];
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
#pragma mark <GMPSyncDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) getAllLocalMapList:(NSError **)err {

    if(err != nil) *err = nil;
    NSArray *allMaps = [MMap allMapsInContext:self.moContext includeMarkedAsDeleted:true];
    return allMaps;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTMap *) gmMapFromLocalMap:(MMap *)localMap error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    GMTMap *gmMap = [GMTMap emptyMap];
    
    gmMap.name = localMap.name;
    gmMap.gmID = localMap.gmID;
    gmMap.etag = localMap.etag;
    gmMap.published_Date = localMap.published_date;
    gmMap.updated_Date = localMap.updated_date;
    gmMap.summary = localMap.summary;
    
    return gmMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalMapFrom:(GMTMap *)gmMap error:(NSError **)err {

    if(err != nil) *err = nil;
    
    MMap *localMap = [MMap emptyMapWithName:gmMap.name inContext:self.moContext];
    [self updateLocalMap:localMap withRemoteMap:gmMap allPointsOK:true error:err];
    
    return localMap;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalMap:(MMap *)localMap withRemoteMap:(GMTMap *)gmMap allPointsOK:(BOOL)allPointsOK error:(NSError **)err {
    
    if(err != nil) *err = nil;
    if(!gmMap) {
        return false;
    }
    
    localMap.name = gmMap.name;
    localMap.gmID = gmMap.gmID;
    localMap.etag = gmMap.etag;
    localMap.published_date = gmMap.published_Date;
    localMap.updated_date = gmMap.updated_Date;
    
    localMap.summary = gmMap.summary;

    [localMap updateDeleteMark:false];
    localMap.modifiedSinceLastSyncValue = false;

    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalMap:(MMap *)localMap error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    [localMap updateDeleteMark:true];
    localMap.modifiedSinceLastSyncValue = false;
    
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) localPointListForMap:(MMap *)localMap error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    NSArray *pointList = localMap.points.allObjects;
    return pointList;
}

// ---------------------------------------------------------------------------------------------------------------------
- (GMTPoint *) gmPointFromLocalPoint:(MPoint *)localPoint error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    GMTPoint *gmPoint = [GMTPoint emptyPoint];
    
    gmPoint.name = localPoint.name;
    gmPoint.gmID = localPoint.gmID;
    gmPoint.etag = localPoint.etag;
    gmPoint.published_Date = localPoint.published_date;
    gmPoint.updated_Date = localPoint.updated_date;
    
    gmPoint.descr = localPoint.descr;
    gmPoint.iconHREF = localPoint.iconHREF;
    gmPoint.latitude = localPoint.latitudeValue;
    gmPoint.longitude = localPoint.longitudeValue;
    
    return gmPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (id) createLocalPointFrom:(GMTPoint *)gmPoint inLocalMap:(MMap *)map error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    MCategory *cat = [MCategory categoryForIconHREF:gmPoint.iconHREF inContext:map.managedObjectContext];
    MPoint *localPoint = [MPoint emptyPointWithName:gmPoint.name inMap:map withCategory:cat];
    [self updateLocalPoint:localPoint withRemotePoint:gmPoint error:err];
    
    return localPoint;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) updateLocalPoint:(MPoint *)localPoint withRemotePoint:(GMTPoint *)gmPoint error:(NSError **)err {
    
    if(err != nil) *err = nil;
    if(!gmPoint) {
        return false;
    }
    
    localPoint.name = gmPoint.name;
    localPoint.gmID = gmPoint.gmID;
    localPoint.etag = gmPoint.etag;
    localPoint.published_date = gmPoint.published_Date;
    localPoint.updated_date = gmPoint.updated_Date;
    
    localPoint.descr = gmPoint.descr;
    [localPoint moveToCategory:[MCategory categoryForIconHREF:gmPoint.iconHREF inContext:localPoint.managedObjectContext]];
    [localPoint setLatitude:gmPoint.latitude longitude:gmPoint.longitude];

    [localPoint updateDeleteMark:false];
    localPoint.modifiedSinceLastSyncValue = false;

    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) deleteLocalPoint:(MPoint *)localPoint inLocalMap:(id)map error:(NSError **)err {
    
    if(err != nil) *err = nil;
    
    [localPoint updateDeleteMark:true];
    localPoint.map.modifiedSinceLastSyncValue = false;
    
    return true;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willGetRemoteMapList {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.extraInfo.stringValue = @"Fetching remote maps list...";
    });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) didGetRemoteMapList {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.extraInfo.stringValue = @"Successfully fetched remote maps list";
    });
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
   
     dispatch_async(dispatch_get_main_queue(), ^{
         self.extraInfo.stringValue = @"Synchronizing maps";
         [self.tableViewItems reloadData];
     });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) willSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int) t_index {

    __block int index = t_index;
    
    if(index>=0) {
        self.itemStatus[index] = TABLE_STATUS_SYNCING;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableViewItems selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:false];
            [self.tableViewItems scrollRowToVisible:index];
            [self.tableViewItems reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        });
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) didSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int) t_index syncOK:(BOOL)syncOK {

    __block int index = t_index;
    
    if(index>=0) {
        self.itemStatus[index] = syncOK ? TABLE_STATUS_DONE_OK : TABLE_STATUS_DONE_ERROR;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableViewItems selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:false];
            [self.tableViewItems scrollRowToVisible:index];
            [self.tableViewItems reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        });
    }
}



// =====================================================================================================================
#pragma mark -
#pragma mark PRIVATE methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) cleanDeletedMaps {

    NSArray *allMaps = [MMap allMapsInContext:self.moContext includeMarkedAsDeleted:true];
    for(MMap *map in allMaps) {
        if(map.markedAsDeletedValue) {
            [map.managedObjectContext deleteObject:map];
        }
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *) textFromTuple:(GMTCompTuple *)tuple {
    
    const NSString *TupleStatusNames[] = {@"+", @"+", @"-", @"-", @"*", @"*"};
    
    NSString *localName = tuple.localItem ? tuple.localItem.name : @"<empty>";
    NSString *remoteName = tuple.remoteItem ? tuple.remoteItem.name : @"<empty>";
    NSString *text = [NSString stringWithFormat:@"%@ / %@ / %@", localName, remoteName, TupleStatusNames[tuple.status]];
    return text;
}

@end
