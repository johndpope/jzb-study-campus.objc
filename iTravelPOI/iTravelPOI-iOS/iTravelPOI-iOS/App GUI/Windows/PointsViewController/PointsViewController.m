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
#import "TagListEditorViewController.h"

#import "BlockActionSheet.h"
#import "KxMenu.h"
#import "Util_Macros.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define TAGFILTER_X_POS 60.0


typedef NS_ENUM(NSUInteger, MENU_MORE_CMDS) {
    MENU_MORE_MOVE=1,
    MENU_MORE_TAGGING=2,
    MENU_MORE_DELETE=3
};



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointsViewController () <TagTreeTableViewControllerDelegate, TagListEditorViewControllerDelegate,
                                    PointDataEditorViewControllerDelegate, PointsControllerDataSource>

@property (weak, nonatomic) IBOutlet UIToolbar                          *doneToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem                    *changeControllerTbItem;
@property (weak, nonatomic) IBOutlet UIView                             *contentView;

@property (strong, nonatomic) UIView                                    *darkCoverView;
@property (strong, nonatomic) TagTreeTableViewController                *tagFilterVC;

@property (strong, nonatomic) PointListViewController                   *pointListVC;
@property (strong, nonatomic) PointMapViewController                    *pointMapVC;
@property (weak, nonatomic)   UIViewController<PointsViewerProtocol>    *activeVC;

@property (strong, nonatomic) MComplexFilter                            *filter;

@property (strong, nonatomic) NSMutableSet                              *checkedPoints;
@property (assign, nonatomic) MENU_MORE_CMDS                            multiSelectionDoneCmd;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation PointsViewController

@synthesize selectedPoint = _selectedPoint;




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
- (MMap *) map {
    return self.filter.filterMap;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) pointList {
    return self.filter.pointList;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectContext *)moContext {
    return self.filter.moContext;
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
    self.checkedPoints = [NSMutableSet set];
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
    
    // Comienza mostrando los puntos en una lista (AQUI PORQUE ES DONDE ESTAN BIEN LOS TAMAÑOS DE LAS VISTAS)
    if(self.activeVC==nil) {
        [self _transitionFromViewController:self.activeVC toViewController:self.pointListVC];
    }

}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];

    if(!self.doneToolbar.hidden) {

        CGFloat visibleY = self.doneToolbar.frame.origin.y;
        frameSetY(self.navigationController.toolbar, visibleY);
        
        self.doneToolbar.hidden = TRUE;
        self.navigationController.toolbar.hidden = FALSE;
    }

}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidLayoutSubviews {

    [super viewDidLayoutSubviews];

    // Hay que ajustar la vista del controlador activo para que "siga" al redimensionado de la ventana contenedora
    self.activeVC.view.frame = self.contentView.bounds;

}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.activeVC.view.frame = self.contentView.bounds;
    self.tagFilterVC.view.frame = [self _calcTagFilterRect];
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
        
    } else if ([[segue identifier] isEqualToString:@"editPointsTags"]) {
        
        // El objeto "sender" es el NSSet de tags a editar
        NSSet *assignedTags = (NSSet *)sender;

        // Consigue la instancia del editor
        TagListEditorViewController *editor = (TagListEditorViewController *)segue.destinationViewController;
        
        // Propaga el color del tinte
        editor.view.tintColor = self.view.tintColor;
        
        // Se establece como el delegate
        editor.delegate = self;
        
        // Consigue el arrays de tags disponibles para los puntos del mapa activo
        NSArray *allPoints = [MPoint allWithMap:self.filter.filterMap sortOrder:@[MBaseOrderNone]];
        NSMutableSet *allAvailableTags = [MPoint allNonAutoTagsFromPoints:allPoints];

        // Asigna la informacion al editor
        [editor setContext:self.filter.filterMap.managedObjectContext assignedTags:assignedTags availableTags:allAvailableTags];
    }

        
}



