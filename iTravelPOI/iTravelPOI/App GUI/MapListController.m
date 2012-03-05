//
//  MapListController.m
//  iTravelPOI
//
//  Created by jzarzuela on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MapListController.h"
#import "ModelService.h"
#import "PointListController.h"
#import "IconEditor.h"
#import "SVProgressHUD.h"
#import "TDBadgedCell.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark MapListController PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MapListController()

@property (nonatomic, retain) IBOutlet UITableView *mapTableView;

@property (nonatomic, readonly) NSManagedObjectContext *moContext;
@property (nonatomic, retain)   NSArray *maps;

- (IBAction) createAndEditMapAction:(id)sender;
- (void) loadMapListData;
- (void) showMapEditorFor:(MEMap *)mapToView;
- (void) showErrorToUser:(NSString *)errorMsg;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MapListController implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MapListController


@synthesize mapTableView = _mapTableView;

@synthesize moContext = _moContext;
@synthesize maps = _maps;



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
    [_maps release];
    [_moContext release];
    
    [_mapTableView release];
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Inicializa el resto de la vista
    self.title = @"Maps";
    
    // Creamos el boton para crear o editar mapas
    UIBarButtonItem *createMapBtn = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
                                                                                   target:self 
                                                                                   action:@selector(createAndEditMapAction:)];
    self.navigationItem.rightBarButtonItem=createMapBtn;
    [createMapBtn release];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    self.mapTableView = nil;
    self.maps = nil;
    [_moContext release];
    _moContext = nil;
    
    [super viewDidUnload];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Si no tenemos los mapas de una iteracion previa los cargamos
    if(!self.maps) {
        [self loadMapListData];
    }
    
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
- (IBAction) createAndEditMapAction:(id)sender {
    
    [self showMapEditorFor:nil];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark MapEditor delegate
//---------------------------------------------------------------------------------------------------------------------
- (MEMap *) mapEditorCreateMapInstance {
    NSLog(@"mapEditorCreateMapInstance");
    return [MEMap insertNew:self.moContext];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) mapEditorSave:(MapEditorController *)sender map:(MEMap *)map {
    
    NSLog(@"mapEditorSave");
    
    [self.navigationController popViewControllerAnimated:true];
    
    // Marca el mapa como modificado
    map.changed = true;
    
    // Almacena los cambios
    NSError *error = [map commitChanges];
    if(error) {
        [self showErrorToUser:@"Error saving local maps"];
    }
    
    // Se recarga entera por si hubo un cambio de nombre y afecta al orden
    [self loadMapListData];
}



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
    return [self.maps count];
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *mapViewIdentifier = @"MapCellView";
    
    MEMap *map = [self.maps objectAtIndex:indexPath.row];
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:mapViewIdentifier];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mapViewIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    cell.textLabel.text = map.name;
    cell.detailTextLabel.text = map.desc;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;	
    cell.badgeString = [NSString stringWithFormat:@"%03u", [map.points count]];
    //cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
    cell.badgeColor = [UIColor colorWithRed:0.197 green:0.592 blue:0.219 alpha:1.000];
    cell.badge.radius = 9;
    
    cell.imageView.image = map.gmapIcon.image;
    
    return cell;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *marray = [NSMutableArray arrayWithArray:self.maps];
        [marray removeObjectAtIndex:indexPath.row];
        self.maps = [[marray copy] autorelease];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        MEMap *map = [self.maps objectAtIndex:indexPath.row];
        [map markAsDeleted];
        NSError *error = [map commitChanges];
        if(error) {
            NSLog(@"Error saving context when deleting an item: %@ / %@", error, [error userInfo]);
            [self showErrorToUser:@"Error deleting map"];
        }
        
    }   
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Table view data source
//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    [self showMapEditorFor:[self.maps objectAtIndex:indexPath.row]];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MEMap *map = [self.maps objectAtIndex:indexPath.row];
    NSManagedObjectContext *ctx = [[ModelService sharedInstance] initContext];
    MEMap *mapToView = (MEMap *)[ctx objectWithID:[map objectID]];
    
    PointListController *pointListController = [[PointListController alloc] initWithNibName:@"PointListController" bundle:nil];
    pointListController.map = mapToView;
    pointListController.filteringCategories = nil;
    [self.navigationController pushViewController:pointListController animated:YES];
    [pointListController release];
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (void) loadMapListData {
    
    // Pone un indicador de actividad
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem.customView = activityIndicator;
    [activityIndicator startAnimating];
    [activityIndicator release];
    
    // Lanzamos la carga de los mapas
    [[ModelService sharedInstance] getUserMapList:self.moContext callback:^(NSArray *maps, NSError *error) {
        
        // Paramos el indicador de actividad
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
        [activityIndicator stopAnimating];
        
        // Si hay un error lo indica. En otro caso, recarga la tabla con los mapas
        if(error) {
            [self showErrorToUser:@"Error loading local maps"];
        } else {
            self.navigationItem.rightBarButtonItem.customView = nil;
            self.maps = maps;
            [self.mapTableView reloadData];
        }
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) showMapEditorFor:(MEMap *)mapToView {
    
    MapEditorController *mapEditor = [[MapEditorController alloc] initWithNibName:@"MapEditorController" bundle:nil];
    mapEditor.delegate = self;
    mapEditor.map = mapToView;
    mapEditor.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController pushViewController:mapEditor animated:YES];
    [mapEditor release];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) showErrorToUser:(NSString *)errorMsg {
    [SVProgressHUD showWithStatus:@""];
    [SVProgressHUD dismissWithError:errorMsg afterDelay:2];
}

@end
