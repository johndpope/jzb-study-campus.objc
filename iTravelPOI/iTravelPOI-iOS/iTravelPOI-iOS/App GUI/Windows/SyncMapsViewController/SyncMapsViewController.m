//
//  SyncMapsViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __SyncMapsViewController__IMPL__
#import "SyncMapsViewController.h"
#import "BaseCoreDataService.h"
#import "GMapSyncService.h"
#import "SyncDataSource.h"
#import "KmlBackup.h"
#import "UIImage+Tint.h"
#import "NSString+JavaStr.h"
#import "NSString+HTML.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface SyncMapsViewController () <UITableViewDelegate, UITableViewDataSource, GMPSyncDelegate>

@property (weak, nonatomic) IBOutlet UILabel                *status;
@property (weak, nonatomic) IBOutlet UITableView            *syncTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem        *syncButton;



@property (strong, nonatomic)   NSManagedObjectContext        *moContext;
@property (strong, atomic)      GMapSyncService               *syncService;
@property (strong, atomic)      NSArray                       *compTuples;
@property (strong, atomic)      NSString                      *backupFolder;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation SyncMapsViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (SyncMapsViewController *) SyncMapsViewControllerWithContext:(NSManagedObjectContext *)moContext {
    
    SyncMapsViewController *me = nil;
    me.moContext = moContext;
    return me;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    // Do any additional setup after loading the view from its nib.
    if(self.moContext==nil) {
        self.moContext = BaseCoreDataService.moContext;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"MapList_to_PointsList"]) {
        
    }
    
}



//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)syncMapsAction:(UIBarButtonItem *)sender {
    if(!self.syncService)
        [self _startSyncMaps];
    else
        [self _cancelSyncMaps];
}




