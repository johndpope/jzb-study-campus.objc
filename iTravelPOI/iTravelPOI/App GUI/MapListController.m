//
//  MapListController.m
//  iTravelPOI
//
//  Created by jzarzuela on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MapListController.h"
#import "ModelService.h"
#import "MEBaseEntity.h"

#import "PointListController.h"
#import "SortOptionsController.h"
#import "GeneralConfigController.h"

#import "SVProgressHUD.h"
#import "TDBadgedCell.h"
#import "WEPopoverController.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark MapListController PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MapListController() <MapEditorDelegate, SortOptionsControllerDelegate>

@property (nonatomic, retain) IBOutlet UITableView *mapTableView;
@property (retain, nonatomic) IBOutlet UIButton *configButton;
@property (retain, nonatomic) IBOutlet UIButton *sortMethodButton;
@property (retain, nonatomic) IBOutlet UIButton *sortOrderButton;


@property (nonatomic, retain)   NSArray *maps;
@property (nonatomic, assign)   ME_SORTING_METHOD sortedBy;
@property (nonatomic, assign)   ME_SORTING_ORDER  sortOrder;


@property (nonatomic, retain) WEPopoverController *sortMapPopover;



- (IBAction) createAndEditMapAction:(id)sender;
- (void) modelHasChanged:(NSNotification *)notification;

- (void) loadMapListData;
- (void) showPointListControllerForMap:(MEMap *)mapToView;
- (void) showMapEditorFor:(MEMap *)mapToView;
- (void) showConfigWindow;
- (void) showErrorToUser:(NSString *)errorMsg;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MapListController implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MapListController


@synthesize configButton = _configButton;
@synthesize sortOrderButton = _sortOrderButton;
@synthesize sortMethodButton = _sortMethodButton;
@synthesize sortOrder = _sortOrder;


@synthesize mapTableView = _mapTableView;

@synthesize maps = _maps;
@synthesize sortedBy = _sortedBy;


