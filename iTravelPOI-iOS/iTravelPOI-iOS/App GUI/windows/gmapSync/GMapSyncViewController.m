//
//  GMapSyncViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#define __GMapSyncViewController__IMPL__
#import "GMapSyncViewController.h"

#import "SyncDataService.h"
#import "NSManagedObjectContext+Utils.h"

#import "ScrollableToolbar.h"
#import "TDBadgedCell.h"

#import "UIView+FirstResponder.h"
#import "NSString+JavaStr.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define ITEMSETID_DEFAULT               1000
#define BTN_ID_EDIT_OK                  8001
#define BTN_ID_EDIT_CANCEL              8002




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface GMapSyncViewController() <UITableViewDelegate, UITableViewDataSource,
                                     SyncDataDelegate>


@property (nonatomic, assign) IBOutlet  UILabel *fSyncFeedback;
@property (nonatomic, assign) IBOutlet  UITableView *fMapsTable;

@property (nonatomic, assign)           UILabel *titleBar;
@property (nonatomic, assign)           ScrollableToolbar *scrollableToolbar;

@property (nonatomic, strong)           TCloseCallback closeCallback;
@property (nonatomic, strong)           SyncDataService *syncService;

@property (nonatomic, strong)           NSManagedObjectContext *moContext;
@property (nonatomic, strong)           NSManagedObjectContext *moAsyncChildContext;

@property (nonatomic, strong)           NSArray *compTuples;
@property (nonatomic, assign)           NSInteger selectedIndex;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation GMapSyncViewController 




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (GMapSyncViewController *) gmapSyncViewControllerWithContext:(NSManagedObjectContext *)moContext {

    // Crea el editor desde el NIB y lo inicializa con la entidad (y contexto) especificada
    GMapSyncViewController *me = [[GMapSyncViewController alloc] initWithNibName:@"GMapSyncViewController" bundle:nil];
    
    me.moContext = moContext;
    me.moAsyncChildContext = moContext.ChildContextASync;
    me.syncService = [SyncDataService syncDataServiceWithChildContext:me.moAsyncChildContext delegate:me];
    return me;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) showModalWithController:(UIViewController *)controller closeCallback:(TCloseCallback)closeCallback {
    
    self.closeCallback = closeCallback;
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [controller presentViewController:self animated:YES completion:nil];
}




//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Crea la barra de titulo, el scrollView y la de herramientas
    UILabel *titleBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
    titleBar.textAlignment = NSTextAlignmentCenter;
    titleBar.textColor = [UIColor whiteColor];
    titleBar.font = [UIFont boldSystemFontOfSize:18];
    titleBar.text = @"GMaps Synchronization";
    titleBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"breadcrumb-barBg"]];
    [self.view addSubview:titleBar];
    self.titleBar = titleBar;
    
    
    // Crea la barra de herramientas con las opciones por defecto
    ScrollableToolbar *scrollableToolbar = [[ScrollableToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-51, self.view.frame.size.width, 51)];
    [self.view addSubview:scrollableToolbar];
    self.scrollableToolbar = scrollableToolbar;
    
    // Crea el boton de back
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0,5,50,30)];
    [btnBack setImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(_btnCloseBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.scrollableToolbar setItems:[self _tbItemsForToolBar] itemSetID:ITEMSETID_DEFAULT animated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark <PSyncDataDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void) syncFinished:(BOOL)allOK {
    
    // Ya no esta interesado en camnbios del conteto hijo
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.moAsyncChildContext];

    // Graba los cambios que haya habido (lo de GMaps ya esta hecho y no se puede deshacer)
    [self.moContext saveChanges];

    if(allOK) {
        [self _showFeedbackText:@"Synchronization is Done!"];
    } else {
        [self _showFeedbackText:@"Synchronization finished with problems!"];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) willGetRemoteMapList {
    [self _showFeedbackText:@"Getting remote map list info..."];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) didGetRemoteMapList {
    [self _showFeedbackText:@"Getting remote map list info... Done!"];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) willCompareLocalAndRemoteMaps {
    [self _showFeedbackText:@"Comparing local and remote info..."];
}
//---------------------------------------------------------------------------------------------------------------------
- (void) didCompareLocalAndRemoteMaps:(NSArray *)compTuples {
    [self _showFeedbackText:@"Comparing local and remote info...Done!"];
    self.compTuples = compTuples;
    [self.fMapsTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) willSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int)index {
    
    [self _showFeedbackText:[NSString stringWithFormat:@"Synchronizing maps info..."]];
    
    self.selectedIndex = index;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.fMapsTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    NSArray *indexesToRefresh;
    if(index>0) {
        indexesToRefresh = [NSArray arrayWithObjects:indexPath, [NSIndexPath indexPathForItem:index-1 inSection:0], nil];
    } else {
        indexesToRefresh = [NSArray arrayWithObject:indexPath];
    }
    [self.fMapsTable reloadRowsAtIndexPaths:indexesToRefresh withRowAnimation:UITableViewRowAnimationAutomatic];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) didSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int)index syncOK:(BOOL)syncOK{
    
    // Vamos guardando los resultados mapa a mapa
    [self.moContext saveChanges];

    self.selectedIndex = index;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.fMapsTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    NSArray *indexesToRefresh;
    if(index>0) {
        indexesToRefresh = [NSArray arrayWithObjects:indexPath, [NSIndexPath indexPathForItem:index-1 inSection:0], nil];
    } else {
        indexesToRefresh = [NSArray arrayWithObject:indexPath];
    }
    [self.fMapsTable reloadRowsAtIndexPaths:indexesToRefresh withRowAnimation:UITableViewRowAnimationAutomatic];
}





