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
#import "SVProgressHUD.h"
#import "TDBadgedCell.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MapListController()

@property (nonatomic, readonly) NSManagedObjectContext *moContext;
@property (nonatomic, retain)   NSArray *maps;

- (IBAction)createNewMapAction:(id)sender;

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation MapListController



@synthesize moContext = _moContext;
@synthesize maps = _maps;




//---------------------------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [super dealloc];
    self.maps = nil;
    [_maps release];
    [_moContext release];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



//=====================================================================================================================
#pragma mark - View lifecycle
//=====================================================================================================================



//---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectContext *) moContext {
    if(!_moContext) {
        _moContext = [[ModelService sharedInstance] initContext];
    }
    return _moContext;
}


//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    
    // Inicializa el resto de la vista
    self.title = @"Maps";
    
    // Creamos el boton de crear nuevos mapas
    UIBarButtonItem *createMapBtn = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
                                                                                   target:self 
                                                                                   action:@selector(createNewMapAction:)];
    self.navigationItem.rightBarButtonItem=createMapBtn;
    [createMapBtn release];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.maps) {
        // Lanzamos la busqueda de los mapas y los mostramos
        [SVProgressHUD showWithStatus:@"Loading local maps"];
        
        [[ModelService sharedInstance] getUserMapList:self.moContext callback:^(NSArray *maps, NSError *error) {
            if(error) {
                [SVProgressHUD dismissWithError:@"Error loading local maps" afterDelay:2];
            } else {
                [SVProgressHUD dismiss];
                self.maps = maps;
                [self.tableView reloadData];
            }
        }];
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



//=====================================================================================================================
#pragma mark - Internal Event Handlers
//=====================================================================================================================




//---------------------------------------------------------------------------------------------------------------------
- (IBAction)createNewMapAction:(id)sender {
    
    MapEditorController *mapEditor = [[MapEditorController alloc] initWithNibName:@"MapEditorController" bundle:nil];
    
    mapEditor.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    mapEditor.delegate = self;
    //    [self.navigationController pushViewController:mapEditor animated:YES];
    [self.navigationController presentModalViewController:mapEditor animated:YES];
    [mapEditor release];
}

//---------------------------------------------------------------------------------------------------------------------
- (MEMap *) createNewInstance {
    return [MEMap insertNew:self.moContext];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) mapEditorCancel:(MapEditorController *)sender {
    NSLog(@"mapEditorCancel");
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) mapEditorSave:(MapEditorController *)sender map:(MEMap *)map {
    
    NSLog(@"mapEditorSave");
    
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    map.changed = true;
    
    NSError *error = [map commitChanges];
    if(error) {
        [SVProgressHUD showWithStatus:@"Saving local maps"];
        [SVProgressHUD dismissWithError:@"Error saving local maps" afterDelay:2];
    } else {
        [[ModelService sharedInstance] getUserMapList:self.moContext callback:^(NSArray *maps, NSError *error) {
            if(error) {
                [SVProgressHUD showWithStatus:@"Loading local maps"];
                [SVProgressHUD dismissWithError:@"Error loading local maps" afterDelay:2];
            } else {
                self.maps = maps;
                [self.tableView reloadData];
            }
        }];
    }
    
}



//=====================================================================================================================
#pragma mark - Table view data source
//=====================================================================================================================



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
    
    static UIImage * myPngs[5] = {nil, nil, nil, nil, nil};
    if(myPngs[0]==nil) {
        for(int n=0;n<5;n++) {
            NSString *iconName = [NSString stringWithFormat:@"icon%u",(n+1)];
            NSString *path = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
            myPngs[n] = [[UIImage imageWithContentsOfFile:path] retain];
        }
    }
    
    
    
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
    
    cell.imageView.image = myPngs[[map.points count] % 5];
    
    return cell;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        MEMap *map = [self.maps objectAtIndex:indexPath.row];
        [map markAsDeleted];
        NSMutableArray *marray = [NSMutableArray arrayWithArray:self.maps];
        [marray removeObjectAtIndex:indexPath.row];
        self.maps = [[marray copy] autorelease];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSError *error = [map commitChanges];
        if(error) {
            NSLog(@"Error saving context when deleting an item: %@ / %@", error, [error userInfo]);
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

//---------------------------------------------------------------------------------------------------------------------
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

//---------------------------------------------------------------------------------------------------------------------
/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

//---------------------------------------------------------------------------------------------------------------------
/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



//=====================================================================================================================
#pragma mark - Table view delegate
//=====================================================================================================================



//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    MapEditorController *mapEditor = [[MapEditorController alloc] initWithNibName:@"MapEditorController" bundle:nil];
    
    mapEditor.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    mapEditor.delegate = self;
    mapEditor.map = [self.maps objectAtIndex:indexPath.row];
    
    //    [self.navigationController pushViewController:mapEditor animated:YES];
    [self.navigationController presentModalViewController:mapEditor animated:YES];
    [mapEditor release];
    
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

@end
