//
//  PointsViewController.m
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointsViewController__IMPL__
#import "PointsViewController.h"
#import "PointsControllerDelegate.h"

#import "PointListViewController.h"
#import "PointMapViewController.h"
#import "TagTreeTableViewController.h"

#import "BaseCoreDataService.h"
#import "MComplexFilter.h"
#import "MMap.h"

#import "PointDataEditorViewController.h"
#import "OpenInActionSheetViewController.h"

#import "BlockActionSheet.h"
#import "KxMenu.h"
#import "Util_Macros.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define TAGFILTER_X_POS 60.0


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointsViewController () <TagTreeTableViewControllerDelegate,
                                    PointDataEditorViewControllerDelegate, PointsControllerDataSource>

@property (weak, nonatomic) IBOutlet UIToolbar                          *toolBar;
@property (weak, nonatomic) IBOutlet UIToolbar                          *doneToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem                    *changeControllerTbItem;
@property (weak, nonatomic) IBOutlet UIView                             *contentView;

@property (strong, nonatomic) UIView                                    *darkCoverView;
@property (strong, nonatomic) TagTreeTableViewController                *tagFilterVC;

@property (strong, nonatomic) PointListViewController                   *pointListVC;
@property (strong, nonatomic) PointMapViewController                    *pointMapVC;
@property (weak, nonatomic)   UIViewController<PointsViewerProtocol>    *activeVC;

@property (strong, nonatomic) MComplexFilter                            *filter;

@property (strong, nonatomic) NSMutableSet                              *selectedPoints;
@property (assign, nonatomic) SEL                                       multiSelectionDoneSel;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation PointsViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setMap:(MMap *)map {

    self.filter.filterMap = map;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) pointList {
    return self.filter.pointList;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Crea un filtro vacio
        self.filter = [MComplexFilter filter];
    }
    return self;
}


