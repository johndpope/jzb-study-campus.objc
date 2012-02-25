//
//  PointListController.m
//  iTravelPOI
//
//  Created by jzarzuela on 19/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PointListController.h"
#import "PointCatEditorController.h"
#import "ShowModeController.h"
#import "ModelServiceAsync.h"
#import "WEPopoverController.h"
#import "UIBarButtonItem+WEPopover.h" 
#import "TDBadgedCell.h"
#import "SVProgressHUD.h"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface PointListController ()

@property (nonatomic, retain) NSArray * elements;
@property (nonatomic, retain) WEPopoverController *popoverShowMode;

- (IBAction)createNewEntityAction:(id)sender;
- (void) saveAndReloadElements;


@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation PointListController


@synthesize map = _map;
@synthesize filteringCategories = _filteringCategories;
@synthesize showMode = _showMode;

@synthesize elements = _elements;
@synthesize popoverShowMode = _popoverShowMode;


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
    [_map release];
    [super dealloc];
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.backBarButtonItem = self.editButtonItem;
    //    leftBarButtonItem = self.editButtonItem;
    
    
    // Inicializa el resto de la vista
    if(self.filteringCategories) {
        NSMutableString *names = [NSMutableString string];
        BOOL firstOne = true;
        for(TCategory *cat in self.filteringCategories) {
            if(!firstOne) {
                [names appendString:@"|"];
            }
            [names appendString:cat.name];
        }
        self.title = names;
    } else {
        self.title = self.map.name;
    }
    
    // Creamos el boton de crear nuevos elementos
    UIBarButtonItem *createMapBtn = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
                                                                                   target:self 
                                                                                   action:@selector(createNewEntityAction:)];
    self.navigationItem.rightBarButtonItem=createMapBtn;
    [createMapBtn release];
    
    
    // Creamos el boton de ver flat o categorized
    UIBarButtonItem *showModeBtn = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                  target:self 
                                                                                  action:@selector(changeShowModeAction:)];
    [self setToolbarItems:[NSArray arrayWithObject:showModeBtn]];
    [showModeBtn release];
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
    
    if(!self.elements) {
        // Lanzamos la busqueda de los mapas y los mostramos
        [SVProgressHUD showWithStatus:@"Loading elements info"];
        [self saveAndReloadElements];
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
- (void) saveAndReloadElements {
    
    [[ModelServiceAsync sharedInstance] saveContext:^(NSError *error) {
        if(error) {
            [SVProgressHUD showWithStatus:@"Loading local entities"];
            [SVProgressHUD dismissWithError:@"Error saving local entities" afterDelay:2];
        } else {
            if(self.showMode == showFlat) {
                [[ModelServiceAsync sharedInstance] getFlatElemensInMap:self.map 
                                                          forCategories:self.filteringCategories
                                                                orderBy:SORT_BY_NAME 
                                                               callback:^(NSArray *elements, NSError *error) {
                                                                   if(error) {
                                                                       [SVProgressHUD dismissWithError:@"Error loading elements info" afterDelay:2];
                                                                   } else {
                                                                       [SVProgressHUD dismiss];
                                                                       self.elements = elements;
                                                                       [self.tableView reloadData];
                                                                   }
                                                               }];
            } else {
                //    forCategory:[self.filteringCategories lastObject]
                [[ModelServiceAsync sharedInstance] getCategorizedElemensInMap:self.map 
                                                                 forCategories:self.filteringCategories
                                                                       orderBy:SORT_BY_NAME 
                                                                      callback:^(NSArray *elements, NSError *error) {
                                                                          if(error) {
                                                                              [SVProgressHUD dismissWithError:@"Error loading elements info" afterDelay:2];
                                                                          } else {
                                                                              [SVProgressHUD dismiss];
                                                                              self.elements = elements;
                                                                              [self.tableView reloadData];
                                                                          }
                                                                      }];
            }
        }
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)createNewEntityAction:(id)sender {
    
    PointCatEditorController *entityEditor = [[PointCatEditorController alloc] initWithNibName:@"PointCatEditorController" bundle:nil];
    
    entityEditor.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    entityEditor.delegate = self;
    entityEditor.map = self.map;
    
    //    [self.navigationController pushViewController:mapEditor animated:YES];
    [self.navigationController presentModalViewController:entityEditor animated:YES];
    [entityEditor release];
}


//---------------------------------------------------------------------------------------------------------------------
- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] autorelease];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13 
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin; 
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
	return props;	
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)changeShowModeAction:(id)sender {
    
    /*
     // Cambiamos el modo de mostrar la informacion
     if(self.showMode==showFlat) {
     self.showMode =  showCategorized;
     } else {
     self.showMode =  showFlat;
     }
     
     // Lanzamos la busqueda de los mapas y los mostramos 
     [SVProgressHUD showWithStatus:@"Loading elements info"];
     [self saveAndReloadElements];
     */
    
    if (self.popoverShowMode && self.popoverShowMode.popoverVisible) {
        [self.popoverShowMode dismissPopoverAnimated:YES];
        self.popoverShowMode = nil;
    } else {
        
        if(!self.popoverShowMode) {
            
            ShowModeController *showModeController = [[ShowModeController alloc] initWithNibName:@"showModeController" bundle:nil];
            
            self.popoverShowMode = [[[WEPopoverController alloc] initWithContentViewController:showModeController] autorelease];
            self.popoverShowMode.containerViewProperties = [self improvedContainerViewProperties];
            self.popoverShowMode.popoverContentSize = showModeController.view.frame.size;
            
            [showModeController release];
        }
        
        CGRect btnFrame = {0, self.tableView.frame.size.height, 50, 1};
        [self.popoverShowMode presentPopoverFromRect:btnFrame 
                                              inView:self.tableView 
                            permittedArrowDirections:UIPopoverArrowDirectionDown
                                            animated:YES];
    }
    
    
}

