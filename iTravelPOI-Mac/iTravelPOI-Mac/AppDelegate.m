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
#import "PointEditorPanel.h"
#import "MyCellView.h"

#import "MockUp.h"
#import "AppTesting.h"

#import "MCategory.h"
#import "MPoint.h"
#import "BaseCoreData.h"
#import "NSString+JavaStr.h"
#import "PCachingViewCount.h"





// *********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
// *********************************************************************************************************************
@interface AppDelegate() <MapEditorPanelDelegate, PointEditorPanelDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (assign) IBOutlet NSTableView *itemsTable;

@property (strong) NSWindowController *mainWnd;
@property (strong) NSArray *items;

@property (strong) MMap *selectedMap;
@property (strong) MCategory *selectedCategory;

@property (assign) BOOL listDataLoaded;

@end



// *********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
// *********************************************************************************************************************
@implementation AppDelegate


//------------------------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.listDataLoaded = false;
    self.selectedMap = nil;
    self.selectedCategory = nil;
    [self initDataModel];
    
    [self loadTableDataSelectingObjWithID:nil];
    
    //[self showMainWindow];
}

//------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib {
    
    
    NSNib *cellNib = [[NSNib alloc] initWithNibNamed:@"MyCellView" bundle:nil];
    [self.itemsTable registerNib:cellNib forIdentifier:@"MyCellViewID"];
    //[self.itemsTable reloadData];
    
    [self.itemsTable setDoubleAction:@selector(tableRowDoubleClicked:)];
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
#pragma mark <IBAction> methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)toolbarBackItemAction:(id)sender {
 
    if(self.selectedCategory!=nil) {
        
        self.selectedCategory = self.selectedCategory.parent;
        [self loadTableDataSelectingObjWithID:nil];
        
    } else if (self.selectedMap!=nil) {
        
        self.selectedMap = nil;
        [self loadTableDataSelectingObjWithID:nil];
        
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction) toolbarAddItemAction:(id)sender {
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    moc.parentContext =[BaseCoreData moContext];
    
    if(self.selectedMap == nil) {
        MMap *newMap = [MMap emptyMapInContext:moc];
        [MapEditorPanel startEditMap:newMap delegate:self];
    } else {
        MMap *copiedMap = (MMap *)[moc objectWithID:self.selectedMap.objectID];
        MCategory *copiedCat = (MCategory *)[moc objectWithID:self.selectedCategory.objectID];
        MPoint *newPoint = [MPoint emptyPointInMap:copiedMap inContext:moc];
        newPoint.iconHREF = copiedCat.iconHREF;
        [PointEditorPanel startEditPoint:newPoint delegate:self];
    }
}

//------------------------------------------------------------------------------------------------------------------
- (IBAction) toolbarEditItemAction:(id)sender {
    
    NSInteger index = [self.itemsTable selectedRow];
    if(index<0) return;
    
    MBaseEntity *item = self.items[index];
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    moc.parentContext =[BaseCoreData moContext];
    MBaseEntity *selectedItem = (MBaseEntity *)[moc objectWithID:item.objectID];

    
    if([item isKindOfClass:[MMap class]]) {
    
        [MapEditorPanel startEditMap:(MMap *)selectedItem delegate:self];
    } else {
        
        [PointEditorPanel startEditPoint:(MPoint *)selectedItem delegate:self];
    }
}