//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarDoneAction:(UIBarButtonItem *)sender {
    
    [self _doneMultipleSelection];

    switch (self.multiSelectionDoneCmd) {
        case MENU_MORE_MOVE:
            break;
        case MENU_MORE_TAGGING:
            [self _cmdTagging];
            break;
        case MENU_MORE_DELETE:
            [self _cmdDelete];
            break;
    }
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
    
    // Le "refresca" al ViewController que acaba de entrar que punto es el que estaria seleccionado/con foco
    [self.activeVC refreshSelectedPoint];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarShowFilter:(UIBarButtonItem *)sender {
    [self _toggleShowTagFilter];
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
- (IBAction)tbarItemSortMenu:(UIBarButtonItem *)sender {
    
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Sort by icon"
                     image:[UIImage imageNamed:@"tbar-sort"]
                    target:self
                    action:@selector(sortMenuItem:)
                   cmdData:@[MBaseOrderByIconAsc, MBaseOrderByNameAsc]],
      [KxMenuItem menuItem:@"Sort by name"
                     image:[UIImage imageNamed:@"tbar-sort"]
                    target:self
                    action:@selector(sortMenuItem:)
                   cmdData:@[MBaseOrderByNameAsc]],
      [KxMenuItem menuItem:@"Sort by distance"
                     image:[UIImage imageNamed:@"tbar-sort"]
                    target:self
                    action:@selector(sortMenuItem:)
                   cmdData:@[InMemoryOrderByDistanceAsc, MBaseOrderByNameAsc]]
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu setTitleFont: [UIFont systemFontOfSize:12]];
    [KxMenu showMenuInView:self.view
                  fromRect:[self _findBarButtonItemRect:sender inToolBar:self.navigationController.toolbar]
                 menuItems:menuItems];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarItemShowMoreMenu:(UIBarButtonItem *)sender {
    
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Tagging"
                     image:[UIImage imageNamed:@"tbar-tagging"]
                    target:self
                    action:@selector(moreMenuItemSelected:)
                   cmdData:[NSNumber numberWithInt:MENU_MORE_TAGGING]],
      [KxMenuItem menuItem:@"Delete"
                     image:[UIImage imageNamed:@"tbar-delete"]
                    target:self
                    action:@selector(moreMenuItemSelected:)
                   cmdData:[NSNumber numberWithInt:MENU_MORE_DELETE]]
      ];
    
    [KxMenu setTitleFont: [UIFont systemFontOfSize:12]];
    [KxMenu showMenuInView:self.view
                  fromRect:[self _findBarButtonItemRect:sender inToolBar:self.navigationController.toolbar]
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
    
    [OpenInActionSheetViewController showOpenInActionSheetWithControllerWithPoint:point];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) resortPoints {
    [self.filter resortPoints];
}



//=====================================================================================================================
#pragma mark -
#pragma mark <PointDataEditorViewControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void) pointEdiorSavePoint:(PointDataEditorViewController *)sender {
    
    // Graba los cambios en ambos contextos
    [BaseCoreDataService saveChangesInContext:sender.point.managedObjectContext];
    [BaseCoreDataService saveChangesInContext:self.map.managedObjectContext];
    
    // Como el punto ha sido salvado, hay que recuperarlo del contexto padre
    self.selectedPoint = (MPoint *)[self.map.managedObjectContext objectWithID:sender.point.objectID];
    
    // Refresca la informacion de los puntos
    [self _updateFilterData:^{
        [self.filter reset];
    }];
}




// =====================================================================================================================
#pragma mark -
#pragma mark <TagListEditorViewControllerDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) tagListEditor:(TagListEditorViewController *)sender assignedTags:(NSArray *)assignedTags tagsRemoved:(NSSet *)tagsRemoved tagsAdded:(NSSet *)tagsAdded {

    // Solo actua si hubo cambios
    if(tagsAdded.count>0 || tagsRemoved.count>0) {
        
        // Sacamos el contexto del mapa seleccionado
        NSManagedObjectContext *moContext = self.map.managedObjectContext;
        
        // Actualiza la información
        for(NSManagedObjectID *pointID in self.checkedPoints) {
            
            MPoint *point = (MPoint *)[moContext objectWithID:pointID];
            
            for(MTag *tag in tagsRemoved) {
                [tag untagPoint:point];
            }
            
            for(MTag *tag in tagsAdded) {
                [tag tagPoint:point];
            }
        }
        
        // Salva los cambios
        [BaseCoreDataService saveChangesInContext:moContext];
        
        // Refresca la informacion con los cambios
        [self _updateFilterData:^{
            [self.filter reset];
        }];
        
    }
    
    // Elimina el conjunto de puntos seleccionados
    [self.checkedPoints removeAllObjects];
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
    [self _updateFilterData:^{
        self.filter.filterTags = [tappedNode.tree allDeepestSelectedChildrenTags];
    }];
    
    // Actualiza la tabla de filtros segun el cambio
    NSSet *expandedTags = tappedNode.tag?[NSSet setWithObject:tappedNode.tag]:[NSSet set];
    [self.tagFilterVC setTagList:self.filter.tagsForPointList selectedTags:self.filter.filterTags expandedTags:expandedTags];
    
    // Actualiza los visores de puntos (lista y mapa)
    [self.checkedPoints removeAllObjects];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _updateFilterData:(void (^)(void)) updatingFilterCode {

    // Indica al controlador activo que prepare informacion para refrescar los puntos (filtro)
    id prevInfo = [self.activeVC pointListWillChange];
    
    // Actualiza el filtro (con posible cambio del contenido de la lista de puntos)
    updatingFilterCode();
    
    // Con la actualizacion puede que el punto seleccionado ya no este presente
    if(self.selectedPoint && ![self.pointList containsObject:self.selectedPoint]) {
        self.selectedPoint = nil;
    }
    
    // Avisa al controlador activo que la lista de puntos ya ha cambiado
    // Le pasa la informacion que este habia preparado para que refresque bien el UI
    [self.activeVC pointListDidChange:prevInfo];
}