//---------------------------------------------------------------------------------------------------------------------
- (TBaseEntity *) createNewInstanceForMap:(TMap *)map isPoint:(BOOL)isPoint {
    if(isPoint) {
        return [TPoint insertNewInMap:map];
    } else {
        return [TCategory insertNewInMap:map];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) pointCatEditCancel:(PointCatEditorController *)sender {
    NSLog(@"pointCatEditCancel");
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) pointCatEditSave:(PointCatEditorController *)sender entity:(TBaseEntity *)entity {
    
    NSLog(@"pointCatEditSave");
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    entity.changed = true;
    
    [self saveAndReloadElements];
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
    return [self.elements count];
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
    
    
    
    static NSString *mapViewIdentifier = @"PointCatCellView";
    
    TBaseEntity *entity = [self.elements objectAtIndex:indexPath.row];
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:mapViewIdentifier];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mapViewIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    cell.textLabel.text = entity.name;
    cell.detailTextLabel.text = entity.desc;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    if([entity isKindOfClass:[TCategory class]]) {
        TCategory *cat = (TCategory *)entity;
        cell.badgeString = [NSString stringWithFormat:@"%03u", cat.t_displayCount];
    } else {
        cell.badgeString = nil;
    }
    //cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
    cell.badgeColor = [UIColor colorWithRed:0.197 green:0.592 blue:0.219 alpha:1.000];
    cell.badge.radius = 9;
    
    cell.imageView.image = myPngs[indexPath.row % 5];
    
    return cell;
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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        TBaseEntity *entity = [self.elements objectAtIndex:indexPath.row];
        [entity markAsDeleted];
        // No se puede hacer "facil" por el tema de la categorizacion
        [self saveAndReloadElements];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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
    
    PointCatEditorController *pointCatEditor = [[PointCatEditorController alloc] initWithNibName:@"PointCatEditorController" bundle:nil];
    
    pointCatEditor.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    pointCatEditor.delegate = self;
    pointCatEditor.map = self.map;
    pointCatEditor.entity = [self.elements objectAtIndex:indexPath.row];
    
    //    [self.navigationController pushViewController:mapEditor animated:YES];
    [self.navigationController presentModalViewController:pointCatEditor animated:YES];
    [pointCatEditor release];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TBaseEntity *entity = [self.elements objectAtIndex:indexPath.row];
    
    if([entity isKindOfClass:[TCategory class]]) {
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


@end
