//
//  ItemListViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 30/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __ItemListViewController__IMPL__
#import "ItemListViewController.h"

#import "MPoint.h"
#import "NSManagedObjectContext+Utils.h"

#import "MapEditorViewController.h"
#import "CategoryEditorViewController.h"
#import "PointEditorViewController.h"
#import "GMapSyncViewController.h"
#import "CategorySelectorViewController.h"
#import "VisualMapEditorViewController.h"

#import "TDBadgedCell.h"
#import "BreadcrumbBar.h"
#import "ScrollableToolbar.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define BTN_ID_ADD          1001
#define BTN_ID_DELETE       1002
#define BTN_ID_MOVE_TO      1003
#define BTN_ID_SYNCHRONIZE  1004
#define BTN_ID_VIEW_IN_MAP  1005

#define ITEMSETID_MAPLIST       5001
#define ITEMSETID_POINTLIST     5002




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface ItemListViewController() <UITableViewDelegate, UITableViewDataSource, BreadcrumbBarDelegate>

@property (nonatomic, assign) IBOutlet UITableView *tableViewItemList;
@property (nonatomic, assign) IBOutlet BreadcrumbBar *breadcrumbBar;
@property (nonatomic, assign) IBOutlet ScrollableToolbar *scrollableToolbar;

@property (nonatomic, strong) NSManagedObjectContext *moContext;
@property (nonatomic, strong) NSArray *itemLists;

@property (nonatomic, strong) MMap *selectedMap;
@property (nonatomic, strong) MCategory *selectedCategory;
@property (nonatomic, strong) NSMutableSet *selectedEditingItems;
@property (nonatomic, assign) BOOL multiselection;
@property (nonatomic, assign) BOOL canSelectCategories;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation ItemListViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (ItemListViewController *) itemListViewControllerWithContext:(NSManagedObjectContext *)moContext {

    ItemListViewController *me = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
    me.moContext = moContext;
    return me;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
    self.selectedEditingItems = [NSMutableSet set];
    self.breadcrumbBar.delegate = self;
    [self.breadcrumbBar addItemWithTitle:nil image:[UIImage imageNamed:@"btn-home"] data:nil];

    
    self.tableViewItemList.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"myTableBg"]];
    self.tableViewItemList.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"myTableBgSepLine"]];

    [self _navigateToSelectedItem:nil addBreadCrumb:NO goingBack:NO];

}

//---------------------------------------------------------------------------------------------------------------------
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}




//=====================================================================================================================
#pragma mark -
#pragma mark <BreadcrumbBarDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void) itemRemovedFromBreadcrumbBar:(BreadcrumbBar *)sender
                     removedItemTitle:(NSString *)title
                      removedItemData:(id)data {
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) activeItemUptatedInBreadcrumbBar:(BreadcrumbBar *)sender
                          activeItemTitle:(NSString *)title
                           activeItemData:(id)data
                        removedItemsCount:(NSUInteger)removedItemsCount {
    
    
    MBaseEntity *item = (MBaseEntity *)data;
    [self _navigateToSelectedItem:item addBreadCrumb:NO goingBack:YES];
}



//=====================================================================================================================
#pragma mark -
#pragma mark <ScrollableToolbar> action methods
//---------------------------------------------------------------------------------------------------------------------
- (void) addNewEntity:(UIButton *)sender {
    
    EntityEditorViewController *editor;
    
    if(self.selectedMap == nil) {
        editor = [MapEditorViewController editorWithNewMapInContext:self.moContext];
    } else {
        editor = [PointEditorViewController editorWithNewPointInContext:self.moContext associatedMap:self.selectedMap associatedCategory:self.selectedCategory];
    }
    
    [editor showModalWithController:self startEditing:NO closeSavedCallback:^(MBaseEntity *entity) {
        
        // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
        // mejor recargar la informacion de nuevo
        [self _loadItemListScrollingTo:entity animated:YES goingBack:NO];
    }];

}

