//
//  PointListController.m
//  iTravelPOI
//
//  Created by JZarzuela on 11/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PointListController.h"
#import "SortOptionsController.h"
#import "ModelService.h"
#import "SVProgressHUD.h"
#import "TDBadgedCell.h"
#import "WEPopoverController.h"
#import "PointCatEditorController.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark PointListController PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface PointListController() <SortOptionsControllerDelegate, PointCatEditorDelegate>

@property (retain, nonatomic) IBOutlet UITableView *itemsTableView;
@property (retain, nonatomic) IBOutlet UIButton *sortMethodButton;
@property (retain, nonatomic) IBOutlet UIButton *sortOrderButton;

@property (nonatomic, retain) WEPopoverController *sortMapPopover;

@property (nonatomic, assign)   SORTING_METHOD sortedBy;
@property (nonatomic, assign)   SORTING_ORDER  sortOrder;

@property (nonatomic, retain) NSArray *mapItems;


- (IBAction) createAndEditItemAction:(id)sender;
- (void) modelHasChanged:(NSNotification *)notification;


- (void) loadMapItemsListData;
- (void) showMapItemEditorFor:(MEBaseEntity *)entityToView;
- (void) showErrorToUser:(NSString *)errorMsg;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark PointListController implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation PointListController


@synthesize itemsTableView = _itemsTableView;
@synthesize sortMethodButton = _sortMethodButton;
@synthesize sortOrderButton = _sortOrderButton;

@synthesize map = _map;
@synthesize filteringCategories = _filteringCategories;
@synthesize showMode = _showMode;

@synthesize sortMapPopover = _sortMapPopover;

@synthesize sortOrder = _sortOrder;
@synthesize sortedBy = _sortedBy;

