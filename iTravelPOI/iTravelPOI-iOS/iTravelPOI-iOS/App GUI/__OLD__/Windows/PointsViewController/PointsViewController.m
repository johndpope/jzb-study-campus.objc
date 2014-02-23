//
//  PointsViewController.m
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointsViewController__IMPL__
#import "PointsViewController.h"
#import "PointListViewController.h"
#import "PointMapViewController.h"
#import "PointsControllerDelegate.h"
#import "BaseCoreDataService.h"
#import "MMap.h"
#import "PointEditorViewController.h"
#import "OpenInActionSheetViewController.h"
#import "BlockActionSheet.h"
#import "TagFilterViewController.h"
#import "SWRevealViewController.h"
#import "KxMenu.h"
#import "Util_Macros.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointsViewController () <SWRevealViewControllerDelegate, TagFilterViewControllerDelegate,
                                    PointEditorViewControllerDelegate, PointsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar                          *toolBar;
@property (weak, nonatomic) IBOutlet UIToolbar                          *doneToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem                    *changeControllerTbItem;
@property (weak, nonatomic) IBOutlet UIView                             *contentView;


@property (strong, nonatomic) PointListViewController                   *pointListVC;
@property (strong, nonatomic) PointMapViewController                    *pointMapVC;
@property (weak, nonatomic)   UIViewController<PointsViewerProtocol>    *activeVC;

@property (strong, nonatomic) NSManagedObjectContext                    *moContext;

@property (weak, nonatomic)   NSArray                                   *pointList;
@property (strong, nonatomic) NSMutableSet                              *selectedPoints;
@property (assign, nonatomic) SEL                                       multiSelectionDoneSel;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation PointsViewController


@synthesize map = _map;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setMap:(MMap *)map {
    
    _map = map;
    
    // Por algun motivo necesita referenciar directamente al moContext
    self.moContext = map.managedObjectContext;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) editPoint:(MPoint *)point {
    
    // Crea un contexto hijo en el que crea una copia del punto para editarlo
    NSManagedObjectContext *childContext = [BaseCoreDataService childContextFor:self.moContext];
    MPoint *copiedPoint = (MPoint *)[childContext objectWithID:point.objectID];
    
    // Lanza la edicion
    [self performSegueWithIdentifier: @"editSelectedPoint" sender: copiedPoint];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) openInExternalApp:(MPoint *)point {
    
    [OpenInActionSheetViewController showOpenInActionSheetWithController:self point:point];
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.doneToolbar.hidden = TRUE;

    // Do any additional setup after loading the view from its nib
    self.pointListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PointListViewController"];
    self.pointMapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PointMapViewController"];
    
    self.pointListVC.delegate = self;
    self.pointMapVC.delegate = self;
    
    self.selectedPoints = [NSMutableSet set];

}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {

    
    [super viewWillAppear:animated];

    // Pone el titulo de la ventana atendiendo al titulo
    self.title = self.map ? self.map.name : @"Any Map";
    
    // Cada vez que esta ventana se muestra se establece como el delegate del side-menu
    self.revealViewController.delegate = self;
    
    // Comienza mostrando los puntos en una lista
    if(!self.activeVC) {
        [self _transitionFromViewController:nil toViewController:self.pointListVC];
    }
    
    
    // La lista de puntos se carga desde el filtro activo
    TagFilterViewController *tagFilterController = (TagFilterViewController *)self.revealViewController.rightViewController;
    tagFilterController.delegate = self;

    // La lista de puntos se carga desde el filtro activo
    self.pointList = tagFilterController.filter.pointList;

}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.activeVC.view.frame = self.contentView.bounds;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"editSelectedPoint"]) {
        
        // El objeto "sender" es el punto a editar (ya copiado)
        MPoint *copiedPoint = (MPoint *)sender;
        
        // Consigue la instancia del editor
        PointEditorViewController *editor = (PointEditorViewController *)segue.destinationViewController;
        
        // Propaga el color del tinte
        editor.view.tintColor = self.view.tintColor;

        // Pasa la informacion necesaria
        editor.point = copiedPoint;
        editor.delegate = self;
    }
}

