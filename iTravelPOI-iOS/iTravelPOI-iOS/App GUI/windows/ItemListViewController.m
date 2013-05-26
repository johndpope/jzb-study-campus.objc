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
#import "BaseCoreData.h"

#import "EntityEditorDelegate.h"
#import "MapEditorViewController.h"
#import "CategoryEditorViewController.h"
#import "PointEditorViewController.h"


#import "TDBadgedCell.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface ItemListViewController() <UITableViewDelegate, UITableViewDataSource, EntityEditorDelegate>

@property (nonatomic, assign) IBOutlet UITableView *tableViewItemList;


@property (nonatomic, strong) NSArray *itemLists;

@property (nonatomic, strong) MMap *selectedMap;
@property (nonatomic, strong) MCategory *selectedCategory;



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
+ (void) pushItemListViewControllerWithMap:(MMap *)map category:(MCategory *)category navController:(UINavigationController*) navController {

    ItemListViewController *me = [ItemListViewController itemListViewController];
    me.selectedMap = map;
    me.selectedCategory = category;
    me.title = category!=nil?category.name:(map!=nil?map.name:@"Map List");
    [navController pushViewController:me animated:TRUE];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:me action:@selector(navBarAddEntity:)];
    navController.navigationBar.topItem.rightBarButtonItem = addButton;
}

//---------------------------------------------------------------------------------------------------------------------
+ (ItemListViewController *) itemListViewController {

    ItemListViewController *me = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
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
    [self _loadItemListScrollingTo:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableViewItemList = nil;
    self.itemLists = nil;
    self.selectedMap = nil;
    self.selectedCategory = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    
    // Un ViewController posterior podría haber borrado la lista porque se edito algo
    // Se debe recargar de nuevo la lista con datos actualizados con el cambio
    if(self.itemLists==nil) {
        [self _loadItemListScrollingTo:nil];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UINavigationBarDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void) navBarAddEntity:(UIBarButtonItem *)sender {
    
    NSManagedObjectContext *moc = [BaseCoreData moChildContext];
    
    if(self.selectedMap == nil) {
        MMap *newMap = [MMap emptyMapWithName:@"" inContext:moc];
        [MapEditorViewController startEditingMap:newMap delegate:self];
    } else {
        MMap *copiedMap = (MMap *)[moc objectWithID:self.selectedMap.objectID];

        MCategory *copiedCategory = nil;
        if(self.selectedCategory!=nil) copiedCategory = (MCategory *)[moc objectWithID:self.selectedCategory.objectID];
        
        MPoint *newPoint = [MPoint emptyPointWithName:@"" inMap:copiedMap];
        if(self.selectedCategory) {
            MCategory *copiedCat = (MCategory *)[moc objectWithID:self.selectedCategory.objectID];
            [newPoint addToCategory:copiedCat];
        }
        [PointEditorViewController startEditingPoint:newPoint delegate:self];
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark <EntityEditorDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) editorSaveChanges:(UIViewController<EntityEditorViewController> *)senderEditor modifiedEntity:(MBaseEntity *)modifiedEntity {

    // Almacena la informacion del contexto hijo al padre y de este a disco
    [BaseCoreData saveMOContext:modifiedEntity.managedObjectContext saveAll:TRUE];
    
    // Un cambio de nombre al editar o un nuevo elemento hace que la lista se desordene
    // mejor recargar la informacion de nuevo
    MBaseEntity *savedEntity = (MBaseEntity *)[[BaseCoreData moContext] objectWithID:modifiedEntity.objectID];
    [self _loadItemListScrollingTo:savedEntity];

    // Avisa al stack de que tienen que refrescar ellos tambien borrandoles la informacion que tenian en ese momento
    [self _warnParentControllersToReloadData];
    
    // Indica que se cierre el editor
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) editorCancelChanges:(UIViewController<EntityEditorViewController> *)senderEditor {

    // Indica que se cierre el editor
    return TRUE;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MBaseEntity *item = (MBaseEntity *)self.itemLists[indexPath.row];
        
        // Esto no funciona con las categorias
        if([item isKindOfClass:[MCategory class]]) {
            [((MCategory *)item) deletePointsInMap:self.selectedMap];
        } else {
            [item markAsDeleted:true];
        }
        
        [BaseCoreData saveContext];
        
        NSMutableArray *reducedItems = [NSMutableArray arrayWithArray:self.itemLists];
        [reducedItems removeObjectAtIndex:indexPath.row];
        self.itemLists = reducedItems;
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // Avisa al stack de que tienen que refrescar ellos tambien borrandoles la informacion que tenian en ese momento
        [self _warnParentControllersToReloadData];

    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    MBaseEntity *selectedItem = self.itemLists[[indexPath indexAtPosition:1]];
    
    // Se crea una copia temporal en un contexto hijo para que se puedan desechar los cambios si se cancela
    NSManagedObjectContext *moc = [BaseCoreData moChildContext];
    MBaseEntity *copyOfItem = (MBaseEntity *)[moc objectWithID:selectedItem.objectID];
    MMap *copyOfMap = nil;

    // Carga la tabla dependiendo de que esta seleccionado
    switch (copyOfItem.entityType) {
        case MET_MAP:
            [MapEditorViewController startEditingMap:(MMap *)copyOfItem delegate:self];
            break;
            
        case MET_CATEGORY:
            copyOfMap = (MMap *)[moc objectWithID:self.selectedMap.objectID];
            [CategoryEditorViewController startEditingCategory:(MCategory *)copyOfItem inMap:copyOfMap delegate:self];
            break;
            
        case MET_POINT:
            [PointEditorViewController startEditingPoint:(MPoint *)copyOfItem delegate:self];
            break;
            
        default:
            break;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MBaseEntity *selectedItem = self.itemLists[[indexPath indexAtPosition:1]];
    
    // Carga la tabla dependiendo de que esta seleccionado
    switch (selectedItem.entityType) {
        case MET_MAP:
            [ItemListViewController pushItemListViewControllerWithMap:(MMap *)selectedItem category:nil navController:self.navigationController];
            break;
            
        case MET_CATEGORY:
            [ItemListViewController pushItemListViewControllerWithMap:self.selectedMap category:(MCategory *)selectedItem navController:self.navigationController];
            break;
            
        case MET_POINT:
            // ¿AQUI QUE HACEMOS?
            break;
            
        default:
            break;
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
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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
- (void) _warnParentControllersToReloadData {
    
    // Avisa al stack de que tienen que refrescar ellos tambien borrandoles la informacion que tenian en ese momento
    NSArray *viewControllers = self.navigationController.viewControllers;
    for(UIViewController *controller in viewControllers) {
        if(controller!=self && [controller isKindOfClass:[ItemListViewController class]]){
            ((ItemListViewController *)controller).itemLists = nil;
            [((ItemListViewController *)controller).tableViewItemList reloadData];
        }
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _loadItemListScrollingTo:(MBaseEntity *)selectedEntity {
    
    // De momento, vamos a presuponer que las consultas son lo suficientemente rapidas como para hacerlas en el hilo principal
    
    NSArray *loadedItemList;
    
    // Si el mapa es nulo, se cargan todos los mapas
    if(self.selectedMap == nil) {
        NSManagedObjectContext *moc = [BaseCoreData moContext];
        loadedItemList = [MMap allMapsInContext:moc includeMarkedAsDeleted:false];
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
    [self.tableViewItemList reloadData];
    
    
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