@synthesize mapItems = _mapItems;



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
    [_itemsTableView release];
    [_sortMethodButton release];
    [_sortOrderButton release];
    
    [_map release];
    [_filteringCategories release];

    [_sortMapPopover release];
    
    [_mapItems release];

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

    // Inicializa el resto de la vista
    if(self.filteringCategories) {
        NSMutableString *names = [NSMutableString string];
        BOOL firstOne = true;
        for(MECategory *cat in self.filteringCategories) {
            if(!firstOne) {
                [names appendString:@"|"];
            }
            [names appendString:cat.name];
        }
        self.title = names;
    } else {
        self.title = self.map.name;
    }

    
    // Creamos el boton para crear o editar mapas
    UIBarButtonItem *createItemBtn = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
                                                                                    target:self 
                                                                                    action:@selector(createAndEditItemAction:)];
    self.navigationItem.rightBarButtonItem=createItemBtn;
    [createItemBtn release];
    
    // Se registra para saber si hubo cambios en el modelo desde otros ViewControllers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelHasChanged:) name:@"ModelHasChangedNotification" object:nil];

    // Pone el orden por defecto de la lista
    self.sortedBy = SORT_BY_NAME;
    self.sortOrder = SORT_DESCENDING;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{   
    [self setItemsTableView:nil];
    [self setSortMethodButton:nil];
    [self setSortOrderButton:nil];

    [self setMap:nil];
    [self setFilteringCategories:nil];

    [self setSortMapPopover:nil];
    
    [self setMapItems:nil];

    // Se deregistra de las notificaciones
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidUnload];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Si no estan cargados los mapas de una iteracion previa los volvemos a cargar
    if(!self.mapItems) {
        [self loadMapItemsListData];
    }

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
- (IBAction) createAndEditItemAction:(id)sender {
    
    [self showMapItemEditorFor:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) modelHasChanged:(NSNotification *)notification {
    
    // Puesto que el contenido del modelo ha cambiado deberiamos invalidar lo que se esta mostrando y pedirlo de nuevo
    // ¿Que pasa si se llama cuando no estamos en pantalla?
    // ¿Que pasa si se pone a "nul" y si esta en pantalla?
    
    // self.maps = nil;
    // [self loadMapListData];
    NSLog(@"modelHasChanged");
    self.mapItems=nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)sortOrderButtonAction:(UIButton *)sender {
    
    self.sortOrder = (self.sortOrder==SORT_ASCENDING ? SORT_DESCENDING : SORT_ASCENDING);
    
    UIImage *img = nil;
    switch (self.sortOrder) {
        case SORT_ASCENDING:
            img = [UIImage imageNamed:@"sortAscending.png"];
            break;
            
        case SORT_DESCENDING:
            img = [UIImage imageNamed:@"sortDescending.png"];
            break;
            
    }
    [self.sortOrderButton setImage:img forState:UIControlStateNormal];
    [self loadMapItemsListData];
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
        
        CGRect btnFrame = {self.view.frame.size.width/2-25, self.itemsTableView.frame.origin.y + self.itemsTableView.frame.size.height, 50, 1};
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
- (void) sortMethodSelected:(SORTING_METHOD)sortedBy {
    
    [self.sortMapPopover dismissPopoverAnimated:NO];
    self.sortMapPopover = nil;
    
    if(self.sortedBy!=sortedBy) {
        UIImage *img = nil;
        switch (sortedBy) {
            case SORT_BY_NAME:
                img = [UIImage imageNamed:@"alphabeticSortIcon.png"];
                break;
                
            case SORT_BY_CREATING_DATE:
                img = [UIImage imageNamed:@"createdSortIcon.png"];
                break;
                
            case SORT_BY_UPDATING_DATE:
                img = [UIImage imageNamed:@"modifiedSortIcon.png"];
                break;
        }
        [self.sortMethodButton setImage:img forState:UIControlStateNormal];
        
        self.sortedBy = sortedBy;
        [self loadMapItemsListData];
    }
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PointCatEditor delegate
//---------------------------------------------------------------------------------------------------------------------
- (MEBaseEntity *) createNewInstanceForMap:(MEMap *)map isPoint:(BOOL)isPoint {
    if(isPoint) {
        return [MEPoint insertNewInMap:map];
    } else {
        return [MECategory insertNewInMap:map];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) pointCatEditCancel:(PointCatEditorController *)sender {
    NSLog(@"pointCatEditCancel");
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) pointCatEditSave:(PointCatEditorController *)sender entity:(MEBaseEntity *)entity {
    
    NSLog(@"pointCatEditSave");
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    entity.changed = true;
    [entity commitChanges]; // AQUI HAY UN CONFLICTO CON EL TOUCH AS UPDATED
    
    [self loadMapItemsListData];
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
    return [self.mapItems count];
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *mapViewIdentifier = @"PointCatCellView";
    
    MEBaseEntity *entity = [self.mapItems objectAtIndex:indexPath.row];
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:mapViewIdentifier];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mapViewIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    cell.textLabel.text = entity.name;
    cell.detailTextLabel.text = entity.desc;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    if([entity isKindOfClass:[MECategory class]]) {
        MECategory *cat = (MECategory *)entity;
        cell.badgeString = [NSString stringWithFormat:@"%03u", cat.t_displayCount];
    } else {
        cell.badgeString = nil;
    }
    //cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
    cell.badgeColor = [UIColor colorWithRed:0.197 green:0.592 blue:0.219 alpha:1.000];
    cell.badge.radius = 9;
    
    cell.imageView.image = entity.icon.image;
    
    return cell;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        MEBaseEntity *entity = [self.mapItems objectAtIndex:indexPath.row];
        
        // Marca la entidad como borrada y a su mapa como modificado
        [entity markAsDeleted];
        [[entity map] touchAsUpdated];
        
        NSError *error = [entity commitChanges];
        if(error) {
            NSLog(@"Error saving context when deleting an item: %@ / %@", error, [error userInfo]);
            [self showErrorToUser:@"Error deleting map item"];
        }
        
        // No se puede hacer "facil" por el tema de la categorizacion
        [self loadMapItemsListData];
    }   

}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Table view data delegate
//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    [self showMapItemEditorFor:[self.mapItems objectAtIndex:indexPath.row]];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    MEBaseEntity *entity = [self.mapItems objectAtIndex:indexPath.row];
    
    if([entity isKindOfClass:[MECategory class]]) {
        PointListController *pointListController = [[PointListController alloc] initWithNibName:@"PointListController" bundle:nil];
        pointListController.map = self.map;
        if(self.filteringCategories) {
            NSMutableArray *fcats = [NSMutableArray arrayWithArray:self.filteringCategories];
            [fcats addObject:entity];
            pointListController.filteringCategories = [[fcats copy] autorelease];
        } else {
            pointListController.filteringCategories = [NSArray arrayWithObject:entity];
        }
        pointListController.showMode = self.showMode;
        [self.navigationController pushViewController:pointListController animated:YES];
        [pointListController release];
    }
    
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (void) loadMapItemsListData {
    
    // Pone un indicador de actividad
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem.customView = activityIndicator;
    [activityIndicator startAnimating];
    [activityIndicator release];
    

    // Este sera el bloque de codigo a ejecutar
    TBlock_getElementListInMapFinished myCallback = ^(NSArray *elements, NSError *error) {

        // Paramos el indicador de actividad
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
        [activityIndicator stopAnimating];
        
        // Si hay un error lo indica. En otro caso, recarga la tabla con los mapas
        if(error) {
            [self showErrorToUser:@"Error loading map's elements info"];
        } else {
            self.navigationItem.rightBarButtonItem.customView = nil;
            self.mapItems = elements;
            [self.itemsTableView reloadData];
        }
    };
    
    // lanzamos la carga de los elementos del mapa
    if(self.showMode == showFlat) {
        [[ModelService sharedInstance] getFlatElemensInMap:self.map 
                                             forCategories:self.filteringCategories
                                                   orderBy:self.sortedBy 
                                                  callback:myCallback];
    } else {
        //    forCategory:[self.filteringCategories lastObject]
        [[ModelService sharedInstance] getCategorizedElemensInMap:self.map 
                                                    forCategories:self.filteringCategories
                                                          orderBy:self.sortedBy
                                                         callback:myCallback];
    }

}

//---------------------------------------------------------------------------------------------------------------------
- (void) showMapItemEditorFor:(MEBaseEntity *)entityToView {
    
    PointCatEditorController *pointCatEditor = [[PointCatEditorController alloc] initWithNibName:@"PointCatEditorController" bundle:nil];
    pointCatEditor.delegate = self;
    pointCatEditor.map = self.map;
    pointCatEditor.entity = entityToView;
    [self.navigationController pushViewController:pointCatEditor animated:YES];
    [pointCatEditor release];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) showErrorToUser:(NSString *)errorMsg {
    [SVProgressHUD showWithStatus:@""];
    [SVProgressHUD dismissWithError:errorMsg afterDelay:2];
}


@end