- (void) startMultipleSelection:(SEL) multiSelectionDoneSel {
    
    self.multiSelectionDoneSel = multiSelectionDoneSel;
    
    CGFloat visibleY = self.toolBar.frame.origin.y;
    CGFloat hiddenY = self.view.frame.origin.y+self.view.frame.size.height;
    
    
    frameSetY(self.doneToolbar, hiddenY);
    self.doneToolbar.hidden = FALSE;
    
    [UIView animateWithDuration:0.15
                     animations:^{
                         frameSetY(self.toolBar, hiddenY);
                         [self.activeVC startMultiplePointSelection];
                     }
                     completion:^(BOOL finished) {
                         self.toolBar.hidden = TRUE;
                         [UIView animateWithDuration:0.15
                                          animations:^{
                                              frameSetY(self.doneToolbar, visibleY);
                                          }];
                     }];
    
}


- (void) doneMultipleSelection {
    
    CGFloat visibleY = self.doneToolbar.frame.origin.y;
    CGFloat hiddenY = self.view.frame.origin.y+self.view.frame.size.height;
    
    frameSetY(self.toolBar, hiddenY);
    self.toolBar.hidden = FALSE;
    
    [UIView animateWithDuration:0.15
                     animations:^{
                         frameSetY(self.doneToolbar, hiddenY);
                         [self.activeVC doneMultiplePointSelection];
                     }
                     completion:^(BOOL finished) {
                         self.doneToolbar.hidden = TRUE;
                         [UIView animateWithDuration:0.15
                                          animations:^{
                                              frameSetY(self.toolBar, visibleY);
                                          }];
                     }];
}