//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib
    self.doneToolbar.hidden = TRUE;

    // Crea los ViewController de soporte (lista y mapa de puntos)
    self.pointListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PointListViewController"];
    self.pointMapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PointMapViewController"];
    self.pointListVC.dataSource = self;
    self.pointMapVC.dataSource = self;
    
    // Añade el ViewController para gestionar el filtro
    self.tagFilterVC = [self _createTagFilterViewController];

    // Arranca sin puntos seleccionados
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
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidLayoutSubviews {

    [super viewDidLayoutSubviews];

    // Hay que ajustar la vista del controlador activo para que "siga" al redimensionado de la ventana contenedora
    self.activeVC.view.frame = self.contentView.bounds;

    // Comienza mostrando los puntos en una lista (AQUI PORQUE ES DONDE ESTAN BIEN LOS TAMAÑOS DE LAS VISTAS)
    if(!self.activeVC) {
        [self _transitionFromViewController:nil toViewController:self.pointListVC];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.activeVC.view.frame = self.contentView.bounds;
    self.tagFilterVC.view.frame = [self _tagFilterRect];
    self.darkCoverView.frame = self.view.frame;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"editSelectedPoint"]) {
        
        // El objeto "sender" es el punto a editar (ya copiado a un contexto hijo)
        MPoint *copiedPoint = (MPoint *)sender;
        
        // Consigue la instancia del editor
        PointDataEditorViewController *editor = (PointDataEditorViewController *)segue.destinationViewController;
        
        // Propaga el color del tinte
        editor.tintColor = self.view.tintColor;

        // Pasa la informacion necesaria
        editor.point = copiedPoint;
        editor.delegate = self;
    }
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
    [self _doneMultipleSelection];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarChangeController:(UIBarButtonItem *)sender {
    
    if(self.activeVC == self.pointListVC) {
        [self _transitionFromViewController:self.pointListVC toViewController:self.pointMapVC];
        self.changeControllerTbItem.image = [UIImage imageNamed:@"tbar-viewList"];
    } else {
        [self _transitionFromViewController:self.pointMapVC toViewController:self.pointListVC];
        self.changeControllerTbItem.image = [UIImage imageNamed:@"tbar-viewMap"];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarItemMultiSelect:(UIBarButtonItem *)sender {

    [self _startMultipleSelection:@selector(msDelete)];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarShowFilter:(UIBarButtonItem *)sender {
    [self _toggleShowTagFilter];
    //    [self.revealViewController rightRevealToggle:self];
}


//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarItemAddNew:(UIBarButtonItem *)sender {
    
    
    // Crea un contexto hijo en el que crea un nuevo punto para editarlo
    NSManagedObjectContext *childContext = [BaseCoreDataService childContextFor:self.filter.moContext];
    MMap *copiedMap = (MMap *)[childContext objectWithID:self.map.objectID];
    MPoint *pointToAdd = [MPoint emptyPointWithName:@"" inMap:copiedMap];
    
    // Si hay un filtro activo de Tags se los establece por defecto
    NSSet *filterTags = self.filter.filterTags;
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
                     image:[UIImage imageNamed:@"tbar-sort"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Sort by icon"
                     image:[UIImage imageNamed:@"tbar-sort"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Sort by distance"
                     image:[UIImage imageNamed:@"tbar-sort"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Sort by update"
                     image:[UIImage imageNamed:@"tbar-sort"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Delete"
                     image:[UIImage imageNamed:@"tbar-delete"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Move to map"
                     image:[UIImage imageNamed:@"tbar-move"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Tagging"
                     image:[UIImage imageNamed:@"tbar-move"]
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
#pragma mark <PointsControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void) editPoint:(MPoint *)point {
    
    // Crea un contexto hijo en el que crea una copia del punto para editarlo
    NSManagedObjectContext *childContext = [BaseCoreDataService childContextFor:self.filter.moContext];
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
#pragma mark <PointDataEditorViewControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void) pointEdiorSavePoint:(PointDataEditorViewController *)sender {
    
    // Graba los cambios en ambos contextos
    [BaseCoreDataService saveChangesInContext:sender.point.managedObjectContext];
    [BaseCoreDataService saveChangesInContext:self.map.managedObjectContext];
    
    //@TODO:    Hay que revisar si, con los cambios, cumple el filtro activo.
    //          Si no lo cumple se debe borrar. Si lo cumple hay que refrescarlo
}




//=====================================================================================================================
#pragma mark -
#pragma mark <TagTreeTableViewControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void)tagTreeTable:(TagTreeTableViewController *)sender tappedTagTreeNode:(TagTreeNode *)tappedNode {
    
    // Cambiar la seleccion depende de si es el nodo mas profundo seleccionado
    TagTreeNode *selChild = tappedNode.selectedChild;
    if(selChild) {
        selChild.isSelected = FALSE;
    } else {
        [tappedNode toggleSelected];
    }
    
    
    // Actualiza el filtro con los TAGs seleccionado
    self.filter.filterTags = [tappedNode.tree allDeepestSelectedChildrenTags];
    
    // Actualiza la tabla de filtros segun el cambio
    NSSet *expandedTags = tappedNode.tag?[NSSet setWithObject:tappedNode.tag]:[NSSet set];
    [self.tagFilterVC setTagList:self.filter.tagList selectedTags:self.filter.filterTags expandedTags:expandedTags];
    
    // Actualiza los visores de puntos (lista y mapa)
    [self.activeVC pointsHaveChanged];
    [self.selectedPoints removeAllObjects];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (TagTreeTableViewController *) _createTagFilterViewController {
    
    TagTreeTableViewController *tagFilterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TagTreeTableViewController"];
    
    tagFilterVC.view.hidden = TRUE;
    tagFilterVC.view.frame = [self _tagFilterRect];
    tagFilterVC.view.autoresizingMask = self.view.autoresizingMask;
    
    [self.view addSubview:tagFilterVC.view];
    
    [self addChildViewController:tagFilterVC];
    [tagFilterVC didMoveToParentViewController:self];
    
    tagFilterVC.delegate = self;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTagFilterPan:)];
    [tagFilterVC.view addGestureRecognizer:panRecognizer];

    return tagFilterVC;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)handleTagFilterPan:(UIPanGestureRecognizer *)recognizer {
    

    if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGFloat xPos = MAX(TAGFILTER_X_POS, self.tagFilterVC.view.frame.origin.x + translation.x);
        frameSetX(self.tagFilterVC.view, xPos);
        [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];

    } else {
        
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        if(velocity.x>0) {
            [self _hideTagFilter:TRUE];
        } else {
            [self _showTagFilter];
        }
        
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (CGRect) _tagFilterRect {

    CGRect rect = self.view.frame;
    
    rect.origin.x = self.tagFilterVC.view.hidden ? self.view.frame.size.width : TAGFILTER_X_POS;
    rect.origin.y = self.contentView.frame.origin.y;
    rect.size.width = self.view.frame.size.width - TAGFILTER_X_POS;
    rect.size.height = self.view.frame.size.height - self.contentView.frame.origin.y;

    return rect;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _toggleShowTagFilter {
    if(self.tagFilterVC.view.hidden) {
        [self _showTagFilter];
    } else {
        [self _hideTagFilter:NO];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _showTagFilter {


    if(!self.darkCoverView) {
        self.darkCoverView = [[UIView alloc] initWithFrame:self.view.frame];
        self.darkCoverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [self.view insertSubview:self.darkCoverView belowSubview:self.tagFilterVC.view];
        
        self.tagFilterVC.view.frame = [self _tagFilterRect];
        self.tagFilterVC.view.hidden = FALSE;

        [self.tagFilterVC setTagList:self.filter.tagList selectedTags:self.filter.filterTags expandedTags:nil];
    }
    
    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.tagFilterVC.view.frame = [self _tagFilterRect];
                         self.darkCoverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _hideTagFilter:(BOOL)fast {
    
    [UIView animateWithDuration:(fast ? 0.15 : 0.35)
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         frameSetX(self.tagFilterVC.view, self.view.frame.size.width);
                         self.darkCoverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                     }
                     completion:^(BOOL finished) {
                         self.tagFilterVC.view.hidden = TRUE;
                         [self.darkCoverView removeFromSuperview];
                         self.darkCoverView = nil;
                     }];
}


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
- (void) _startMultipleSelection:(SEL) multiSelectionDoneSel {
    
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


//---------------------------------------------------------------------------------------------------------------------
- (void) _doneMultipleSelection {
    
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

//---------------------------------------------------------------------------------------------------------------------
- (void) msDelete {
    [BlockActionSheet showInView:self.view
                       withTitle:@"Delete Points"
               cancelButtonTitle:@"Cancel"
          destructiveButtonTitle:@"Done"
               otherButtonTitles:nil
                            code:^(NSInteger buttonIndex) {
                                NSLog(@"index = %d",buttonIndex);
        [self _doneMultipleSelection];
    }];
}


@end