//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Inhibe que las filas se puedan borrar pasando el dedo
    return UITableViewCellEditingStyleNone;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    // No dejamos nada seleccionado
    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.compTuples.count;
}


//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = [indexPath indexAtPosition:1];
    if(self.selectedIndex == index) {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.backgroundColor = [UIColor colorWithRed:0.9333 green:0.9686 blue:0.9922 alpha:1.0];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = [[UIImageView alloc] initWithImage:[self _itemRunStatusImageInTuple:nil]];
    }
    
    
    NSInteger index = [indexPath indexAtPosition:1];
    GMTCompTuple *tuple = (GMTCompTuple*) self.compTuples[index];
    
    cell.textLabel.text = [self _itemNameInTuple:tuple];
    cell.imageView.image = [self _itemStatusImageInTuple:tuple];
    ((UIImageView *)cell.accessoryView).image = [self _itemRunStatusImageInTuple:tuple];

    
    return cell;
}





//=====================================================================================================================
#pragma mark -
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseBack:(id)sender {
    
    // No se puede salir por las buenas?????
    // Cancela lo que haya en curso
    if(self.syncService.isRunning) {
        [self _cancelSync:nil];
    } else {
        [self _dismissController];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) myManagedObjectContextDidSaveNotificationHander:(NSNotification *)notification {

    // Mezcla los cambios al contexto padre en el main_queue_thread
    [self.moAsyncChildContext.parentContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                                             withObject:notification
                                                          waitUntilDone:YES];

}

//---------------------------------------------------------------------------------------------------------------------
- (void) _startSync:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myManagedObjectContextDidSaveNotificationHander:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.moAsyncChildContext];
    
    

    // Si no esta en ejecucion lo arranca
    if(!self.syncService.isRunning) {
        self.compTuples = nil;
        [self.fMapsTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.syncService startMapsSync];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _cancelSync:(UIButton *)sender {
    
    // Si esta en ejecucion lo para
    if(self.syncService.isRunning) {
        [self.syncService cancelSync];
        [self _showFeedbackText:@"Waiting for cancelation..."];
    }
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissController {
    
    // Avisa de que se cierra
    if(self.closeCallback!=nil) {
        self.closeCallback();
    }
    
    // Cierra el editor
    [self dismissViewControllerAnimated:YES completion:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _itemNameInTuple:(GMTCompTuple *)tuple {
    return tuple.localItem.name!=nil ? tuple.localItem.name : tuple.remoteItem.name;
}


//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) _itemStatusImageInTuple:(GMTCompTuple *)tuple {
    
    __strong static UIImage *_imgCreateLocal = nil;
    __strong static UIImage *_imgCreateRemote = nil;
    __strong static UIImage *_imgDeleteLocal = nil;
    __strong static UIImage *_imgDeleteRemote = nil;
    __strong static UIImage *_imgUpdateLocal = nil;
    __strong static UIImage *_imgUpdateRemote = nil;
    
    if(_imgCreateLocal==nil) {
        _imgCreateLocal = [UIImage imageNamed:@"syncCreateLocal"];
        _imgCreateRemote = [UIImage imageNamed:@"syncCreateRemote"];
        _imgDeleteLocal = [UIImage imageNamed:@"syncDeleteLocal"];
        _imgDeleteRemote = [UIImage imageNamed:@"syncDeleteRemote"];
        _imgUpdateLocal = [UIImage imageNamed:@"syncUpdateLocal"];
        _imgUpdateRemote = [UIImage imageNamed:@"syncUpdateRemote"];
    }
    
    switch (tuple.compStatus) {
        case ST_Comp_Create_Local:
            return _imgCreateLocal;
            
        case ST_Comp_Create_Remote:
            return _imgCreateRemote;
            
        case ST_Comp_Delete_Local:
            return _imgDeleteLocal;

        case ST_Comp_Delete_Remote:
            return _imgDeleteRemote;
            
        case ST_Comp_Update_Local:
            return _imgUpdateLocal;

        case ST_Comp_Update_Remote:
            return _imgUpdateRemote;
    }
    
    // No deberia llegar aqui
    return  nil;
}


//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) _itemRunStatusImageInTuple:(GMTCompTuple *)tuple {
    
    __strong static UIImage *_imgNone = nil;
    __strong static UIImage *_imgProcessing = nil;
    __strong static UIImage *_imgOK = nil;
    __strong static UIImage *_imgFailed = nil;
    
    if(_imgProcessing==nil) {
        _imgNone = [UIImage imageNamed:@"syncRunStatusNone"];
        _imgProcessing = [UIImage imageNamed:@"syncRunStatusProcessing"];
        _imgOK = [UIImage imageNamed:@"syncRunStatusOK"];
        _imgFailed = [UIImage imageNamed:@"syncRunStatusFailed"];
    }
    
    switch (tuple.runStatus) {
        case ST_Run_None:
            return _imgNone;
            
        case ST_Run_Processing:
            return _imgProcessing;
            
        case ST_Run_OK:
            return _imgOK;
            
        case ST_Run_Failed:
            return _imgFailed;
    }
    
    // No deberia llegar aqui
    return  nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _showFeedbackText:(NSString *)text {
    
    self.fSyncFeedback.text = text;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbItemsForToolBar {
    NSArray *items = [NSArray arrayWithObjects:
                      [STBItem itemWithTitle:@"Cancel" image:[UIImage imageNamed:@"btn-checkCancel"] tagID:BTN_ID_EDIT_CANCEL target:self action:@selector(_cancelSync:)],
                      [STBItem itemWithTitle:@"Sync" image:[UIImage imageNamed:@"btn-checkOK"] tagID:BTN_ID_EDIT_OK target:self action:@selector(_startSync:)],
                      nil];
    
    return items;
}




@end