//=====================================================================================================================
#pragma mark -
#pragma mark <GMPSyncDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) shouldProcessTuple:(GMTCompTuple *)tuple error:(NSError * __autoreleasing *)err {

    BOOL wasOK;
    
    // De momento no hay error
    *err = nil;

    
    MMap *localMap = (MMap *)tuple.localItem;
    GMTMap *remoteMap = (GMTMap *)tuple.remoteItem;

    
    // Si no tenemos un folder de backup lo prepara
    if(!self.backupFolder) {
        [self _setStatus:@"Creating backup folder"];
        self.backupFolder = [KmlBackup backupFolderWithDate:[NSDate date] error:err];
        if(!self.backupFolder || *err!=nil) {
            [self _setStatus:@"Error creating backup folder!"];
            return FALSE;
        }
    }

    // Antes de procesar un mapa hacemos un backup
    switch(tuple.compStatus) {

        case ST_Comp_Delete_Local:
            [self _setStatus:@"Backing up local map"];
            wasOK = [KmlBackup backupLocalMap:localMap inFolder:self.backupFolder error:err];
            [self _setStatus:[NSString stringWithFormat:@"Local map backed up %@", (wasOK?@"OK":@"with ERROR")]];
            break;
            
        case ST_Comp_Delete_Remote:
            [self _setStatus:@"Backing up remote map"];
            wasOK = [KmlBackup backupRemoteMap:remoteMap inFolder:self.backupFolder error:err];
            [self _setStatus:[NSString stringWithFormat:@"Remote map backed up %@", (wasOK?@"OK":@"with ERROR")]];
            break;
            
        case ST_Comp_Update_Local:
        case ST_Comp_Update_Remote:
            [self _setStatus:@"Backing up remote map"];
            wasOK = [KmlBackup backupRemoteMap:remoteMap inFolder:self.backupFolder error:err];
            if(wasOK && !*err) {
                [self _setStatus:@"Backing up local map"];
                wasOK = [KmlBackup backupLocalMap:localMap inFolder:self.backupFolder error:err];
                [self _setStatus:[NSString stringWithFormat:@"Local map backed up %@", (wasOK?@"OK":@"with ERROR")]];
            } else {
                [self _setStatus:[NSString stringWithFormat:@"Remote map backed up %@", (wasOK?@"OK":@"with ERROR")]];
            }
            break;
            
        default:
            wasOK = TRUE;
            break;
    }
    
    return wasOK;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) syncFinished:(BOOL)wasAllOK {
    
    if(wasAllOK) {
        [self _setStatus:@"Synchronization is done!"];
    } else {
        [self _setStatus:@"Synchronization finished with ERROR!"];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) willGetRemoteMapList {
    [self _setStatus:@"Requesing remote map list"];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) didGetRemoteMapList {
    [self _setStatus:@"Remote map list received"];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) willCompareLocalAndRemoteMaps {
    [self _setStatus:@"Comparing local and remote maps"];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) didCompareLocalAndRemoteMaps:(NSArray *)compTuples {
    [self _setStatus:@"Local and remote maps were compared"];
    self.compTuples = compTuples;
    [self _reloadTableData];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) willSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int)index {
    
    NSString *text = [NSString stringWithFormat:@"Synchronizing map: '%@'", [self _mapNameFromTuple:tuple]];
    [self _setStatus:text];
    [self _reloadTableRow:index done:FALSE];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) didSyncMapTuple:(GMTCompTuple *)tuple withIndex:(int)index syncOK:(BOOL)syncOK {
    
    NSString *text = [NSString stringWithFormat:@"Map '%@' synchronized %@", [self _mapNameFromTuple:tuple], (syncOK?@"":@"with ERRORS")];
    [self _setStatus:text];
    [self _reloadTableRow:index done:TRUE];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    static UIColor *runningBkgnd = nil;
    if(!runningBkgnd) runningBkgnd = [UIColor colorWithIntRed:230 intGreen:245 intBlue:255 alpha:1.0];
    
    GMTCompTuple *tuple = self.compTuples[[indexPath indexAtPosition:1]];
    cell.textLabel.text = [self _mapNameFromTuple:tuple];
    cell.textLabel.textColor = [self _runningStatusColorFromTuple:tuple];
    cell.imageView.image = [self _compStatusIconFromTuple:tuple];
    cell.backgroundColor = tuple.runStatus==ST_Run_Processing ? runningBkgnd : [UIColor whiteColor];
    
    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _mapNameFromTuple:(GMTCompTuple *)tuple {
    if(tuple.remoteItem.name) return tuple.remoteItem.name;
    if(tuple.localItem.name) return tuple.localItem.name;
    return @"<unknown>";
}

//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) _compStatusIconFromTuple:(GMTCompTuple *)tuple {
    
    static __strong UIImage *imgSynAdd = nil;
    static __strong UIImage *imgSynRemove = nil;
    static __strong UIImage *imgSynUpdate = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        imgSynAdd = [UIImage imageNamed:@"sync-add" burnTintRed:108 green:162 blue:9 alpha:1.0];
        imgSynRemove = [UIImage imageNamed:@"sync-delete" burnTintRed:178 green:60 blue:63 alpha:1.0];
        imgSynUpdate = [UIImage imageNamed:@"sync-update" burnTintRed:70 green:134 blue:174 alpha:1.0];
    });
    
    switch(tuple.compStatus) {
        case ST_Comp_Create_Local:
        case ST_Comp_Create_Remote:
            return imgSynAdd;
        case ST_Comp_Delete_Local:
        case ST_Comp_Delete_Remote:
            return imgSynRemove;
        case ST_Comp_Update_Local:
        case ST_Comp_Update_Remote:
            return imgSynUpdate;
    }
    
    // NO debería llegar aqui
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (UIColor *) _runningStatusColorFromTuple:(GMTCompTuple *)tuple {
    
    static __strong UIColor *colorStatusNone = nil;
    static __strong UIColor *colorStatusRunning = nil;
    static __strong UIColor *colorStatusOK = nil;
    static __strong UIColor *colorStatusError = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        colorStatusNone = [UIColor colorWithIntRed:180 intGreen:180 intBlue:180 alpha:1.0];
        colorStatusRunning = [UIColor colorWithIntRed:70 intGreen:134 intBlue:174 alpha:1.0];
        colorStatusOK = [UIColor colorWithIntRed:108 intGreen:162 intBlue:9 alpha:1.0];
        colorStatusError = [UIColor colorWithIntRed:178 intGreen:60 intBlue:63 alpha:1.0];
    });

    switch(tuple.runStatus) {
        case ST_Run_None:
            return colorStatusNone;
        case ST_Run_Processing:
            return colorStatusRunning;
        case ST_Run_OK:
            return colorStatusOK;
        case ST_Run_Failed:
            return colorStatusError;
    }
    
    // NO debería llegar aqui
    return nil;

}

