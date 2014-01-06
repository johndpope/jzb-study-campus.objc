//
//  POIListViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __POIListViewController__IMPL__
#import "POIListViewController.h"
#import "KxMenu.h"
#import "SWRevealViewController.h"
#import "TagFilterViewController.h"
#import "BaseCoreDataService.h"
#import "MPoint.h"
#import "MIcon.h"
#import "POIEditorViewController.h"

#import "OpenInActionSheetViewController.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface POIListViewController () <SWRevealViewControllerDelegate, TagFilterViewControllerDelegate,
                                     POIEditorViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, weak) IBOutlet UIBarButtonItem    *filterButtonItem;
@property (nonatomic, weak) IBOutlet UIToolbar          *toolBar;
@property (nonatomic, weak) IBOutlet UITableView        *poisTable;

@property (nonatomic, strong) NSManagedObjectContext    *moContext;
@property (nonatomic, strong) MMap                      *map;
@property (nonatomic, strong) NSArray                   *pointList;

@property (nonatomic, strong) NSArray                   *pointOrder;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation POIListViewController


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setMap:(MMap *)map andContext:(NSManagedObjectContext *)moContext {
    
    // Comprueba que esta todo sincronizado
    if(self.map && ![self.map.managedObjectContext isEqual:self.moContext]) {
        [NSException raise:@"UnsynchronizedContextException" format:@"map.context and passed moContext aren't the same"];
    }
    self.moContext = moContext;
    self.map = map;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.pointOrder = @[MBaseOrderByIconAsc, MBaseOrderByNameAsc];
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {

    
    [super viewWillAppear:animated];
    
    // Cada vez que esta ventana se muestra se establece como el delegate del side-menu
    self.revealViewController.delegate = self;
    
    // Y del filtro
    TagFilterViewController *tagFilterController = (TagFilterViewController *)self.revealViewController.rightViewController;
    tagFilterController.delegate = self;

    // Establece el criterio de ordenacion
    tagFilterController.filter.pointOrder = self.pointOrder;
    
    // La lista de puntos se carga desde el filtro activo
    self.pointList = tagFilterController.filter.pointList;

    // Pone el titulo de la ventana atendiendo al titulo
    self.title = self.map ? self.map.name : @"Any Map";
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"PointList_to_PointEditor"]) {
        
        NSIndexPath *indexPath = [self.poisTable indexPathForCell:(UITableViewCell *)sender];
        if(indexPath) {
            
            POIEditorViewController *editor = (POIEditorViewController *)segue.destinationViewController;

            // Propaga el color del tinte
            editor.view.tintColor = self.view.tintColor;

            MPoint *point = self.pointList[[indexPath indexAtPosition:1]];

            // Crea un contexto hijo en el que crea una copia de la entidad para editarla
            NSManagedObjectContext *childContext = [BaseCoreDataService childContextFor:self.moContext];
            MPoint *copiedPoint = (MPoint *)[childContext objectWithID:point.objectID];

            editor.moContext = childContext;
            editor.point = copiedPoint;
            editor.map = copiedPoint.map;
            editor.delegate = self;
        }
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------
- (void) pushMenuItem:(id)sender
{
    NSLog(@"%@", sender);
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarShowFilter:(UIBarButtonItem *)sender {
    [self.revealViewController rightRevealToggle:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarItemOpenWith:(UIBarButtonItem *)sender {
    [OpenInActionSheetViewController showOpenInActionSheetWithController:self point:self.pointList[0]];

}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarItemShowMap:(UIBarButtonItem *)sender {
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarItemAddNew:(UIBarButtonItem *)sender {
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarItemShowMoreMenu:(UIBarButtonItem *)sender {
    
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Sort by name"
                     image:[UIImage imageNamed:@"actions-sort"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Sort by icon"
                     image:[UIImage imageNamed:@"actions-sort"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Sort by distance"
                     image:[UIImage imageNamed:@"actions-sort"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Sort by update"
                     image:[UIImage imageNamed:@"actions-sort"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Delete"
                     image:[UIImage imageNamed:@"actions-delete"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Move to map"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Tagging"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItem:)]
      ];
    
    //    KxMenuItem *first = menuItems[0];
    //    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    //    first.alignment = NSTextAlignmentCenter;
    

    //[KxMenu setTintColor:[UIColor redColor]];
    [KxMenu setTitleFont: [UIFont systemFontOfSize:12]];

    [KxMenu showMenuInView:self.view
                  fromRect:[self _findBarButtonItemRect:sender inToolBar:self.toolBar]
                 menuItems:menuItems];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (CGRect) _findBarButtonItemRect:(UIBarButtonItem *)barButtonItem inToolBar:(UIToolbar *)toolBar
{
    UIControl *button = nil;
    for (UIView *subview in toolBar.subviews) {
        if ([subview isKindOfClass:[UIControl class]]) {
            for (id target in [(UIControl *)subview allTargets]) {
                if (target == barButtonItem) {
                    button = (UIControl *)subview;
                    break;
                }
            }
            if (button != nil) break;
        }
    }
    
    return [button.superview convertRect:button.frame toView:self.view];
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
#pragma mark <TagFilterViewControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void)filterHasChanged:(TagFilterViewController *)sender filter:(MComplexFilter *)filter {
    
    // Refresca los puntos de la tabla desde el filtro
    self.pointList = filter.pointList;
    [self.poisTable reloadData];
}






//=====================================================================================================================
#pragma mark -
#pragma mark <POIEditorViewControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void) pointEdiorSavePoint:(POIEditorViewController *)sender {

    // Graba los cambios en ambos contextos
    [BaseCoreDataService saveChangesinContext:sender.moContext];
    [BaseCoreDataService saveChangesinContext:self.moContext];
    
    //@TODO:    Hay que revisar si, con los cambios, cumple el filtro activo.
    //          Si no lo cumple se debe borrar. Si lo cumple hay que refrescarlo
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

    return indexPath;
    
    // No dejamos nada seleccionado
    ////return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pointList.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }

    MPoint *itemToShow = (MPoint *)[self.pointList objectAtIndex:[indexPath indexAtPosition:1]];
    cell.textLabel.text = [NSString stringWithFormat:@"%lu - %@",(unsigned long)[indexPath indexAtPosition:1], itemToShow.name];
    cell.imageView.image = itemToShow.icon.image;

    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------


@end