//------------------------------------------------------------------------------------------------------------------
- (IBAction) toolbarRemoveItemAction:(id)sender {
    
    NSInteger index = [self.itemsTable selectedRow];
    if(index>=0) {
        
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

//------------------------------------------------------------------------------------------------------------------
- (void)alertRemoveItemDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {

    NSInteger index = [self.itemsTable selectedRow];
    if(index<0 || returnCode != NSAlertFirstButtonReturn) return;
    
    MBaseEntity *item= self.items[index];

    // Esto no funciona con las categorias
    item.markedAsDeletedValue = true;
    item.modifiedSinceLastSyncValue = true;
    [BaseCoreData saveContext];
    
    NSMutableArray *reducedItems = [NSMutableArray arrayWithArray:self.items];
    [reducedItems removeObjectAtIndex:index];
    self.items = reducedItems;
    
    [self.itemsTable removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationSlideUp];
    
    
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


// =====================================================================================================================
#pragma mark -
#pragma mark <NSToolbarItemValidation> methods
// ---------------------------------------------------------------------------------------------------------------------
-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem {
    
    BOOL enable = self.listDataLoaded;
    return enable;
}



// =====================================================================================================================
#pragma mark -
#pragma mark <NSTableViewDataSource> methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView {
    NSUInteger count = self.items.count;
    return count;
}





// =====================================================================================================================
#pragma mark -
#pragma mark <NSTableViewDelegate> methods
//---------------------------------------------------------------------------------------------------------------------
- (void) asyncSetBadgeTextForCell:(MyCellView *)cell cachingItem:(id<PCachingViewCount>)cachingItem {

    // Array con los items que se estan calculando
    static NSMutableDictionary *calculatingItems = nil;
    if(calculatingItems==nil) {
        calculatingItems = [NSMutableDictionary dictionary];
    }

    
    // Si ya estaba calculada la cuenta la establece y termina
    NSString *viewCount = cachingItem.viewCount;
    if(viewCount!=nil) {
        cell.badgeText = viewCount;
        return;
    }


    // ------------------------------------------------------------------
    // Se tiene que hacer el calculo de forma asincrona
    cell.badgeText = @"???";

    // Se apoyara en el ID
    __block NSManagedObjectID *itemToShowID = cachingItem.objectID;


    // Asocia la celda con el item actual
    cell.objectValue = itemToShowID;

    // Comprueba si ya estaba realizando el calculo para ese item (se le asocia la nueva celda)
    MyCellView *prevCell = [calculatingItems objectForKey:itemToShowID];
    [calculatingItems setObject:cell forKey:itemToShowID];
    if(prevCell!=nil) {
        // Si la celda anterior me seguia apuntando a mi la libera
        if([prevCell.objectValue isEqual:itemToShowID]) {
            prevCell.objectValue = nil;
        }
        // Termina
        return;
    }
    

    
    // ------------------------------------------------------------------
    // Realiza el calculo de forma asincrona
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    moc.parentContext =[BaseCoreData moContext];
    [moc performBlock:^{
        
        //[NSThread sleepForTimeInterval:20];
        
        // Actualiza la cuenta para su visualizacion
        id<PCachingViewCount> cachingItem = (id<PCachingViewCount>)[moc objectWithID:itemToShowID];
        [cachingItem updateViewCount];
        
        // Graba el resultado al contexto padre
        NSError *err = nil;
        if(![moc save:&err]) {
            NSLog(@"Error salvando la cuenta de puntos: %@", err);
        }
        
        // ------------------------------------------------------------------
        // Actualiza el texto de la celda en el hilo principal
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MyCellView *prevCell = [calculatingItems objectForKey:itemToShowID];
            [calculatingItems removeObjectForKey:itemToShowID];
            
            if([prevCell.objectValue isEqual:itemToShowID]){
                id<PCachingViewCount> cachingItem = (id<PCachingViewCount>)[[BaseCoreData moContext] objectWithID:itemToShowID];
                prevCell.badgeText = cachingItem.viewCount;
            }
            
            // Si no hay actualizaciones graba el contexto
            if(calculatingItems.count<=0) {
                [BaseCoreData saveContext];
            }
        });
        
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    MBaseEntity *itemToShow = self.items[row];
    
    MyCellView *resultCell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    resultCell.labelText = itemToShow.name;
    //resultCell = itemToShow;
    

    // SIEMPRE se debe desasociar de cualquier item que tuviese de un uso anterior
    resultCell.objectValue = nil;
    
    // Establece el nuevo valor dependiendo del tipo de elemento
    if(![itemToShow conformsToProtocol:@protocol(PCachingViewCount)]) {
        resultCell.badgeText = nil;
    } else {
    
        id<PCachingViewCount> cachingItem;
        
        // Si es una categoria necesitamos su asociacion con el mapa
        if([itemToShow isKindOfClass:[MCategory class]]) {
            MCategory *cat = (MCategory *)itemToShow;
            cachingItem = [(MCategory *)cat viewCountForMap:self.selectedMap];
        } else {
            cachingItem = (id<PCachingViewCount>)itemToShow;
        }

        [self asyncSetBadgeTextForCell:resultCell cachingItem:cachingItem];

    }
    
    return resultCell;
}



// =====================================================================================================================
#pragma mark -
#pragma mark <MapEditorPanelDelegate> methods
//---------------------------------------------------------------------------------------------------------------------
- (void) mapPanelSaveChanges:(MapEditorPanel *)sender {
    
    NSManagedObjectContext *moc =sender.map.managedObjectContext;
    
    // Tiene que salvar la informacion del contexto hijo al padre y de este a disco
    [BaseCoreData saveMOContext:moc];
    [BaseCoreData saveContext];
    
    MMap *savedMap = (MMap *)[[BaseCoreData moContext] objectWithID:sender.map.objectID];
    
    // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
    // mejor recargar la informacion de nuevo
    [self loadTableDataSelectingObjWithID:savedMap.objectID];
}

//------------------------------------------------------------------------------------------------------------------
- (void) mapPanelCancelChanges:(MapEditorPanel *)sender {
    // Nothing to do
}



// =====================================================================================================================
#pragma mark -
#pragma mark <PointEditorPanelDelegate> methods
//---------------------------------------------------------------------------------------------------------------------
- (void) pointPanelSaveChanges:(PointEditorPanel *)sender {
    
    NSManagedObjectContext *moc =sender.point.managedObjectContext;
    
    // Tiene que salvar la informacion del contexto hijo al padre y de este a disco
    [BaseCoreData saveMOContext:moc];
    [BaseCoreData saveContext];
    
    MPoint *savedPoint = (MPoint *)[[BaseCoreData moContext] objectWithID:sender.point.objectID];
    
    // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
    // mejor recargar la informacion de nuevo
    [self loadTableDataSelectingObjWithID:savedPoint.objectID];
}

//------------------------------------------------------------------------------------------------------------------
- (void) pointPanelCancelChanges:(PointEditorPanel *)sender {
    // Nothing to do
}





// =====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) tableRowDoubleClicked:(NSTableView *)tableView {

    
    NSInteger rowNumber = [tableView clickedRow];
    if(rowNumber>=0) {
        
        MBaseEntity *selectedItem = self.items[rowNumber];

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
    
    self.listDataLoaded=false;
    
    
    NSError *err=nil;
    NSArray *loadedItems = nil;
    
    if(self.selectedMap==nil) {
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
    
    self.items = loadedItems;
    [self.itemsTable reloadData];
    
    if(objID!=nil) {
        for(NSInteger n=0;n<self.items.count;n++) {
            MBaseEntity *item = self.items[n];
            if([item.objectID isEqual:objID]) {
                [self.itemsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:n] byExtendingSelection:false];
            }
        }
    }
    
    self.listDataLoaded=true;

}


// ---------------------------------------------------------------------------------------------------------------------
- (void) initDataModel {
    
    //---------------------------------------
    //---------------------------------------
    [MockUp resetModel:@"iTravelPOI"];
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
    
    [MockUp populateModel];
     /*
    [AppTesting excuteTestWithMOContext:BaseCoreData.moContext];
     */
    //---------------------------------------
    //---------------------------------------
    
    
}




//------------------------------------------------------------------------------------------------------------------
// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [BaseCoreData.moContext undoManager];
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
