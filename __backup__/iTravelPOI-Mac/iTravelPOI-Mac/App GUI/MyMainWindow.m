//
//  MyMainWindow.m
//  iTravelPOI-Mac
//
//  Created by Jose Zarzuela on 26/01/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __MyMainWindow__IMPL__
#import "MyMainWindow.h"
#import "DDLog.h"

#import "BaseCoreData.h"

#import "GSyncPanel.h"
#import "EntityEditorPanel.h"
#import "MapEditorPanel.h"
#import "PointEditorPanel.h"
#import "CategoryEditorPanel.h"
#import "RMCViewCount.h"

#import "ImageManager.h"

#import "MyCellView.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MyMainWindow() <GSyncPanelDelegate, EntityEditorPanelDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, assign) IBOutlet NSTableView *tableViewItems;

@property (nonatomic, strong) NSArray *loadedItems;
@property (nonatomic, assign) BOOL toolBarEnabled;

@property (nonatomic, strong) MMap *selectedMap;
@property (nonatomic, strong) MCategory *selectedCategory;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MyMainWindow




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MyMainWindow *) myMainWindow {
    
    MyMainWindow *me = [[MyMainWindow alloc] initWithWindowNibName:@"MyMainWindow"];
    if(me) {
        [me.window makeKeyAndOrderFront:me];
        return me;
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
    [self loadTableDataSelectingObjWithID:nil];
    
    [self.window makeKeyAndOrderFront:self];
    [self.window setOrderedIndex:0];
    
}

// ------------------------------------------------------------------------------------------------------------------
- (void) awakeFromNib {
    
    
    NSNib *cellNib = [[NSNib alloc] initWithNibNamed:@"MyCellView" bundle:nil];
    [self.tableViewItems registerNib:cellNib forIdentifier:@"MyCellViewID"];
    // [self.itemsTable reloadData];
    
    [self.tableViewItems setDoubleAction:@selector(tableRowDoubleClicked:)];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark <IBAction> methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) toolbarSyncItemAction:(id)sender {
        
    NSManagedObjectContext *moc = [BaseCoreData moChildContextASync];
    [GSyncPanel startSyncWithMOContext:moc delegate:self];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) toolbarBackItemAction:(id)sender {
    
    if(self.selectedCategory != nil) {
        
        NSManagedObjectID *objID = self.selectedCategory.objectID;
        self.selectedCategory = self.selectedCategory.parent;
        [self loadTableDataSelectingObjWithID:objID];
        
    } else if(self.selectedMap != nil) {
        
        NSManagedObjectID *objID = self.selectedMap.objectID;
        self.selectedMap = nil;
        [self loadTableDataSelectingObjWithID:objID];
        
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) toolbarAddItemAction:(id)sender {
    
    NSManagedObjectContext *moc = [BaseCoreData moChildContext];
    
    if(self.selectedMap == nil) {
        MMap *newMap = [MMap emptyMapWithName:@"" inContext:moc];
        [MapEditorPanel startEditMap:newMap delegate:self];
    } else {
        MMap *copiedMap = nil;
        MCategory *copiedCategory = nil;
        
        if(self.selectedMap!=nil) copiedMap = (MMap *)[moc objectWithID:self.selectedMap.objectID];
        if(self.selectedCategory!=nil) copiedCategory = (MCategory *)[moc objectWithID:self.selectedCategory.objectID];
        
        MPoint *newPoint = [MPoint emptyPointWithName:@"" inMap:copiedMap withCategory:copiedCategory];
        [PointEditorPanel startEditPoint:newPoint delegate:self];
    }
}

// ------------------------------------------------------------------------------------------------------------------
- (IBAction) toolbarEditItemAction:(id)sender {
    
    NSInteger index = [self.tableViewItems selectedRow];
    if(index < 0) return;
    
    MMapBaseEntity *item = self.loadedItems[index];
    
    NSManagedObjectContext *moc = [BaseCoreData moChildContext];
    MMapBaseEntity *selectedItemCopy = (MMapBaseEntity *)[moc objectWithID:item.objectID];
    
    
    if([item isKindOfClass:[MMap class]]) {
        
        [MapEditorPanel startEditMap:(MMap *)selectedItemCopy delegate:self];
        
    } else if([item isKindOfClass:[MPoint class]]) {
        
        [PointEditorPanel startEditPoint:(MPoint *)selectedItemCopy delegate:self];
        
    } else {
        
        [CategoryEditorPanel startEditCategory:(MCategory *)selectedItemCopy inMap:self.selectedMap delegate:self];
        
    }
}

// ------------------------------------------------------------------------------------------------------------------
- (IBAction) toolbarRemoveItemAction:(id)sender {
    
    NSInteger index = [self.tableViewItems selectedRow];
    if(index >= 0) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Delete item?"];
        [alert setInformativeText:@"Deleted records cannot be restored."];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        [alert beginSheetModalForWindow:self.window
                          modalDelegate:self
                         didEndSelector:@selector(alertRemoveItemDidEnd:returnCode:contextInfo:)
                            contextInfo:nil];
    }
    
}

// ------------------------------------------------------------------------------------------------------------------
- (void) alertRemoveItemDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    
    NSInteger index = [self.tableViewItems selectedRow];
    if(index < 0 || returnCode != NSAlertFirstButtonReturn) return;
    
    MMapBaseEntity *item = self.loadedItems[index];
    
    // Esto no funciona con las categorias
    if([item isKindOfClass:[MCategory class]]) {
        [((MCategory *)item) deletePointsInMap:self.selectedMap];
    } else {
        [item updateDeleteMark:true];
    }
    
    [BaseCoreData saveContext];
    
    NSMutableArray *reducedItems = [NSMutableArray arrayWithArray:self.loadedItems];
    [reducedItems removeObjectAtIndex:index];
    self.loadedItems = reducedItems;
    
    [self.tableViewItems removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationSlideUp];
    
    
}