//---------------------------------------------------------------------------------------------------------------------
- (TagTreeTableViewController *) _createTagFilterViewController {
    
    TagTreeTableViewController *tagFilterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TagTreeTableViewController"];
    
    tagFilterVC.view.hidden = TRUE;
    tagFilterVC.view.frame = [self _calcTagFilterRect];
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
- (CGRect) _calcTagFilterRect {

    CGRect rect = self.view.frame;
    
    rect.origin.x = self.tagFilterVC.view.hidden ? self.view.frame.size.width : TAGFILTER_X_POS;
    rect.origin.y = self.contentView.frame.origin.y;
    rect.size.width = self.contentView.frame.size.width - TAGFILTER_X_POS;
    rect.size.height = self.contentView.frame.size.height;

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
        
        self.tagFilterVC.view.frame = [self _calcTagFilterRect];
        self.tagFilterVC.view.hidden = FALSE;

        [self.tagFilterVC setTagList:self.filter.tagsForPointList selectedTags:self.filter.filterTags expandedTags:nil];
    }
    
    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.tagFilterVC.view.frame = [self _calcTagFilterRect];
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
    
    // La direccion del scroll depende de si muestra la lista o el mapa
    CGFloat height = self.contentView.bounds.size.height;
    if(toViewController == self.pointMapVC) {
        height = -height;
    }
    
    
    CGRect rect = self.contentView.bounds;
    rect.origin.y = height;
    toViewController.view.frame = rect;
    toViewController.view.bounds = rect;
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
                             
                             [self.activeVC.view layoutIfNeeded];
                         }];
        
    }
}


//---------------------------------------------------------------------------------------------------------------------
- (void) sortMenuItem:(KxMenuItem *)sender
{
    
    [self _updateFilterData:^{
        self.filter.pointOrder = sender.cmdData;
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) moreMenuItemSelected:(KxMenuItem *)sender
{
    NSNumber *selectedCmd = (NSNumber *)sender.cmdData;
    self.multiSelectionDoneCmd = selectedCmd.intValue;
    [self _startMultipleSelection];
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
- (void) _startMultipleSelection {
    
    [self.checkedPoints removeAllObjects];

    CGFloat visibleY = self.navigationController.toolbar.frame.origin.y;
    CGFloat hiddenY = self.view.frame.origin.y+self.view.frame.size.height;
    
    
    frameSetY(self.doneToolbar, hiddenY);
    self.doneToolbar.hidden = FALSE;
    
    [UIView animateWithDuration:0.15
                     animations:^{
                         frameSetY(self.navigationController.toolbar, hiddenY);
                         [self.activeVC startMultiplePointSelection];
                     }
                     completion:^(BOOL finished) {
                         self.navigationController.toolbar.hidden = TRUE;
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
    
    frameSetY(self.navigationController.toolbar, hiddenY);
    self.navigationController.toolbar.hidden = FALSE;
    
    [UIView animateWithDuration:0.15
                     animations:^{
                         frameSetY(self.doneToolbar, hiddenY);
                         [self.activeVC doneMultiplePointSelection];
                     }
                     completion:^(BOOL finished) {
                         self.doneToolbar.hidden = TRUE;
                         [UIView animateWithDuration:0.15
                                          animations:^{
                                              frameSetY(self.navigationController.toolbar, visibleY);
                                          }];
                     }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _cmdTagging {
    
    NSMutableSet *assignedTags = [NSMutableSet set];
    
    // Sacamos el contexto del mapa seleccionado
    NSManagedObjectContext *moContext = self.map.managedObjectContext;

    // Calcula los Tags asignado a los puntos seleccionados
    // Como es una interseccion, el primer punto lo debe tratar de forma especial
    BOOL firstPoint = TRUE;
    for(NSManagedObjectID *pointID in self.checkedPoints) {
        MPoint *point = (MPoint *)[moContext objectWithID:pointID];
        if(firstPoint) {
            firstPoint = FALSE;
            [assignedTags unionSet:point.directNoAutoTags];
        } else {
            [assignedTags intersectSet:point.directNoAutoTags];
        }
    }

    // Activa el editor pasando la informacion
    [self performSegueWithIdentifier: @"editPointsTags" sender: assignedTags];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _cmdDelete {
    
    // Confirma con el usuario que realmente quiere borrar los puntos seleccionados
    [BlockActionSheet showInView:self.view
                       withTitle:@"Delete Selected Points"
               cancelButtonTitle:@"Cancel"
          destructiveButtonTitle:@"Delete"
               otherButtonTitles:nil
                            code:^(BlockActionSheet *actionSheet, NSInteger buttonIndex) {
                                if(buttonIndex==actionSheet.destructiveButtonIndex) {

                                    // Sacamos el contexto del mapa seleccionado
                                    NSManagedObjectContext *moContext = self.map.managedObjectContext;
                                    
                                    // Marca los puntos como borrados
                                    for(NSManagedObjectID *pointID in self.checkedPoints) {
                                        MPoint *point = (MPoint *)[moContext objectWithID:pointID];
                                        [point markAsDeleted:TRUE];
                                    }
                                    
                                    // Salva los cambios
                                    [BaseCoreDataService saveChangesInContext:moContext];
                                    
                                    // Recarga la informacion
                                    [self _updateFilterData:^{
                                        [self.filter reset];
                                    }];
                                    
                                    // Elimina el conjunto de puntos seleccionados
                                    [self.checkedPoints removeAllObjects];
                                }
                            }];
}


@end