//---------------------------------------------------------------------------------------------------------------------
- (void) deleteEntities:(UIButton *)sender {
    
    // Se prepara para editar
    [self _startToolbarEditingWithMultiselection:YES canSelectCategories:YES];
    
    // Pone la barra en ediccion con la opcion indicada
    [self.scrollableToolbar activateEditModeForItemWithTagID:BTN_ID_DELETE animated:YES confirmBlock:^{
        
        NSMutableArray *indexPathsToRemove = [NSMutableArray array];
        
        // Borra todos los elementos seleccionados del modelo y la tabla
        [self.selectedEditingItems enumerateObjectsUsingBlock:^(MBaseEntity *item, BOOL *stop) {

            // Las categorias tienen un borrado especial
            if([item isKindOfClass:[MCategory class]]) {
                [((MCategory *)item) deletePointsInMap:self.selectedMap];
            } else {
                [item markAsDeleted:true];
            }

            // Prepara el elemento para ser borrado visualmente de la tabla
            NSUInteger index = [self.itemLists indexOfObject:item];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [indexPathsToRemove addObject:indexPath];
        }];

        // Persiste todos los cambios
        [self.moContext saveChanges];
        
        // Elimina los elementos del array actual
        NSMutableArray *reducedItems = [NSMutableArray arrayWithArray:self.itemLists];
        [reducedItems removeObjectsInArray:self.selectedEditingItems.allObjects];
        self.itemLists = reducedItems;

        // Elimina el elemento de la tabla
        [self.tableViewItemList deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationAutomatic];

        // Sale del modo de edicion
        [self _endToolbarEditing];

    } cancelBlock:^{
        
        // Sale del modo de edicion
        [self _endToolbarEditing];
    }];
}
//---------------------------------------------------------------------------------------------------------------------
- (void) moveEntities:(UIButton *)sender {
    
        
    // Se prepara para editar
    [self _startToolbarEditingWithMultiselection:YES canSelectCategories:YES];
    
    
    // Pone la barra en ediccion con la opcion indicada
    [self.scrollableToolbar activateEditModeForItemWithTagID:BTN_ID_MOVE_TO animated:YES confirmBlock:^{
        
        // Muestra el selector de categorias para indicar el destino
        CategorySelectorViewController *selector = [CategorySelectorViewController categoriesSelectorInContext:self.moContext
                                                                                                   selectedMap:self.selectedMap
                                                                                           currentSelectedCats:nil
                                                                                                multiSelection:NO];

        // Muestra el selector de categorias
        __block __weak ItemListViewController *weakSelf = self;
        [selector showModalWithController:self closeCallback:^(NSArray *selectedCategories) {
            
            // Recoge la categoria selecionada
            // NOTA: Seleccionar "NADA" implica mover al raiz
            MCategory *destCategory = selectedCategories.count>0 ? selectedCategories[0] : nil;

            
            // No se procesara si el destino es igual a la actual
            if(weakSelf.selectedCategory.internalIDValue==destCategory.internalIDValue) {
                // Aqui deberia dar un aviso al usuario
            } else {
                
                // Itera los elementos seleccionados moviendolos a la categoria destino
                for(MBaseEntity *item in weakSelf.selectedEditingItems) {
                    
                    // El movimiento depende del tipo de elemento
                    if([item isKindOfClass:[MCategory class]]) {
                        [((MCategory *)item) transferToParent:destCategory inMap:self.selectedMap];
                    } else {
                        MPoint *point = (MPoint *)item;
                        [point removeFromCategory:self.selectedCategory];
                        if(destCategory) {
                            [point addToCategory:destCategory];
                        }
                    }
                }
                
                // Persiste todos los cambios
                [weakSelf.moContext saveChanges];
                
                // Recarga toda la tabla puesto que ha habido cambios importantes
                [weakSelf _loadItemListScrollingTo:nil animated:YES goingBack:NO];
            }
            
            // Sale del modo de edicion
            [self _endToolbarEditing];
        }];
        
    } cancelBlock:^{
        
        // Sale del modo de edicion
        [self _endToolbarEditing];
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) synchronizeMaps:(UIButton *)sender {
    
    GMapSyncViewController *controller = [GMapSyncViewController gmapSyncViewControllerWithContext:self.moContext];
    [controller showModalWithController:self closeCallback:^{
        [self _loadItemListScrollingTo:nil animated:YES goingBack:NO];
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewInMap:(UIButton *)sender {

    // Consigue todos los puntos en el mapa y categoria(recursivo) seleccionados
    NSArray *points = [MPoint pointsInMap:self.selectedMap andCategoryRecursive:self.selectedCategory];
    
    // Los muestra en el mapa
    [VisualMapEditorViewController showPoints:points withContext:self.moContext controller:self modifiedCallback:^{
        
        // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
        // mejor recargar la informacion de nuevo
        [self _loadItemListScrollingTo:nil animated:YES goingBack:NO];
        
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _startToolbarEditingWithMultiselection:(BOOL)multiselection canSelectCategories:(BOOL)canSelectCategories {

    // Se prepara para editar las entidades desde una accion de la barra
    self.breadcrumbBar.enabled = NO;
    self.multiselection = multiselection;
    self.canSelectCategories = canSelectCategories;
    self.lastSelectedIndexPath=nil;
    
    // Hay que reajustar la informacion de seleccion que tienen los elementos que ahora estan visibles
    [self.tableViewItemList.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {

        MBaseEntity *itemShown = (MBaseEntity *)[self.itemLists objectAtIndex:[indexPath indexAtPosition:1]];
        TDBadgedCell *cell = (TDBadgedCell *)[self.tableViewItemList cellForRowAtIndexPath:indexPath];
        [self _setLeftCheckStatusFor:itemShown cell:cell];
    }];

    // Pasa la tabla a edicion
    [self.tableViewItemList setEditing:YES animated:YES];

}

//---------------------------------------------------------------------------------------------------------------------
- (void) _endToolbarEditing {

    // Reestablece todo despues de terminar de editar
    self.breadcrumbBar.enabled = YES;
    [self.selectedEditingItems removeAllObjects];
    self.lastSelectedIndexPath=nil;
    [self.tableViewItemList setEditing:NO animated:YES];
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

    EntityEditorViewController *editor;

    // Carga el editor dependiendo de que esta seleccionado
    MBaseEntity *selectedItem = self.itemLists[[indexPath indexAtPosition:1]];
    switch (selectedItem.entityType) {
        case MET_MAP:
            editor = [MapEditorViewController editorWithMap:(MMap *)selectedItem moContext:self.moContext];
            break;
            
        case MET_CATEGORY:
            editor = [CategoryEditorViewController editorWithCategory:(MCategory *)selectedItem associatedMap:self.selectedMap  moContext:self.moContext];
            break;
            
        case MET_POINT:
            // Aqui no hace falta
            break;
        
        default:
            [[[NSException alloc] initWithName:@"Invalid Entity Type" reason:@"Unexpected entity type was tapped" userInfo:nil] raise];
            break;
    }
    
    [editor showModalWithController:self startEditing:NO closeSavedCallback:^(MBaseEntity *entity) {
        
        // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
        // mejor recargar la informacion de nuevo
        [self _loadItemListScrollingTo:entity animated:YES goingBack:NO];
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MBaseEntity *selectedItem = self.itemLists[[indexPath indexAtPosition:1]];
    
    
    // El comportamiento depende de si esta en ediccion o no
    if(tableView.isEditing) {

        // Chequea si el elemento en cuestion se puede seleccionar
        if(!self.canSelectCategories && selectedItem.entityType == MET_CATEGORY) {
            return nil;
        }
        
        // Cambia el estado de seleccion
        if([self.selectedEditingItems containsObject:selectedItem]) {
            [self.selectedEditingItems removeObject:selectedItem];
        } else {
            if(!self.multiselection) {
                // Elimina lo que hubiese selecionado de antes
                [self.selectedEditingItems removeAllObjects];
                if(self.lastSelectedIndexPath!=nil) {
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.lastSelectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            [self.selectedEditingItems addObject:selectedItem];
        }
        // Recarga los elementos afectados
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.lastSelectedIndexPath = indexPath;
        
        // Actualiza el boton de confirmacion
        [self.scrollableToolbar enableConfirmButton:self.selectedEditingItems.count>0 count:self.selectedEditingItems.count];
        
    } else {
        
        // Navega, recargando la informacion de la tabla, dependiendo de que se ha seleccionado
        switch (selectedItem.entityType) {
            case MET_MAP:
                [self _navigateToSelectedItem:selectedItem addBreadCrumb:YES goingBack:NO];
                break;
                
            case MET_CATEGORY:
                [self _navigateToSelectedItem:selectedItem addBreadCrumb:YES goingBack:NO];
                break;
                
            case MET_POINT: {
                EntityEditorViewController *editor = [PointEditorViewController editorWithPoint:(MPoint *)selectedItem  moContext:self.moContext];
                [editor showModalWithController:self startEditing:NO closeSavedCallback:^(MBaseEntity *entity) {
                    
                    // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
                    // mejor recargar la informacion de nuevo
                    [self _loadItemListScrollingTo:entity animated:YES goingBack:NO];
                }];
                }
                break;
                
            default:
                break;
        }
    }

    // No dejamos nada seleccionado
    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemLists.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";
    
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
    
    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _navigateToSelectedItem:(MBaseEntity *)selectedEntity addBreadCrumb:(BOOL)addBreadCrumb goingBack:(BOOL)goingBack {
 
    // Solo se contempla que sea nulo o un mapa  o una categoria
    if(selectedEntity==nil) {
        self.selectedMap = nil;
        self.selectedCategory =nil;
    } else if(selectedEntity.entityType == MET_MAP) {
        self.selectedMap = (MMap *)selectedEntity;
        self.selectedCategory =nil;
    } else {
        self.selectedCategory = (MCategory *)selectedEntity;
    }
    
    if(addBreadCrumb) {
        [self.breadcrumbBar addItemWithTitle:selectedEntity.name image:nil data:selectedEntity];
    }
    
    [self _loadItemListScrollingTo:nil animated:YES goingBack:addBreadCrumb];
    
    [self _adjustToolBarForSelectedItems:goingBack];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _adjustToolBarForSelectedItems:(BOOL)goingBack {
    
    // Calcula que barra mostrar
    NSArray *items = self.selectedMap==nil ? self.tbItemsForMapList : self.tbItemsForPointList;
    NSUInteger itemSetID = self.selectedMap==nil ? ITEMSETID_MAPLIST : ITEMSETID_POINTLIST;
    // Solo habra animacion de la toobar cuando se cambie entre lista de mapas y los elementos de uno
    BOOL animated = goingBack ? self.breadcrumbBar.count<2 : self.breadcrumbBar.count<3;
    [self.scrollableToolbar setItems:items itemSetID:itemSetID animated:animated];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setLeftCheckStatusFor:(MBaseEntity *)item cell:(TDBadgedCell *)cell {

    if(!self.canSelectCategories && item.entityType==MET_CATEGORY) {
        cell.leftCheckState = ST_DISABLED;
    } else {
        cell.leftCheckState = [self.selectedEditingItems containsObject:item] ? ST_CHECKED : ST_UNCHECKED;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) tbItemsForMapList {
    
    NSArray *__tbItemsForMapList = [NSArray arrayWithObjects:
                                    [STBItem itemWithTitle:@"Add Map" image:[UIImage imageNamed:@"btn-edit"] tagID:BTN_ID_ADD target:self action:@selector(addNewEntity:)],
                                    [STBItem itemWithTitle:@"Delete" image:[UIImage imageNamed:@"btn-delete"] tagID:BTN_ID_DELETE target:self action:@selector(deleteEntities:)],
                                    [STBItem itemWithTitle:@"Synchronize" image:[UIImage imageNamed:@"btn-synchronize"] tagID:BTN_ID_SYNCHRONIZE target:self action:@selector(synchronizeMaps:)],
                                    nil];
    return __tbItemsForMapList;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) tbItemsForPointList {
    
    NSArray *__tbItemsForPointList = [NSArray arrayWithObjects:
                                      [STBItem itemWithTitle:@"Add Point" image:[UIImage imageNamed:@"btn-edit"] tagID:BTN_ID_ADD target:self action:@selector(addNewEntity:)],
                                      [STBItem itemWithTitle:@"Move" image:[UIImage imageNamed:@"btn-move-to"] tagID:BTN_ID_MOVE_TO target:self action:@selector(moveEntities:)],
                                      [STBItem itemWithTitle:@"In Map" image:[UIImage imageNamed:@"btn-map"] tagID:BTN_ID_VIEW_IN_MAP target:self action:@selector(viewInMap:)],
                                      [STBItem itemWithTitle:@"Synchronize" image:[UIImage imageNamed:@"btn-synchronize"] tagID:BTN_ID_SYNCHRONIZE target:self action:@selector(synchronizeMaps:)],
                                      [STBItem itemWithTitle:@"Delete" image:[UIImage imageNamed:@"btn-delete"] tagID:BTN_ID_DELETE target:self action:@selector(deleteEntities:)],
                                      nil];
    return __tbItemsForPointList;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _loadItemListScrollingTo:(MBaseEntity *)selectedEntity animated:(BOOL)animated goingBack:(BOOL)goingBack {
    
    // De momento, vamos a presuponer que las consultas son lo suficientemente rapidas como para hacerlas en el hilo principal
    
    NSArray *loadedItemList;
    
    // Si el mapa es nulo, se cargan todos los mapas
    if(self.selectedMap == nil) {
        loadedItemList = [MMap allMapsInContext:self.moContext includeMarkedAsDeleted:false];
    } else {
        // Se cargan todas las categorias y puntos con los datos de filtrado
        NSArray *cats = [MCategory categoriesWithPointsInMap:self.selectedMap parentCategory:self.selectedCategory];
        NSArray *points = [MPoint pointsInMap:self.selectedMap andCategory:self.selectedCategory];
        NSMutableArray *allItems = [NSMutableArray arrayWithArray:cats];
        [allItems addObjectsFromArray:points];
        loadedItemList = allItems;
    }
    
       
    // Se carga la lista en las propiedades y la tabla
    self.itemLists = loadedItemList;
    UITableViewRowAnimation animation;
    if(animated) {
        animation = goingBack ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight;
    } else {
        animation = UITableViewRowAnimationNone;
    }
        
    [self.tableViewItemList reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];
    
    
    // Si se indico un elemento a mostrar haciendo scroll, lo busca y lo muestra
    if(selectedEntity != nil) {
        for(NSInteger n = 0; n < loadedItemList.count; n++) {
            MBaseEntity *item = loadedItemList[n];
            if(item.internalIDValue==selectedEntity.internalIDValue) {
                [self. tableViewItemList scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:n inSection:0]
                                               atScrollPosition:UITableViewScrollPositionNone
                                                       animated:TRUE];
                break;
            }
        }
    }
    
    
}

@end

