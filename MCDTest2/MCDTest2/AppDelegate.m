//
//  AppDelegate.m
//  MCDTest2
//
//  Created by Jose Zarzuela on 29/07/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "AppDelegate.h"
#import "Model/Model.h"
#import "Services/BaseCoreData.h"
#import "Services/ModelDAO.h"
#import "Services/FixedData.h"
#import "Services/GMapSync.h"

#import "MockUp.h"

@interface AppDelegate()

@property (strong) GroupsAndPoints *result;
@property (strong) NSMutableArray *filter;

@end


@implementation AppDelegate


@synthesize dataTable;
@synthesize goBackButton;
@synthesize groupLabel;
@synthesize result;


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
    
    NSInteger rowNumber = [dataTable clickedRow];
    
    if(rowNumber>=0 && rowNumber<result.groupsAndCounts.count) {
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
    self.result = [ModelDAO searchEntitiesWithFilter:self.filter];
    NSDate *t2 = [NSDate dateWithTimeIntervalSinceNow:0];
    double time = [t2 timeIntervalSinceDate:t1]*1000.0;
    
    
    NSMutableString *str = [NSMutableString stringWithFormat:@"Result [%f]:\n",time];
    [str appendString:@"-- groups ----------\n"];
    for(GroupAndCount *value in result.groupsAndCounts) {
        MGroup *group = (MGroup *)[BaseCoreData.moContext objectWithID:value.group];
        group.viewCount = value.count;
        [str appendFormat:@"  %@ - %d\n", group.name, group.viewCount];
    }
    [str appendFormat:@"\n-- points [%lu]----------\n",result.points.count];
    int counter = 0;
    for(NSManagedObjectID *pointID in  result.points) {
        MPoint *point = (MPoint *)[BaseCoreData.moContext objectWithID:pointID];
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
    NSUInteger count = result.groupsAndCounts.count + result.points.count;
    return count;
}

//------------------------------------------------------------------------------------------------------------------
- (id) objectValueForNameInRow:(NSInteger)row {
    if(row<result.groupsAndCounts.count) {
        id value = ((GroupAndCount*)result.groupsAndCounts[row]).group;
        if([value isKindOfClass:NSManagedObjectID.class]) {
            value = [BaseCoreData.moContext objectWithID:value];
            ((GroupAndCount*)result.groupsAndCounts[row]).group = value;
        }
        return ((MGroup *)value).name;
    } else {
        NSInteger index= row-result.groupsAndCounts.count;
        id value = result.points[index];
        if([value isKindOfClass:NSManagedObjectID.class]) {
            value = [BaseCoreData.moContext objectWithID:value];
            result.points[index] = value;
        }
        return ((MPoint *)value).name;
    }
}

//------------------------------------------------------------------------------------------------------------------
- (id) objectValueForCountInRow:(NSInteger)row {
    if(row<result.groupsAndCounts.count) {
        id value = ((GroupAndCount*)result.groupsAndCounts[row]).group;
        if([value isKindOfClass:NSManagedObjectID.class]) {
            value = [BaseCoreData.moContext objectWithID:value];
            ((GroupAndCount*)result.groupsAndCounts[row]).group = value;
        }
        return [NSNumber numberWithUnsignedInt:((MGroup *)value).viewCount];
    } else {
        return @"";
    }
}

//------------------------------------------------------------------------------------------------------------------
- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if([tableColumn.identifier isEqualToString:@"type"]) {
        if(row<result.groupsAndCounts.count) {
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
    [dataTable setTarget:self];
    [dataTable setDoubleAction:@selector(table_row_doubleClick:)];
}

//------------------------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    NSError *error = nil;
    GMapSync *gmaps = [[GMapSync alloc] init];
    [gmaps loginWithUser:@"jzarzuela@gmail.com" password:@"#webweb1971"];
    GDataFeedBase *cosa = [gmaps fetchUserMapList:&error];
    NSLog(@"Error = %@, %@", error, [error userInfo]);
    NSLog(@"Cosa = %@", cosa);
    
    
    
    //---------------------------------------
    [MockUp resetModel];
    
    
    
    if(![BaseCoreData initCDStack:@"MCDTest2"]) {
        NSAlert *alert = [NSAlert alertWithError:BaseCoreData.lastError];
        [alert setMessageText:@"Error inicializando Core Data"];
        [alert runModal];
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    if(![FixedData initFixedData]) {
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