// =====================================================================================================================
#pragma mark -
#pragma mark <NSToolbarItemValidation> methods
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL) validateToolbarItem:(NSToolbarItem *)toolbarItem {
    
    return self.toolBarEnabled;
}

// =====================================================================================================================
#pragma mark -
#pragma mark <NSTableViewDataSource, NSTableViewDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView {
    NSUInteger count = self.loadedItems.count;
    return count;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Consigue una instancia de la celda
    MyCellView *resultCell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    // SIEMPRE se debe desasociar de cualquier item que tuviese de un uso anterior
    resultCell.objectValue = nil;
    
    // Establece los nuevos valores
    MBaseEntity *itemToShow = self.loadedItems[row];
    [resultCell setLabelText:itemToShow.name badgeText:itemToShow.strViewCount image:itemToShow.entityImage];
    
    return resultCell;
}

// =====================================================================================================================
#pragma mark -
#pragma mark <EntityEditorPanelDelegate> <GSyncPanelDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) editorPanelSaveChanges:(MapEditorPanel *)sender {
    
    NSManagedObjectContext *moc = sender.entity.managedObjectContext;
    
    // Tiene que salvar la informacion del contexto hijo al padre y de este a disco
    [BaseCoreData saveMOContext:moc saveAll:TRUE];
    
    MMapBaseEntity *savedEntity = (MMapBaseEntity *)[[BaseCoreData moContext] objectWithID:sender.entity.objectID];
    
    // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
    // mejor recargar la informacion de nuevo
    [self loadTableDataSelectingObjWithID:savedEntity.objectID];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) gsyncPanelClose:(GSyncPanel *)sender {
    
    NSManagedObjectContext *moc = sender.moContext;
    
    // Tiene que salvar la informacion del contexto hijo al padre y de este a disco
    [BaseCoreData saveMOContext:moc saveAll:TRUE];
    
    // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
    // mejor recargar la informacion de nuevo
    self.selectedMap = nil;
    self.selectedCategory = nil;
    [self loadTableDataSelectingObjWithID:nil];
}



// =====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) tableRowDoubleClicked:(NSTableView *)tableView {
    
    
    NSInteger rowNumber = [tableView clickedRow];
    if(rowNumber >= 0) {
        
        MBaseEntity *selectedItem = self.loadedItems[rowNumber];
        
        if([selectedItem isKindOfClass:[MMap class]]) {
            
            self.selectedMap = (MMap *)selectedItem;
            [self loadTableDataSelectingObjWithID:nil];
            
        } else if([selectedItem isKindOfClass:[MCategory class]]) {
            
            self.selectedCategory = (MCategory *)selectedItem;
            [self loadTableDataSelectingObjWithID:nil];
            
        }
        
    }
    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) loadTableDataSelectingObjWithID:(NSManagedObjectID *)objID {
    
    // De momento, vamos a presuponer que las consultas son lo suficientemente rapidas como para hacerlas en el hilo principal
    
    self.toolBarEnabled = false;
    
    
    NSArray *loadedItems = nil;
    
    if(self.selectedMap == nil) {
        // carga todos los mapas disponibles
        NSManagedObjectContext *moc = [BaseCoreData moContext];
        loadedItems = [MMap allMapsInContext:moc includeMarkedAsDeleted:false];
    } else {
        NSArray *cats = [MCategory categoriesWithPointsInMap:self.selectedMap parentCategory:self.selectedCategory];
        NSArray *points = [MPoint pointsInMap:self.selectedMap category:self.selectedCategory];
        NSMutableArray *allItems = [NSMutableArray arrayWithArray:cats];
        [allItems addObjectsFromArray:points];
        loadedItems = allItems;
    }
    
    self.loadedItems = loadedItems;
    [self.tableViewItems reloadData];
    
    if(objID != nil) {
        for(NSInteger n = 0; n < self.loadedItems.count; n++) {
            MMapBaseEntity *item = self.loadedItems[n];
            if([item.objectID isEqual:objID]) {
                [self.tableViewItems selectRowIndexes:[NSIndexSet indexSetWithIndex:n] byExtendingSelection:false];
                [self.tableViewItems scrollRowToVisible:n];
                break;
            }
        }
    }
    
    self.toolBarEnabled = true;
    
}




@end

