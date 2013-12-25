//
//  TagFilterViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TagFilterViewController__IMPL__
#import "TagFilterViewController.h"
#import "BaseCoreDataService.h"
#import "MTag.h"
#import "MIcon.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TagFilterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) IBOutlet UITableView *tagsTable;

@property (nonatomic, strong) NSArray *tagList;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TagFilterViewController


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
    self.filter = [NSMutableSet set];
    self.tagList = [MTag tagsForPointsTaggedWith:self.filter InContext:self.moContext];
    
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

    MTag *itemSelected = (MTag *)[self.tagList objectAtIndex:[indexPath indexAtPosition:1]];
    
    [UIView animateWithDuration:0.3 animations:^{
        if([self.filter containsObject:itemSelected]) {
            [self.filter removeObject:itemSelected];
        } else {
            [self.filter addObject:itemSelected];
        }
        
        self.tagList = [MTag tagsForPointsTaggedWith:self.filter InContext:self.moContext];
        
        //    [self.tagsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]
        //                                   atScrollPosition:UITableViewScrollPositionNone
        //                                           animated:TRUE];
        
        [self.tagsTable reloadData];
    }];


    //    return indexPath;
    
    // No dejamos nada seleccionado
    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tagList.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    
    MTag *itemToShow = (MTag *)[self.tagList objectAtIndex:[indexPath indexAtPosition:1]];
    cell.textLabel.text = itemToShow.name;
    if([self.filter containsObject:itemToShow]) {
        cell.textLabel.textColor = [UIColor blueColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
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
