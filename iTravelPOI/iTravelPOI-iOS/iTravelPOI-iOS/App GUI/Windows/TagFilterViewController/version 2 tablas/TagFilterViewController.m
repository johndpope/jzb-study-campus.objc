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

@property (nonatomic, assign) IBOutlet UITableView *filterTable;
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
    self.filter = [NSMutableArray array];
    /*
    self.tagList = [MTag tagsForPointsTaggedWith:self.filter InContext:self.moContext];
     */
    

    
}

- (void) viewWillAppear:(BOOL)animated {
    [self _loadTags];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _loadTags {
    
    NSMutableArray *allTags = [NSMutableArray arrayWithArray:[MTag tagsForPointsTaggedWith:[NSSet setWithArray:self.filter] InContext:self.moContext]];
    
    for(MTag *tag in [allTags copy]) {
        NSLog(@"1-Procesing tag '%@'", tag.name);
        if(![self.filter containsObject:tag] && tag.hasParentTags && [tag anyIsParentTag:[NSSet setWithArray:allTags]] && ![tag anyIsParentTag:[NSSet setWithArray:self.filter]]) {
            NSLog(@"    Filtered because parent is already in list");
            [allTags removeObject:tag];
        }
    }
    
    for(MTag *tag in [allTags copy]) {
        NSLog(@"2-Procesing tag '%@'", tag.name);
        if([self.filter containsObject:tag]) {
            NSLog(@"    Filtered because is in filter");
            [allTags removeObject:tag];
        }
    }
    
    
    self.tagList = allTags;
    [self.tagsTable reloadData];
    [self.filterTable reloadData];
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

    
    if(tableView==self.filterTable) {
        MTag *itemSelected = (MTag *)[self.filter objectAtIndex:[indexPath indexAtPosition:1]];
        [self.filter removeObject:itemSelected];
    } else {
        MTag *itemSelected = (MTag *)[self.tagList objectAtIndex:[indexPath indexAtPosition:1]];
        [self.filter addObject:itemSelected];
    }
    
    [self _loadTags];

    // No dejamos nada seleccionado
    //    return indexPath;
    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(tableView==self.filterTable) {
        return self.filter.count;
    } else {
        return self.tagList.count;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView==self.filterTable) {
        return [self tableViewFilter:tableView cellForRowAtIndexPath:indexPath];
    } else {
        return [self tableViewTags:tableView cellForRowAtIndexPath:indexPath];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableViewFilter:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myTableCell2";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    
    MTag *itemToShow = (MTag *)[self.filter objectAtIndex:[indexPath indexAtPosition:1]];
    if(itemToShow.shortName) {
        cell.textLabel.text = itemToShow.shortName;
    } else {
        cell.textLabel.text = itemToShow.name;
    }
    if([self.filter containsObject:itemToShow]) {
        cell.textLabel.textColor = [UIColor blueColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.imageView.image = itemToShow.icon.image;
    
    
    return cell;

}
    
//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableViewTags:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myTableCell2";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    
    MTag *itemToShow = (MTag *)[self.tagList objectAtIndex:[indexPath indexAtPosition:1]];
    if(itemToShow.shortName) {
        cell.textLabel.text = itemToShow.shortName;
    } else {
        cell.textLabel.text = itemToShow.name;
    }
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