@synthesize sortMapPopover = _sortMapPopover;



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
    
    [_sortMapPopover release];
    
    [_mapTableView release];
    [_sortOrderButton release];
    [_sortMethodButton release];
    
    [_configButton release];
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
    
    // Se registra para saber si hubo cambios en el modelo desde otros ViewControllers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelHasChanged:) name:@"ModelHasChangedNotification" object:nil];
    
    // Pone el orden por defecto de la lista
    self.sortedBy = ME_SORT_BY_NAME;
    self.sortOrder = ME_SORT_ASCENDING;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    self.mapTableView = nil;
    [self setSortOrderButton:nil];
    [self setSortMethodButton:nil];
    
    self.maps = nil;
    self.sortMapPopover = nil;
    
    // Se deregistra de las notificaciones
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    [self setConfigButton:nil];
    [super viewDidUnload];
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
    
    // Si no estan cargados los mapas de una iteracion previa los volvemos a cargar
    if(!self.maps) {
        [self loadMapListData];
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
- (IBAction) createAndEditMapAction:(id)sender {
    
    [self showMapEditorFor:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) modelHasChanged:(NSNotification *)notification {
    
    // Puesto que el contenido del modelo ha cambiado deberiamos invalidar lo que se esta mostrando y pedirlo de nuevo
    // ¿Que pasa si se llama cuando no estamos en pantalla?
    // ¿Que pasa si se pone a "nul" y si esta en pantalla?
    
    // self.maps = nil;
    // [self loadMapListData];
    NSLog(@"modelHasChanged");
    self.maps=nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)configButtonAction:(UIButton *)sender {
    [self showConfigWindow];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)sortOrderButtonAction:(UIButton *)sender {
    
    self.sortOrder = (self.sortOrder==ME_SORT_ASCENDING ? ME_SORT_DESCENDING : ME_SORT_ASCENDING);
    
    UIImage *img = nil;
    switch (self.sortOrder) {
        case ME_SORT_ASCENDING:
            img = [UIImage imageNamed:@"sortAscending.png"];
            break;
            
        case ME_SORT_DESCENDING:
            img = [UIImage imageNamed:@"sortDescending.png"];
            break;
            
    }
    [self.sortOrderButton setImage:img forState:UIControlStateNormal];
    [self loadMapListData];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)sortMapPopoverAction:(UIButton *)sender {
    
    // El tamaño debe ser, como minimo, de 16x28 para que se vea bien el popover
    if (self.sortMapPopover && self.sortMapPopover.popoverVisible) {
        [self.sortMapPopover dismissPopoverAnimated:NO];
        self.sortMapPopover = nil;
    } else {
        
        if(!self.sortMapPopover) {
            
            SortOptionsController *sortOptionsController = [[SortOptionsController alloc] initWithNibName:@"SortOptionsController" bundle:nil];
            sortOptionsController.delegate = self;
            
            self.sortMapPopover = [[[WEPopoverController alloc] initWithContentViewController:sortOptionsController] autorelease];
            self.sortMapPopover.containerViewProperties = [self.sortMapPopover improvedContainerViewProperties];
            
            self.sortMapPopover.popoverContentSize = sortOptionsController.view.frame.size;
            
            [sortOptionsController release];
        }
        
        CGRect btnFrame = {self.view.frame.size.width/2-25, self.mapTableView.frame.origin.y + self.mapTableView.frame.size.height, 50, 1};
        [self.sortMapPopover presentPopoverFromRect:btnFrame 
                                             inView:self.view 
                           permittedArrowDirections:UIPopoverArrowDirectionDown
                                           animated:NO];
    }
    
    
    
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark SortOptionsController delegate
//---------------------------------------------------------------------------------------------------------------------
- (void) sortMethodSelected:(ME_SORTING_METHOD)sortedBy {
    
    [self.sortMapPopover dismissPopoverAnimated:NO];
    self.sortMapPopover = nil;
    
    if(self.sortedBy!=sortedBy) {
        UIImage *img = nil;
        switch (sortedBy) {
            case ME_SORT_BY_NAME:
                img = [UIImage imageNamed:@"alphabeticSortIcon.png"];
                break;
                
            case ME_SORT_BY_CREATING_DATE:
                img = [UIImage imageNamed:@"createdSortIcon.png"];
                break;
                
            case ME_SORT_BY_UPDATING_DATE:
                img = [UIImage imageNamed:@"modifiedSortIcon.png"];
                break;
        }
        [self.sortMethodButton setImage:img forState:UIControlStateNormal];
        
        self.sortedBy = sortedBy;
        [self loadMapListData];
    }
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark MapEditor delegate
//---------------------------------------------------------------------------------------------------------------------
- (MEMap *) mapEditorCreateMapInstance {
    NSLog(@"mapEditorCreateMapInstance");
    return [MEMap map];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) mapEditorSave:(MapEditorController *)sender map:(MEMap *)map {
    
    NSLog(@"mapEditorSave");
    
    // Marca el mapa como modificado
    map.changed = true;
    
    // Almacena los cambios
    NSError *error = [map commitChanges];
    if(error) {
        [self showErrorToUser:@"Error saving map info"];
    }
    
    // Se recarga entera por si hubo un cambio de nombre y afecta al orden
    // YA NO HACE FALTA PORQUE LA NOTIFICACION DE CAMBIO HABRA BORRADO LA LISTA DE MAPAS
    //[self loadMapListData];

    // Sale de la pantalla de edicion
    [self.navigationController popViewControllerAnimated:true];
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
    
    cell.imageView.image = map.icon.image;
    
    return cell;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MEMap *mapToRemove = [self.maps objectAtIndex:indexPath.row];
        
        NSMutableArray *marray = [NSMutableArray arrayWithArray:self.maps];
        [marray removeObjectAtIndex:indexPath.row];
        self.maps = [[marray copy] autorelease];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [mapToRemove markAsDeleted];
        NSError *error = [mapToRemove commitChanges];
        if(error) {
            NSLog(@"Error saving context when deleting an item: %@ / %@", error, [error userInfo]);
            [self showErrorToUser:@"Error deleting map"];
        }
        
    }   
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Table view data delegate
//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    [self showMapEditorFor:[self.maps objectAtIndex:indexPath.row]];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MEMap *map = [self.maps objectAtIndex:indexPath.row];
    [self showPointListControllerForMap:map];
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
    [[ModelService sharedInstance] asyncGetUserMapList:^(NSArray *maps, NSError *error) {
        
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
- (void) showPointListControllerForMap:(MEMap *)mapToView {
    
    PointListController *pointListController = [[PointListController alloc] initWithNibName:@"PointListController" bundle:nil];
    pointListController.map = mapToView;
    pointListController.filteringCategories = nil;
    [self.navigationController pushViewController:pointListController animated:YES];
    [pointListController release];

}

//---------------------------------------------------------------------------------------------------------------------
- (void) showMapEditorFor:(MEMap *)mapToView {
    
    MapEditorController *mapEditor = [[MapEditorController alloc] initWithNibName:@"MapEditorController" bundle:nil];
    mapEditor.delegate = self;
    mapEditor.map = mapToView;
    [self.navigationController pushViewController:mapEditor animated:YES];
    [mapEditor release];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) showConfigWindow {
    
    GeneralConfigController *configWindow = [[GeneralConfigController alloc] initWithNibName:@"GeneralConfigController" bundle:nil];
    //configWindow.delegate = self;
    [self.navigationController pushViewController:configWindow animated:YES];
    [configWindow release];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) showErrorToUser:(NSString *)errorMsg {
    [SVProgressHUD showWithStatus:@""];
    [SVProgressHUD dismissWithError:errorMsg afterDelay:2];
}

@end
