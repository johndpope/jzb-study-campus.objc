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


@interface AppDelegate()

@property (strong) NSArray *groups;
@property (strong) NSArray *points;
@property (strong) NSMutableArray *filter;

@end


@implementation AppDelegate


@synthesize dataTable = _dataTable;
@synthesize goBackButton = _goBackButton;
@synthesize groupLabel = _groupLabel;
@synthesize groups = _groups;
@synthesize points = _points;



//------------------------------------------------------------------------------------------------------------------
- (id)init {
    if ((self = [super init])) {
        self.filter = [NSMutableArray array];
    }
    return self;
}

//------------------------------------------------------------------------------------------------------------------
- (IBAction)goBackAction:(NSButton *)sender {
    [self removeLastFilterName];
}

//------------------------------------------------------------------------------------------------------------------
- (IBAction)goHomeAction:(NSButton *)sender {
    [self removeAllFilterNames];
}


//------------------------------------------------------------------------------------------------------------------
- (IBAction)table_row_doubleClick:(NSTableView *)sender {
    
    NSInteger rowNumber = [self.dataTable clickedRow];
    
    if(rowNumber>=0 && rowNumber<self.groups.count) {
        NSString *groupName = [self objectValueForNameInRow:rowNumber];
        [self addFilterName:groupName];
    }
    
}

//------------------------------------------------------------------------------------------------------------------
- (void) addFilterName:(NSString *)groupName {
    
    if(groupName) {
        MGroup *group = [MGroup searchGroupByName:groupName];
        [self.filter addObject:group];
    }
    
    [self refreshData];
    
}

//------------------------------------------------------------------------------------------------------------------
- (void) removeAllFilterNames {
    [self.filter removeAllObjects];
    [self refreshData];
}

//------------------------------------------------------------------------------------------------------------------
- (void) removeLastFilterName {
    
    if(self.filter.count>0) {
        [self.filter removeLastObject];
    }
    
    [self refreshData];
    
}

//------------------------------------------------------------------------------------------------------------------
- (void) refreshData {
    
    NSDate *t1 = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDictionary *result = [ModelDAO searchEntitiesWithFilter:self.filter];
    NSDate *t2 = [NSDate dateWithTimeIntervalSinceNow:0];
    double time = [t2 timeIntervalSinceDate:t1]*1000.0;
    
    self.groups = [result objectForKey:FOUND_GROUPS_KEY];
    self.points = [result objectForKey:FOUND_POINTS_KEY];
    
    
    NSMutableString *str = [NSMutableString stringWithFormat:@"Result [%f]:\n",time];
    [str appendString:@"-- groups ----------\n"];
    for(MDataView *value in self.groups) {
        MGroup *group = (MGroup *)value.element;
        [str appendFormat:@"  %@ - %d\n", group.name, value.count];
    }
    [str appendFormat:@"\n-- points [%lu]----------\n",self.points.count];
    int counter = 0;
    for(MDataView *value in self.points) {
        MPoint *point = (MPoint *)value.element;
        [str appendFormat:@"  %@\n", point.name];
        counter++;
        if(counter>4) {
            [str appendFormat:@"  ...more points...\n"];
            break;
        }
    }
    
    NSLog(@"result = \n%@",str);
    
    if(self.filter.count>0) {
        self.groupLabel.stringValue=((MGroup *)self.filter.lastObject).name;
        if(self.filter.count>1) {
            self.goBackButton.title=((MGroup *)self.filter[self.filter.count-2]).name;
        } else{
            self.goBackButton.title=@"[ROOT]";
        }
    } else {
        self.groupLabel.stringValue=@"[ROOT]";
        self.goBackButton.title=@"";
    }
    
    [self.dataTable reloadData];
}


//------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView {
    NSUInteger count = self.groups.count + self.points.count;
    return count;
}

//------------------------------------------------------------------------------------------------------------------
- (id) objectValueForNameInRow:(NSInteger)row {
    if(row<self.groups.count) {
        MGroup *group =(MGroup *)[self.groups[row] element];
        return group.name;
    } else {
        NSInteger index= row-self.groups.count;
        MPoint *point = (MPoint *)[self.points[index] element];
        return point.name;
    }
}

//------------------------------------------------------------------------------------------------------------------
- (id) objectValueForCountInRow:(NSInteger)row {
    if(row<self.groups.count) {
        MDataView *dataView = (MDataView *)self.groups[row];
        return [NSNumber numberWithUnsignedInt:dataView.count];
    } else {
        return @"";
    }
}

//------------------------------------------------------------------------------------------------------------------
- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if([tableColumn.identifier isEqualToString:@"type"]) {
        if(row<self.groups.count) {
            return @"G";
        } else {
            return @"P";
        }
    } else if([tableColumn.identifier isEqualToString:@"name"]) {
        return [self objectValueForNameInRow:row];
    } else if([tableColumn.identifier isEqualToString:@"count"]) {
        return [self objectValueForCountInRow:row];
    }
    
    
    
    return nil;
}

//------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib {
    [self.dataTable setTarget:self];
    [self.dataTable setDoubleAction:@selector(table_row_doubleClick:)];
}

//------------------------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
    //---------------------------------------
    [MockUp resetModel:@"iTravelPOI"];
    
    
    
    if(![BaseCoreData initCDStack:@"iTravelPOI"]) {
        NSAlert *alert = [NSAlert alertWithError:BaseCoreData.lastError];
        [alert setMessageText:@"Error inicializando Core Data"];
        [alert runModal];
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    if(![ModelDAO createInitialData]) {
        NSAlert *alert = [NSAlert alertWithError:BaseCoreData.lastError];
        [alert setMessageText:@"Error inicializando la informacion inicial de partida"];
        [alert runModal];
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    
    //---------------------------------------
    [MockUp populateModel];
    
    [self addFilterName:nil];
    
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