//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) _runningStatusIconFromTuple:(GMTCompTuple *)tuple {
    
    static __strong UIImage *imgStatusRunning = nil;
    static __strong UIImage *imgStatusOK = nil;
    static __strong UIImage *imgStatusError = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        imgStatusRunning = [UIImage imageNamed:@"sync-add" burnTintRed:185 green:239 blue:86 alpha:1.0];
        imgStatusOK = [UIImage imageNamed:@"sync-remove" burnTintRed:255 green:137 blue:140 alpha:1.0];
        imgStatusError = [UIImage imageNamed:@"sync-update" burnTintRed:147 green:211 blue:251 alpha:1.0];
    });
    
    switch(tuple.runStatus) {
        case ST_Run_None:
            return nil;
        case ST_Run_Processing:
            return imgStatusRunning;
        case ST_Run_OK:
            return imgStatusOK;
        case ST_Run_Failed:
            return imgStatusError;
    }
    
    // NO debería llegar aqui
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setStatus:(NSString *)text {

    dispatch_async(dispatch_get_main_queue(), ^{
        self.status.text = [NSString stringWithFormat:@"  %@", text];
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _reloadTableData {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.syncTable reloadData];
    });
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _reloadTableRow:(NSUInteger)index done:(BOOL)done{
    
    // Lo hacemos sincrono para que no se continue hasta que la tabla refleje bien el estado de sincronizacion
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if(done) {
            [self.syncTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        }
        [self.syncTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        self.syncButton.title = [NSString stringWithFormat:@"Cancel [%td/%td]",index, self.compTuples.count];
    });
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _cancelSyncMaps {
    
    [self.syncService cancelSync];
    self.syncButton.enabled = NO;
    self.syncButton.title = @"Canceling";
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _startSyncMaps {
    
    self.compTuples = nil;
    [self.syncTable reloadData];
    self.status.text = @"";
    self.syncButton.title = @"Cancel";
    self.syncButton.tintColor = [UIColor redColor];
    
    // Cada sincronizacio debe contar con su propia carpeta de backup
    self.backupFolder = nil;
    
    NSManagedObjectContext *moAsyncChildContext = [BaseCoreDataService childContextASyncFor:self.moContext];
    [moAsyncChildContext performBlock:^{
        
        SyncDataSource *syncDataSource = [[SyncDataSource alloc] init];
        syncDataSource.moContext = moAsyncChildContext;
        
        [self _setStatus:@"Connecting and login into Google Maps service"];
        
        NSString *email = @"jzarzuela@gmail.com";
        NSString *pwd = @"#webweb1971";
        NSError *error = nil;
        BOOL wasAllOK = TRUE;
        
        self.syncService = [GMapSyncService serviceWithEmail:email password:pwd dataSource:syncDataSource delegate:self error:&error];
        if(self.syncService!=nil && error==nil) {
            [self _setStatus:@"Starting map list synchronization"];
            wasAllOK = [self.syncService syncMaps:&error];
        }
        
        // Graba lo que se haya podido sincronizar sin problemas
        [BaseCoreDataService saveChangesInContext:moAsyncChildContext];
        [BaseCoreDataService saveChangesInContext:moAsyncChildContext.parentContext];
        
        // Deja el mensaje final de estado
        [self syncFinished:(self.syncService!=nil && error==nil && wasAllOK==TRUE)];
        
        // Da por finalizada la sincronizacion
        self.syncService = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.syncButton.title = @"Start";
            self.syncButton.tintColor = self.view.tintColor;
            self.syncButton.enabled = YES;
        });

    }];
    
    
}


@end
