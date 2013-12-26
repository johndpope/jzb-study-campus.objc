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

#import "OpenInActionSheetViewController.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface POIListViewController () <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, assign) IBOutlet UIBarButtonItem* filterButtonItem;
@property (nonatomic, assign) IBOutlet UIToolbar *toolBar;
@property (nonatomic, assign) IBOutlet UITableView *poisTable;

@property (nonatomic, strong) NSArray *poiList;
@property (nonatomic, strong) NSMutableSet *filter;


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
    
    // Do any additional setup after loading the view from its nib
    if(self.moContext==nil) {
        self.moContext = BaseCoreDataService.moContext;
    }
    if(!self.filter) self.filter = [NSMutableSet set];
    self.poiList = [MPoint pointsTaggedWith:self.filter inMap:nil InContext:self.moContext];
}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"pepe");
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
    
    TagFilterViewController *tagFilterVC = (TagFilterViewController *)self.revealViewController.rightViewController;
    if(self.revealViewController.frontViewPosition==FrontViewPositionLeft) {
        tagFilterVC.filter = self.filter;
    } else {
        self.filter = tagFilterVC.filter;
        self.poiList = [MPoint pointsTaggedWith:self.filter inMap:nil InContext:self.moContext];
        [self.poisTable reloadData];
    }
    [self.revealViewController rightRevealToggle:self];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)tbarItemOpenWith:(UIBarButtonItem *)sender {
    [OpenInActionSheetViewController showOpenInActionSheetWithController:self point:self.poiList[0]];

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
    return self.poiList.count;
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

    
    MPoint *itemToShow = (MPoint *)[self.poiList objectAtIndex:[indexPath indexAtPosition:1]];
    cell.textLabel.text = [NSString stringWithFormat:@"%d - %@",[indexPath indexAtPosition:1], itemToShow.name];
    cell.imageView.image = itemToShow.icon.image;

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
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------


@end
