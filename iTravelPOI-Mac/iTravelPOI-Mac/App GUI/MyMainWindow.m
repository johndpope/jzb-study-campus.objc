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

#import "MapEditorPanel.h"
#import "PointEditorPanel.h"
#import "CategoryEditorPanel.h"

#import "MyCellView.h"

#import "GMapIcon.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MyMainWindow() <MapEditorPanelDelegate, PointEditorPanelDelegate, CategoryEditorPanelDelegate, NSTableViewDelegate, NSTableViewDataSource>

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
- (IBAction) toolbarBackItemAction:(id)sender {
    
    if(self.selectedCategory != nil) {
        
        self.selectedCategory = self.selectedCategory.parent;
        [self loadTableDataSelectingObjWithID:nil];
        
    } else if(self.selectedMap != nil) {
        
        self.selectedMap = nil;
        [self loadTableDataSelectingObjWithID:nil];
        
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction) toolbarAddItemAction:(id)sender {
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    moc.parentContext = [BaseCoreData moContext];
    
    if(self.selectedMap == nil) {
        MMap *newMap = [MMap emptyMapInContext:moc];
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
    
    MBaseEntity *item = self.loadedItems[index];
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    moc.parentContext = [BaseCoreData moContext];
    MBaseEntity *selectedItemCopy = (MBaseEntity *)[moc objectWithID:item.objectID];
    
    
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
        
        [alert beginSheetModalForWindow:[[NSApp delegate] window]
                          modalDelegate:self
                         didEndSelector:@selector(alertRemoveItemDidEnd:returnCode:contextInfo:)
                            contextInfo:nil];
    }
    
}

// ------------------------------------------------------------------------------------------------------------------
- (void) alertRemoveItemDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    
    NSInteger index = [self.tableViewItems selectedRow];
    if(index < 0 || returnCode != NSAlertFirstButtonReturn) return;
    
    MBaseEntity *item = self.loadedItems[index];
    
    // Esto no funciona con las categorias
    if([item isKindOfClass:[MCategory class]]) {
        [((MCategory *)item) deletePointsWithMap:self.selectedMap];
    } else {
        [item setAsDeleted:true];
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
#pragma mark <NSTableViewDataSource> methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView {
    NSUInteger count = self.loadedItems.count;
    return count;
}

// =====================================================================================================================
#pragma mark -
#pragma mark <NSTableViewDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    MBaseEntity *itemToShow = self.loadedItems[row];
    
    MyCellView *resultCell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    resultCell.labelText = itemToShow.name;
    // resultCell = itemToShow;
    
    
    // SIEMPRE se debe desasociar de cualquier item que tuviese de un uso anterior
    resultCell.objectValue = nil;
    
    // Establece el nuevo valor dependiendo del tipo de elemento
    if([itemToShow isKindOfClass:[MPoint class]]) {
        
        MPoint *pointToShow = (MPoint *)itemToShow;
        resultCell.badgeText = nil;
        GMapIcon *gmapIcon = [GMapIcon iconForHREF:pointToShow.iconHREF];
        resultCell.imageView.image = gmapIcon.image;
        
    } else if([itemToShow isKindOfClass:[MMap class]]) {
        
        MMap *mapToShow = (MMap *)itemToShow;
        resultCell.badgeText=[NSString stringWithFormat:@"%03d", mapToShow.viewCountValue];
        resultCell.imageView.image = nil;
        
    } else {
        
        MCategory *catToShow = (MCategory *)itemToShow;
        MCacheViewCount *viewCountForMap = [catToShow viewCountForMap:self.selectedMap];
        resultCell.badgeText=[NSString stringWithFormat:@"%03d", viewCountForMap.viewCountValue];
        GMapIcon *gmapIcon = [GMapIcon iconForHREF:catToShow.iconHREF];
        resultCell.imageView.image = gmapIcon.image;
        
    }
    
    return resultCell;
}

// =====================================================================================================================
#pragma mark -
#pragma mark <MapEditorPanelDelegate> <PointEditorPanelDelegate> <CategoryEditorPanelDelegate> methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) mapPanelSaveChanges:(MapEditorPanel *)sender {
    
    NSManagedObjectContext *moc = sender.map.managedObjectContext;
    
    // Tiene que salvar la informacion del contexto hijo al padre y de este a disco
    [BaseCoreData saveMOContext:moc];
    [BaseCoreData saveContext];
    
    MMap *savedMap = (MMap *)[[BaseCoreData moContext] objectWithID:sender.map.objectID];
    
    // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
    // mejor recargar la informacion de nuevo
    [self loadTableDataSelectingObjWithID:savedMap.objectID];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) pointPanelSaveChanges:(PointEditorPanel *)sender {
    
    NSManagedObjectContext *moc = sender.point.managedObjectContext;
    
    // Tiene que salvar la informacion del contexto hijo al padre y de este a disco
    [BaseCoreData saveMOContext:moc];
    [BaseCoreData saveContext];
    
    MPoint *savedPoint = (MPoint *)[[BaseCoreData moContext] objectWithID:sender.point.objectID];
    
    // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
    // mejor recargar la informacion de nuevo
    [self loadTableDataSelectingObjWithID:savedPoint.objectID];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) categoryPanelSaveChanges:(CategoryEditorPanel *)sender {
    
    NSManagedObjectContext *moc = sender.category.managedObjectContext;
    
    // Tiene que salvar la informacion del contexto hijo al padre y de este a disco
    [BaseCoreData saveMOContext:moc];
    [BaseCoreData saveContext];
    
    MCategory *savedCategory = (MCategory *)[[BaseCoreData moContext] objectWithID:sender.category.objectID];
    
    // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
    // mejor recargar la informacion de nuevo
    [self loadTableDataSelectingObjWithID:savedCategory.objectID];
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
    
    
    NSError *err = nil;
    NSArray *loadedItems = nil;
    
    if(self.selectedMap == nil) {
        // carga todos los mapas disponibles
        NSManagedObjectContext *moc = [BaseCoreData moContext];
        loadedItems = [MMap allMapsInContext:moc includeMarkedAsDeleted:false error:&err];
    } else {
        NSArray *cats = [MCategory categoriesFromMap:self.selectedMap parentCategory:self.selectedCategory error:&err];
        NSArray *points = [MPoint pointsFromMap:self.selectedMap category:self.selectedCategory error:&err];
        NSMutableArray *allItems = [NSMutableArray arrayWithArray:cats];
        [allItems addObjectsFromArray:points];
        loadedItems = allItems;
    }
    
    self.loadedItems = loadedItems;
    [self.tableViewItems reloadData];
    
    if(objID != nil) {
        for(NSInteger n = 0; n < self.loadedItems.count; n++) {
            MBaseEntity *item = self.loadedItems[n];
            if([item.objectID isEqual:objID]) {
                [self.tableViewItems selectRowIndexes:[NSIndexSet indexSetWithIndex:n] byExtendingSelection:false];
            }
        }
    }
    
    self.toolBarEnabled = true;
    
}




@end

