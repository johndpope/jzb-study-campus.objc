//
//  GeneralConfigController.m
//  iTravelPOI
//
//  Created by JZarzuela on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeneralConfigController.h"

#import "SyncService.h"
#import "ModelService.h"
#import "MEComparer.h"
#import "MEBaseEntity.h"

#import "SVProgressHUD.h"
#import "TDBadgedCell.h"
#import "WEPopoverController.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark GeneralConfigController PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GeneralConfigController()

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *syncButton;

@property (nonatomic, readonly) NSManagedObjectContext *moContext;
@property (nonatomic, retain)   NSMutableArray *compItems;


- (void) loadCompMapsListData;
- (void) syncMapsListData;

- (void) showErrorToUser:(NSString *)errorMsg;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark GeneralConfigController implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation GeneralConfigController
@synthesize tableView = _tableView;
@synthesize syncButton = _syncButton;

@synthesize moContext = _moContext;
@synthesize compItems = _compItems;



//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_moContext release];
    [_compItems release];

    [_tableView release];
    [_syncButton release];
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectContext *) moContext {
    if(!_moContext) {
        _moContext = [[ModelService sharedInstance] initContext];
    }
    return _moContext;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark View lifecycle
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [_moContext release];
    _moContext = nil;
    self.compItems = nil;
    
    [self setTableView:nil];
    [self setSyncButton:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Si no estan cargados los items de comparacion de una iteracion previa los volvemos a cargar
    if(!self.compItems) {
        [self loadCompMapsListData];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark Internal Event Handlers
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)syncButtonAction:(UIButton *)sender {
    
    [self syncMapsListData];
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark SortOptionsController delegate
//---------------------------------------------------------------------------------------------------------------------


//*********************************************************************************************************************
#pragma mark -
#pragma mark Table view data source
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.compItems count];
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *compItemViewIdentifier = @"CompItemCellView";
    
    MECompareTuple *tuple = [self.compItems objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:compItemViewIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:compItemViewIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    MEMap *map = (MEMap *)(tuple.localEntity ? tuple.localEntity : tuple.remoteEntity);
    cell.textLabel.text = map.name;
    cell.detailTextLabel.text = SyncStatusType_Names[tuple.syncStatus];//map.desc;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;	
    cell.imageView.image = map.icon.image;
    
    return cell;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.compItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Table view data delegate
//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    //    [self showMapEditorFor:[self.maps objectAtIndex:indexPath.row]];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    MEMap *map = [self.maps objectAtIndex:indexPath.row];
    //    [self showPointListControllerForMap:map];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (void) loadCompMapsListData {
    
    // Pone un indicador de actividad
    /*
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem.customView = activityIndicator;
    [activityIndicator startAnimating];
    [activityIndicator release];
    */
    
    // Calcula la información con los cambios en los mapas
    [[SyncService sharedInstance] compareMapsInCtx:self.moContext callback:^(NSMutableArray *compItems, NSError *error) {
        
        // Paramos el indicador de actividad
        /*
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
        [activityIndicator stopAnimating];
        */
        
        // Si hay un error lo indica. En otro caso, recarga la tabla con la informacion
        if(error) {
            [self showErrorToUser:@"Error loading local maps"];
        } else {
            //self.navigationItem.rightBarButtonItem.customView = nil;
            
            // Algoritmo de comparacion para ordenar los elementos segun el nombre
            NSComparator comparator = ^NSComparisonResult(id obj1, id obj2) {
                MECompareTuple *ct1 = obj1;
                MECompareTuple *ct2 = obj2;
                NSString *name1 = ct1.localEntity ? ct1.localEntity.name : ct1.remoteEntity.name;
                NSString *name2 = ct2.localEntity ? ct2.localEntity.name : ct2.remoteEntity.name;
                return [name1 compare:name2];
            };
            
            // Ordena y refresca la tabla
            self.compItems = [NSMutableArray arrayWithArray:[compItems sortedArrayUsingComparator:comparator]];
            [self.tableView reloadData];
        }
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) syncMapsListData {
    
    // Pone un indicador de actividad
    /*
     UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
     self.navigationItem.rightBarButtonItem.customView = activityIndicator;
     [activityIndicator startAnimating];
     [activityIndicator release];
     */
    
    // Sincroniza la información con los cambios en los mapas
    [[SyncService sharedInstance] syncMapsInCtx:self.moContext compItems:self.compItems callback:^(NSError *error) {
        
        // Paramos el indicador de actividad
        /*
         UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
         [activityIndicator stopAnimating];
         */
        
        // Si hay un error lo indica. En otro caso, recarga la tabla con la informacion
        if(error) {
            [self showErrorToUser:@"Error loading local maps"];
        } else {
            //self.navigationItem.rightBarButtonItem.customView = nil;

            // Manda volver a calcular si hay cambios????
            [self loadCompMapsListData];
        }
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) showErrorToUser:(NSString *)errorMsg {
    [SVProgressHUD showWithStatus:@""];
    [SVProgressHUD dismissWithError:errorMsg afterDelay:2];
}
@end
