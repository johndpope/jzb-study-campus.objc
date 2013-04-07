//
//  MainViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 30/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __MainViewController__IMPL__
#import "MainViewController.h"

#import "MMap.h"
#import "MPoint.h"
#import "MCategory.h"
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
@interface MainViewController() <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, EntityEditorDelegate>

@property (nonatomic, assign) IBOutlet UITableView *tableViewItemList;
@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;


@property (nonatomic, strong) NSArray *itemLists;
@property (nonatomic, strong) MMap *selectedMap;
@property (nonatomic, strong) MCategory *selectedCategory;


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MainViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (MainViewController *) mainViewController {
    
    MainViewController *me = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
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
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(navBarAddEntity:)];
    self.navigationBar.topItem.rightBarButtonItem = addButton;
    [self _loadItemListForMap:nil category:nil selectedEntity:nil];
    
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
//- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    if(self.selectedCategory) {
        [self _loadItemListForMap:self.selectedMap category:self.selectedCategory.parent selectedEntity:self.selectedCategory];
    } else {
        [self _loadItemListForMap:nil category:nil selectedEntity:self.selectedMap];
    }
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) navBarAddEntity:(UIBarButtonItem *)sender {
    
    NSManagedObjectContext *moc = [BaseCoreData moChildContext];
    
    if(self.selectedMap == nil) {
        MMap *newMap = [MMap emptyMapWithName:@"" inContext:moc];
        [MapEditorViewController startEditingMap:newMap delegate:self];
    } else {
        MMap *copiedMap = copiedMap = (MMap *)[moc objectWithID:self.selectedMap.objectID];

        MCategory *copiedCategory = nil;
        if(self.selectedCategory!=nil) copiedCategory = (MCategory *)[moc objectWithID:self.selectedCategory.objectID];
        
        MPoint *newPoint = [MPoint emptyPointWithName:@"" inMap:copiedMap withCategory:copiedCategory];
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
    [self _loadItemListForMap:self.selectedMap category:self.selectedCategory selectedEntity:savedEntity];

    
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

    NSUInteger index = [indexPath indexAtPosition:1];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MMapBaseEntity *item = (MMapBaseEntity *)self.itemLists[index];
        
        // Esto no funciona con las categorias
        if([item isKindOfClass:[MCategory class]]) {
            [((MCategory *)item) deletePointsInMap:self.selectedMap];
        } else {
            [item updateDeleteMark:true];
        }
        
        [BaseCoreData saveContext];
        
        NSMutableArray *reducedItems = [NSMutableArray arrayWithArray:self.itemLists];
        [reducedItems removeObjectAtIndex:index];
        self.itemLists = reducedItems;
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    MBaseEntity *selectedItem = self.itemLists[[indexPath indexAtPosition:1]];
    
    // Carga la tabla dependiendo de que esta seleccionado
    switch (selectedItem.entityType) {
        case MET_MAP:
            [MapEditorViewController startEditingMap:(MMap *)selectedItem delegate:self];
            break;
            
        case MET_CATEGORY:
            [CategoryEditorViewController startEditingCategory:(MCategory *)selectedItem inMap:self.selectedMap delegate:self];
            break;
            
        case MET_POINT:
            [PointEditorViewController startEditingPoint:(MPoint *)selectedItem delegate:self];
            break;
            
        default:
            break;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MBaseEntity *selectedItem = self.itemLists[[indexPath indexAtPosition:1]];
    
    // Carga la tabla dependiendo de que esta seleccionado
    switch (selectedItem.entityType) {
        case MET_MAP:
            [self _loadItemListForMap:(MMap *)selectedItem category:nil selectedEntity:nil];
            break;
            
        case MET_CATEGORY:
            [self _loadItemListForMap:self.selectedMap category:(MCategory *)selectedItem selectedEntity:nil];
            break;
            
        case MET_POINT:
            // ¿AQUI QUE HACEMOS?
            break;
            
        default:
            break;
    }
    
    // Lo establece en la barra de navegacion
    if(selectedItem.entityType != MET_POINT) {
        UINavigationItem *newNavItem = [[UINavigationItem alloc] initWithTitle:selectedItem.name];
        [self.navigationBar pushNavigationItem:newNavItem animated:YES];
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(navBarAddEntity:)];
        self.navigationBar.topItem.rightBarButtonItem = addButton;
    }

    
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
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; //UITableViewCellAccessoryDisclosureIndicator
    }
    
    
    MBaseEntity *itemToShow = (MBaseEntity *)[self.itemLists objectAtIndex:[indexPath indexAtPosition:1]];
    
    cell.textLabel.text=itemToShow.name;
    cell.detailTextLabel.text=@"";
    cell.badgeString=itemToShow.strViewCount;
    cell.imageView.image = itemToShow.entityImage;
    
    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) _loadItemListForMap:(MMap *)mapToUse category:(MCategory *)parentCat   selectedEntity:(MBaseEntity *)selectedEntity {
    
    // De momento, vamos a presuponer que las consultas son lo suficientemente rapidas como para hacerlas en el hilo principal
    
    NSArray *loadedItemList;
    
    // Si el mapa es nulo, se cargan todos los mapas
    if(mapToUse == nil) {
        NSManagedObjectContext *moc = [BaseCoreData moContext];
        loadedItemList = [MMap allMapsInContext:moc includeMarkedAsDeleted:false];
    } else {
        // Se cargan todas las categorias y puntos con los datos de filtrado
        NSArray *cats = [MCategory categoriesWithPointsInMap:mapToUse parentCategory:parentCat];
        NSArray *points = [MPoint pointsInMap:mapToUse category:parentCat];
        NSMutableArray *allItems = [NSMutableArray arrayWithArray:cats];
        [allItems addObjectsFromArray:points];
        loadedItemList = allItems;
    }
    
       
    // Se carga la lista en las propiedades y la tabla
    self.selectedMap = mapToUse;
    self.selectedCategory = parentCat;
    self.itemLists = loadedItemList;
    [self.tableViewItemList reloadData];
    
    
    // Si se indico un elemento a seleccionar, lo busca y lo marca como seleccionado
    if(selectedEntity != nil) {
        NSManagedObjectID *objID = selectedEntity.objectID;
        for(NSInteger n = 0; n < loadedItemList.count; n++) {
            MMapBaseEntity *item = loadedItemList[n];
            if([item.objectID isEqual:objID]) {
                [self.tableViewItemList selectRowAtIndexPath:[NSIndexPath indexPathForItem:n inSection:0]
                                                    animated:YES
                                              scrollPosition:UITableViewScrollPositionTop];
                break;
            }
        }
    }
    
    
}

@end

