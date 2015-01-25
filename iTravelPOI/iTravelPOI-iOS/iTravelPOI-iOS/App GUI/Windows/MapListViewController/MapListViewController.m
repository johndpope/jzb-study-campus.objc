//
//  MapListViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __MapListViewController__IMPL__
#import "MapListViewController.h"
#import "BaseCoreDataService.h"
#import "PointsViewController.h"
#import "UINavigationPopProtocol.h"
#import "KmlBackup.h"
#import "KMLReader.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define PREVIOUS_SHOWN_MAP_URI_ID   @"previousShownMapUriID"



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MapListViewController () <UINavigationPopProtocol, UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UIBarButtonItem    *revealButtonItem;
@property (weak, nonatomic) IBOutlet UITableView        *tableViewItemList;

@property (strong, nonatomic) NSManagedObjectContext    *moContext;
@property (strong, nonatomic) NSArray                   *mapList;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MapListViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------


//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)importKLMs:(UIBarButtonItem *)sender {
    
    // Primero hacemos una copia de seguridad
    [self exportKLMs:sender];
    
    // Importamos lo que haya
    [KMLReader importKmlFiles];
    self.mapList = [MMap allMapsinContext:self.moContext includeMarkedAsDeleted:FALSE];
    [self.tableViewItemList reloadData];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)exportKLMs:(UIBarButtonItem *)sender {
    
    BOOL wasOK = TRUE;
    NSError *err = nil;
    
    
    NSString *backupFolder;
    backupFolder = [KmlBackup backupFolderWithDate:[NSDate date] error:&err];
    if(!backupFolder || err!=nil) {
        wasOK = FALSE;
    } else {
        NSArray *allMaps = [MMap allMapsinContext:BaseCoreDataService.moContext includeMarkedAsDeleted:FALSE];
        for(MMap *localMap in allMaps) {
            wasOK &= [KmlBackup backupLocalMap:localMap inFolder:backupFolder error:&err];
        }
    }
    
    if(!wasOK) {
        UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Backup error"
                                                            message: @"Error creating maps backups"
                                                           delegate: nil
                                                  cancelButtonTitle: @"Ok"
                                                  otherButtonTitles: nil];
        [someError show];
    }

}


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
    
    self.mapList = [MMap allMapsinContext:self.moContext includeMarkedAsDeleted:FALSE];
    [self.tableViewItemList reloadData];

    
    // Antes de termina de mostrarse comprueba si debe auto-activar el mostrar un mapa
    [self _restorePreviousShownMap];
    
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
        
        if([segue.destinationViewController isKindOfClass:[PointsViewController class]]) {
            
            MMap *map = (MMap *)sender;
            PointsViewController *poiList = (PointsViewController *)segue.destinationViewController;
            poiList.map = map;
            
            // Recuerda que esta mostrando este mapa
            [self _savePreviousShownMap:map];
        }
    }
    
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UINavigationPopProtocol> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void) poppedFromVC:(UIViewController *)controller {
    
    // Recuerda que ya no se esta mostrando ningun mapa en concreto
    [self _removePreviousShownMap];
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
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    

}

//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Un cambio del mapa implica resetear el filtro
    MMap *map = [self _mapAtIndex:[indexPath indexAtPosition:1]];
    [self performSegueWithIdentifier: @"MapList_to_PointsList" sender: map];

    // No dejamos nada seleccionado
    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + self.mapList.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    
    MMap *mapToShow = (MMap *)[self _mapAtIndex:[indexPath indexAtPosition:1]];
    if(!mapToShow) {
        cell.textLabel.text = @"[* Any map *]";
    } else {
        cell.textLabel.text = mapToShow.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d points",(int)mapToShow.pointsCount];
    }

    
    /*
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    
    MBaseEntity *itemToShow = (MBaseEntity *)[self.itemLists objectAtIndex:[indexPath indexAtPosition:1]];
    
    cell.textLabel.text=itemToShow.name;
    cell.imageView.image = itemToShow.entityImage;
    
    if(itemToShow.entityType == MET_POINT) {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text=@" ";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.badgeString=nil;
    } else {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.detailTextLabel.text=@"";
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        if (itemToShow.entityType == MET_MAP) {
            cell.badgeString=[(MMap*)itemToShow strViewCount];
        } else {
            cell.badgeString=[(MCategory*)itemToShow strViewCountForMap:self.selectedMap];
        }
    }
    
    if(tableView.isEditing) {
        [self _setLeftCheckStatusFor:itemToShow cell:cell];
    }
    */
    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (MMap *) _mapAtIndex:(NSUInteger)index {
    
    return index==0?nil:self.mapList[index-1];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _savePreviousShownMap:(MMap *)map {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:map.objectID.URIRepresentation.absoluteString forKey:PREVIOUS_SHOWN_MAP_URI_ID];
    [userDefaults synchronize];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _removePreviousShownMap {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:PREVIOUS_SHOWN_MAP_URI_ID];
    [userDefaults synchronize];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _restorePreviousShownMap {
    
    // Comprueba si se cerro la aplicacion cuando se estaba mostrando un mapa para seguir con el
    NSString *uriObjId = [[NSUserDefaults standardUserDefaults] objectForKey:PREVIOUS_SHOWN_MAP_URI_ID];
    if(uriObjId) {
        NSManagedObjectID *mapID = [self.moContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:uriObjId]];
        if(mapID) {
            MMap *prevSelMap = (MMap *)[self.moContext objectWithID:mapID];
            if(prevSelMap) {
                [self performSegueWithIdentifier: @"MapList_to_PointsList" sender: prevSelMap];
            }
        }
    }
    
}


@end
