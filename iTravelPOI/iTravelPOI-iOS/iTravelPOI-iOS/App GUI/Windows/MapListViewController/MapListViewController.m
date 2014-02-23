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
#import "SWRevealViewController.h"
#import "PointsViewController.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MapListViewController () <SWRevealViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>


@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *tableViewItemList;

@property (strong, nonatomic) NSArray *mapList;

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
+ (MapListViewController *) mapListViewControllerWithContext:(NSManagedObjectContext *)moContext {
    
    MapListViewController *me = [[MapListViewController alloc] initWithNibName:@"MapListViewController" bundle:nil];
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
    
    self.mapList = [MMap allMapsinContext:self.moContext includeMarkedAsDeleted:FALSE];
    
    
    // Cada vez que esta ventana se muestra se establece como el delegate del side-menu
    if(self.revealViewController) {
        self.revealViewController.delegate = self;
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
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
        MMap *map = (MMap *)sender;
        PointsViewController *poiList = (PointsViewController *)segue.destinationViewController;
        poiList.map =map;
    }
    
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
#pragma mark <SWRevealViewControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
// The following delegate methods will be called before and after the front view moves to a position
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    
    switch (position) {
            
            // Vuelve al estado normal con ambos paneles ocultos
        case FrontViewPositionLeft:
            break;
            
            // Se va a mostrar el panel de la izquierda
        case FrontViewPositionLeftSide:
            break;
            
            // Se va a mostrar el panel de la derecha
        case FrontViewPositionRight:
            break;
            
        default:
            break;
    }
    // NSLog(@"- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position");
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    //NSLog(@"- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position");
}

// This will be called inside the reveal animation, thus you can use it to place your own code that will be animated in sync
- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position {
    //NSLog(@"- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position");
}

// Implement this to return NO when you want the pan gesture recognizer to be ignored
- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController {
    //NSLog(@"- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController");
    return YES;
}

// Implement this to return NO when you want the tap gesture recognizer to be ignored
- (BOOL)revealControllerTapGestureShouldBegin:(SWRevealViewController *)revealController {
    //NSLog(@"- (BOOL)revealControllerTapGestureShouldBegin:(SWRevealViewController *)revealController");
    return YES;
}

// Called when the gestureRecognizer began and ended
- (void)revealControllerPanGestureBegan:(SWRevealViewController *)revealController {
    //NSLog(@"- (void)revealControllerPanGestureBegan:(SWRevealViewController *)revealController");
}

- (void)revealControllerPanGestureEnded:(SWRevealViewController *)revealController {
    //NSLog(@"- (void)revealControllerPanGestureEnded:(SWRevealViewController *)revealController");
}

// The following methods provide a means to track the evolution of the gesture recognizer.
// The 'location' parameter is the X origin coordinate of the front view as the user drags it
// The 'progress' parameter is a positive value from 0 to 1 indicating the front view location relative to the
// rearRevealWidth or rightRevealWidth. 1 is fully revealed, dragging ocurring in the overDraw region will result in values above 1.
- (void)revealController:(SWRevealViewController *)revealController panGestureBeganFromLocation:(CGFloat)location progress:(CGFloat)progress {
    //NSLog(@"- (void)revealController:(SWRevealViewController *)revealController panGestureBeganFromLocation:(CGFloat)location progress:(CGFloat)progress");
}

- (void)revealController:(SWRevealViewController *)revealController panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress {
    //NSLog(@"- (void)revealController:(SWRevealViewController *)revealController panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress");
}

- (void)revealController:(SWRevealViewController *)revealController panGestureEndedToLocation:(CGFloat)location progress:(CGFloat)progress {
    //NSLog(@"- (void)revealController:(SWRevealViewController *)revealController panGestureEndedToLocation:(CGFloat)location progress:(CGFloat)progress");
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (MMap *) _mapAtIndex:(NSUInteger)index {
    
    return index==0?nil:self.mapList[index-1];
}

@end
