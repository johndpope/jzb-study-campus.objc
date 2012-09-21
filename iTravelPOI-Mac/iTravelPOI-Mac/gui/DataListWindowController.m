//
//  DataListWindowController.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 30/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "DataListWindowController.h"
#import "ModelDAO.h"
#import "BaseCoreData.h"
#import "MyCellView.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private enumerations & definitions
//---------------------------------------------------------------------------------------------------------------------




//*********************************************************************************************************************
#pragma mark -
#pragma mark DataListWindowController Private interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface DataListWindowController ()

@property (strong) NSArray *groups;
@property (strong) NSArray *points;
@property (strong) NSMutableArray *filter;

@property (strong) GroupEditWindowController *groupEditorWC;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark DataListWindowController implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation DataListWindowController



@synthesize dataTable = _dataTable;
@synthesize goBackButton = _goBackButton;
@synthesize groupLabel = _groupLabel;

@synthesize groups = _groups;
@synthesize points = _points;
@synthesize filter = _filter;



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------



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
        self.filter = [NSMutableArray array];
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.dataTable setTarget:self];
    [self.dataTable setDoubleAction:@selector(table_row_doubleClick:)];
    [self refreshData];
    
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark NSTableViewDataSource protocol methods
//------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView {
    NSUInteger count = self.groups.count + self.points.count;
    return count;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    MyCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    //result.imageView.image = item.itemIcon;

    NSString *name = [self objectValueForNameInRow:row];
    result.textField.stringValue = name;
    
    if(row<self.groups.count) {
        NSString *count = [self objectValueForCountInRow:row];
        result.badgeText = count;
    } else {
        result.badgeText = nil;
    }
    
    return result;
}

//---------------------------------------------------------------------------------------------------------------------
- (id) tableView2:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
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



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark GroupEditorDelegate protocol methods
//------------------------------------------------------------------------------------------------------------------
- (void) endSaving:(MGroup *)group sender:(id)sender {
    [NSApp stopModalWithCode:0];
    [self.groupEditorWC close];
    //self.groupEditorWC = nil;
}

//------------------------------------------------------------------------------------------------------------------
- (void) endCanceling:(MGroup *)group sender:(id)sender {
    [NSApp stopModalWithCode:0];
    [self.groupEditorWC close];
    //self.groupEditorWC = nil;
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark OUTLET ACTION methods
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
        MDataView *dataView = self.groups[rowNumber];
        [self addFilterGroup:(MGroup*)dataView.element];
    }
    
}

//------------------------------------------------------------------------------------------------------------------
- (IBAction)addGroupAction:(NSToolbarItem *)sender {
    
    NSManagedObjectContext *moChildContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moChildContext setParentContext:BaseCoreData.moContext];
    [moChildContext setUndoManager:nil];
    
    MGroup *newGroup = [MGroup createGroupWithName:@"" parentGrp:nil inContext:moChildContext];
    [self openGroupEditorWithGroup:newGroup];
}


//------------------------------------------------------------------------------------------------------------------
- (IBAction)editEntityAction:(NSToolbarItem *)sender {

    
    NSInteger index = self.dataTable.selectedRow;
    if(index>=0 && index<self.groups.count) {
        
        MDataView *dataView = (MDataView *)self.groups[index];
        
        NSManagedObjectContext *moChildContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [moChildContext setParentContext:BaseCoreData.moContext];
        [moChildContext setUndoManager:nil];
        
        MGroup *group = (MGroup *)[moChildContext objectWithID:dataView.element.objectID];
        [self openGroupEditorWithGroup:group];
    }
}



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private methods
//------------------------------------------------------------------------------------------------------------------
- (void) addFilterGroup:(MGroup *)group {
    
    if(group) {
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
    NSDictionary *result = [ModelDAO searchEntitiesWithFilter:self.filter inContext:BaseCoreData.moContext];
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
        return [NSString stringWithFormat:@"%03u", dataView.count];
        //return [NSNumber numberWithUnsignedInt:dataView.count];
    } else {
        return @"";
    }
}

//------------------------------------------------------------------------------------------------------------------
- (void)openGroupEditorWithGroup:(MGroup *)group {
    
    if(self.groupEditorWC == nil) {
        self.groupEditorWC = [[GroupEditWindowController alloc] initWithWindowNibName:@"GroupEditWindowController"];
        self.groupEditorWC.delegate=self;
    }
    self.groupEditorWC.group = group;
    
    [NSApp runModalForWindow: self.groupEditorWC.window];
}



@end