//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarDoneAction:(UIBarButtonItem *)sender {
    [self performSelector:self.multiSelectionDoneSel withObject:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarCancelAction:(UIBarButtonItem *)sender {
    [self doneMultipleSelection];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarItemMultiSelect:(UIBarButtonItem *)sender {

    [self startMultipleSelection:@selector(msDelete)];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarShowFilter:(UIBarButtonItem *)sender {
    [self.revealViewController rightRevealToggle:self];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarChangeController:(UIBarButtonItem *)sender {

    if(self.activeVC == self.pointListVC) {
        [self _transitionFromViewController:self.pointListVC toViewController:self.pointMapVC];
        self.changeControllerTbItem.image = [UIImage imageNamed:@"actions-view-list"];
    } else {
        [self _transitionFromViewController:self.pointMapVC toViewController:self.pointListVC];
        self.changeControllerTbItem.image = [UIImage imageNamed:@"BlueMapIcon2-2"];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarItemAddNew:(UIBarButtonItem *)sender {
    
    
    // Crea un contexto hijo en el que crea un nuevo punto para editarlo
    NSManagedObjectContext *childContext = [BaseCoreDataService childContextFor:self.moContext];
    MMap *copiedMap = (MMap *)[childContext objectWithID:self.map.objectID];
    MPoint *pointToAdd = [MPoint emptyPointWithName:@"" inMap:copiedMap];
    
    // Si hay un filtro activo de Tags se los establece por defecto
    TagFilterViewController *tagFilterController = (TagFilterViewController *)self.revealViewController.rightViewController;
    NSSet *filterTags = tagFilterController.filter.filterTags;
    for(MTag *tag in filterTags) {
        
        if(!tag.isAutoTagValue) {
            // Tags directos que no son automaticos
            MTag *copiedTag = (MTag *)[childContext objectWithID:tag.objectID];
            [copiedTag tagPoint:pointToAdd];
        } else {
            // Le asigna el icono por defecto si estaba filtrado este tipo de elementos
            MTag *copiedTag = (MTag *)[childContext objectWithID:tag.objectID];
            [pointToAdd updateIcon:copiedTag.icon];
        }
        
    }
    
    
    // Lanza la edicion
    [self performSegueWithIdentifier: @"editSelectedPoint" sender: pointToAdd];
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



//=====================================================================================================================
#pragma mark -
#pragma mark <PointEditorViewControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void) pointEdiorSavePoint:(PointEditorViewController *)sender {
    
    // Graba los cambios en ambos contextos
    [BaseCoreDataService saveChangesInContext:sender.point.managedObjectContext];
    [BaseCoreDataService saveChangesInContext:self.map.managedObjectContext];
    
    //@TODO:    Hay que revisar si, con los cambios, cumple el filtro activo.
    //          Si no lo cumple se debe borrar. Si lo cumple hay que refrescarlo
}


//=====================================================================================================================
#pragma mark -
#pragma mark <TagFilterViewControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void)filterHasChanged:(TagFilterViewController *)sender filter:(MComplexFilter *)filter {
    
    // Refresca los puntos de la tabla desde el filtro
    self.pointList = filter.pointList;

    // Actualiza los visores de puntos (lista y mapa)
    [self.activeVC pointsHaveChanged];
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
- (void) _transitionFromViewController:(UIViewController<PointsViewerProtocol> *)fromViewController
                      toViewController:(UIViewController<PointsViewerProtocol> *)toViewController {
    
    // No estamos cambiando
    if(toViewController==nil) {
        return;
    }
    
    CGFloat height = -self.contentView.bounds.size.height;
    /*
     CGFloat height = self.contentView.bounds.size.height;
    if(toViewController == self.pointMapVC) {
        height = -height;
    }
     */
    
    
    CGRect rect = self.contentView.bounds;
    rect.origin.y = height;
    toViewController.view.frame = rect;
    toViewController.view.autoresizingMask = self.view.autoresizingMask;
    [self addChildViewController:toViewController];
    [self.contentView addSubview:toViewController.view];

    self.activeVC = toViewController;
    
    
    // No viene de uno previo
    if(fromViewController==nil) {
        
        CGRect rect = toViewController.view.frame;
        rect.origin.y = 0;
        toViewController.view.frame = rect;
        [toViewController didMoveToParentViewController:self];
        
    } else {
        
        [fromViewController willMoveToParentViewController:nil];

        [UIView animateWithDuration:0.6
                         animations:^{
                             
                             CGRect rect = fromViewController.view.frame;
                             rect.origin.y = -height;
                             fromViewController.view.frame = rect;

                             rect = toViewController.view.frame;
                             rect.origin.y = 0;
                             toViewController.view.frame = rect;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             CGRect rect = toViewController.view.frame;
                             rect.origin.y = 0;
                             toViewController.view.frame = rect;
                             
                             [fromViewController.view removeFromSuperview];
                             [fromViewController removeFromParentViewController];
                             [toViewController didMoveToParentViewController:self];
                             
                         }];
        
    }
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _transitionFromViewController222:(UIViewController<PointsViewerProtocol> *)fromViewController
                         toViewController:(UIViewController<PointsViewerProtocol> *)toViewController {
    
    // No estamos cambiando
    if(toViewController==nil) {
        return;
    }

    // Lo añade
    toViewController.view.frame = self.contentView.bounds;
    toViewController.view.autoresizingMask = self.view.autoresizingMask;
    [self addChildViewController:toViewController];
    [self.contentView addSubview:toViewController.view];
    
    
    // No viene de uno previo
    if(fromViewController==nil) {
        
        [toViewController didMoveToParentViewController:self];
        self.activeVC = toViewController;
        
    } else {
        
        [fromViewController willMoveToParentViewController:nil];
        [self transitionFromViewController:fromViewController
                          toViewController:toViewController
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                }
                                completion:^(BOOL finished) {
                                    
                                    [fromViewController removeFromParentViewController];
                                    [toViewController didMoveToParentViewController:self];
                                    self.activeVC = toViewController;
                                    
                                }];
        
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) pushMenuItem:(id)sender
{
    NSLog(@"%@", sender);
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

//---------------------------------------------------------------------------------------------------------------------
- (void) msDelete {
    [BlockActionSheet showInView:self.view
                       withTitle:@"Delete Points"
               cancelButtonTitle:@"Cancel"
          destructiveButtonTitle:@"Done"
               otherButtonTitles:nil
                            code:^(NSInteger buttonIndex) {
                                NSLog(@"index = %d",buttonIndex);
        [self doneMultipleSelection];
    }];
}


@end
