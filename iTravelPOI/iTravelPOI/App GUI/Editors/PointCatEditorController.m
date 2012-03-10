//
//  PointCatEditorController.m
//  iTravelPOI
//
//  Created by jzarzuela on 19/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PointCatEditorController.h"
#import "ModelService.h"
#import "MEMap.h"
#import "MECategory.h"
#import "MEPoint.h"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface TCatListItemInfo : NSObject {
@public
    BOOL wasSelected;
    BOOL isSelected;
    MECategory *category;
}

- (id) initWithCategory:(MECategory *)cat forEntity:(MEBaseEntity *)entity;

@end

@implementation TCatListItemInfo

//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCategory:(MECategory *)cat forEntity:(MEBaseEntity *)entity {
    
    self = [super init];
    if (self) {
        self->category = cat;
        SEL categoryByGID = @selector(categoryByGID:);
        MECategory *categorizingCat = [entity performSelector:categoryByGID withObject:cat.GID];
        self->wasSelected = self->isSelected = (categorizingCat != nil);
    }
    return self;
}

@end




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface PointCatEditorController ()

@property (nonatomic, retain) NSArray *catListInfo;


@property (nonatomic, retain) IBOutlet UINavigationItem *itemTitle;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveBtn;
@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UITextView *desc;
@property (nonatomic, retain) IBOutlet UISwitch *isPoint;
@property (nonatomic, retain) IBOutlet UILabel *isPointLabel;
@property (nonatomic, retain) IBOutlet UITableView *categories;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *icons;


@end




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation PointCatEditorController


@synthesize catListInfo = _catListInfo;


@synthesize scrollView = _scrollView;
@synthesize isPoint = _isPoint;
@synthesize isPointLabel = _isPointLabel;
@synthesize entity = _entity;
@synthesize map = _map;
@synthesize delegate = _delegate;

@synthesize name = _name;
@synthesize desc = _desc;
@synthesize itemTitle = _itemTitle;
@synthesize saveBtn = _saveBtn;
@synthesize icons = _icons;
@synthesize categories = _categories;


static NSString *iconURLs[3] = {
    @"http://maps.gstatic.com/mapfiles/ms2/micons/blue-dot.png",
    @"http://maps.gstatic.com/mapfiles/ms2/micons/green-dot.png",
    @"http://maps.gstatic.com/mapfiles/ms2/micons/yellow-dot.png"};


int _getIndexFromIconURL(NSString *url) {
    for(int n=0;n<3;n++) {
        if([url isEqualToString:iconURLs[n]]) {
            return n;
        }
    }
    return 0;
}

NSString * _getIconURLFromIndex(int n) {
    if(n>=0 && n<3) {
        return iconURLs[n];
    } else {
        return iconURLs[0];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _getCategoriesListInfo {
    
    NSMutableArray *cats = [NSMutableArray array];
    for(MECategory *cat in self.map.categories) {
        TCatListItemInfo *itemInfo = [[TCatListItemInfo alloc] initWithCategory:cat forEntity:self.entity];
        [cats addObject:itemInfo];
        [itemInfo release];
    }
    self.catListInfo = [[cats copy] autorelease];
}

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
- (void)viewWillAppear:(BOOL)animated {
    
    // Redondea los bordes de la caja de texto
    self.desc.layer.cornerRadius = 5.0;
    self.desc.clipsToBounds = YES;
    
    // Si nos han puesto una entidad es que quieren editarla y no es nueva creacion
    if(self.entity) {
        self.isPoint.hidden = YES;
        self.isPointLabel.hidden = YES;
        self.itemTitle.title = @"edit";
        self.name.text = self.entity.name;
        if([self.name.text length]>1) {
            self.saveBtn.enabled = true;
        } else {
            self.saveBtn.enabled = false;
        }
        self.desc.text = self.entity.desc;
        self.icons.selectedSegmentIndex = _getIndexFromIconURL(self.entity.icon.url);
        [self _getCategoriesListInfo];
        [self.categories reloadData];
    }
    
    // Es necesario establecer el tamaño de la tabla para que se vean todos los elementos
    CGRect r = self.categories.frame;
    CGSize s = self.categories.contentSize;
    r.size.height =  s.height;
    self.categories.frame = r;
    r.origin.x = r.origin.y = 0;
    self.categories.bounds = r;
    
    // Establecemos el tamaño maximo para que funcione el scroll bien y se vea la tabla
    self.scrollView.contentSize = CGSizeMake(320,680+s.height); //¿¿¿porque 680 ???!!!!
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc { 
    
    [_catListInfo release];

    [_itemTitle release];
    [_saveBtn release];
    [_name release];
    [_desc release];
    [_isPoint release];
    [_isPointLabel release];
    [_categories release];
    [_scrollView release];
    [_icons release];

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
    // Do any additional setup after loading the view from its nib.
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [self setName:nil];
    [self setDesc:nil];
    [self setIcons:nil];
    [self setCategories:nil];
    [self setSaveBtn:nil];
    [self setTitle:nil];
    [self setItemTitle:nil];
    [self setScrollView:nil];
    [self setIsPoint:nil];
    [self setIsPointLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





//=====================================================================================================================
#pragma mark - View lifecycle
//=====================================================================================================================



//---------------------------------------------------------------------------------------------------------------------
- (IBAction)cancelAction:(id)sender {
    if(self.delegate) {
        [self.delegate pointCatEditCancel:self];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)saveAction:(id)sender {
    
    if(self.delegate) {
        // Si es una entidad nueva hay que crearla.
        if(!self.entity) {
            self.entity = [self.delegate createNewInstanceForMap:self.map isPoint:self.isPoint.on];
        }
        
        // Se actualiza la entidad con la informacion de la pantalla
        self.entity.name = self.name.text;
        self.entity.desc = self.desc.text;
        self.entity.icon = [GMapIcon iconForURL:_getIconURLFromIndex(self.icons.selectedSegmentIndex)];
        
        SEL addCategory = @selector(addCategory:);
        SEL removeCategory = @selector(removeCategory:);
        for(TCatListItemInfo *catInfoElement in self.catListInfo) {
            // Solo actuamos en caso de cambio
            if(catInfoElement->isSelected != catInfoElement->wasSelected) {
                if(catInfoElement->isSelected) {
                    [self.entity performSelector:addCategory withObject:catInfoElement->category];
                } else {
                    [self.entity performSelector:removeCategory withObject:catInfoElement->category];
                }
                
            }
        }
        
        // Avisa a su delegate de que se debe salvar la entidad actualizada
        [self.delegate pointCatEditSave:self entity:self.entity];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)nameChanged:(id)sender {
    if([self.name.text length]>1) {
        self.saveBtn.enabled = true;
    } else {
        self.saveBtn.enabled = false;
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
    return [self.catListInfo count];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TCatListItemInfo *item = [self.catListInfo objectAtIndex:indexPath.row];
    item->isSelected = !item->isSelected;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *catCellIdentifier = @"catCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:catCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:catCellIdentifier] autorelease];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell
    TCatListItemInfo *item = [self.catListInfo objectAtIndex:indexPath.row];
    cell.textLabel.text = item->category.name;
    if(item->isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
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
/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
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


@end
