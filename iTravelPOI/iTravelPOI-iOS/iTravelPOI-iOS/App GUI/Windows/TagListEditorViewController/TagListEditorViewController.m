//
//  TagListEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TagListEditorViewController__IMPL__
#import "TagListEditorViewController.h"
#import "Util_Macros.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TagListEditorViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) IBOutlet UITableView *assignedTagsTableView;
@property (nonatomic, assign) IBOutlet UITableView *existingTagsTableView;

@property (nonatomic, strong) NSMutableArray *assignedTags;
@property (nonatomic, strong) NSMutableArray *existingTags;

@property (weak, nonatomic) IBOutlet UILabel *lblSelector;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TagListEditorViewController


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

    self.assignedTags = [NSMutableArray array];
    for(int n=0;n<20;n++) {
        [self.assignedTags addObject:[NSString stringWithFormat:@"ATag-%d",n]];
    }
    self.assignedTagsTableView.editing = YES;
    
    self.existingTags = [NSMutableArray array];
    for(int n=0;n<20;n++) {
        [self.existingTags addObject:[NSString stringWithFormat:@"ETag-%d",n]];
    }
    //self.existingTagsTableView.editing = YES;
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
- (IBAction)assignedAction:(UIBarButtonItem *)sender {
    
    frameSetX(self.lblSelector, 205);
    frameSetX(self.viewContainer, -320);
    
    [UIView animateWithDuration:0.3 animations:^{
        frameSetX(self.lblSelector, 36);
        frameSetX(self.viewContainer, 0);
    } completion:^(BOOL finished) {
        frameSetX(self.lblSelector, 36);
        frameSetX(self.viewContainer, 0);
    }];
}

- (IBAction)availableAction:(UIBarButtonItem *)sender {
    
    frameSetX(self.lblSelector, 36);
    frameSetX(self.viewContainer, 0);
    
    [UIView animateWithDuration:0.3 animations:^{
        frameSetX(self.lblSelector, 205);
        frameSetX(self.viewContainer,-320);
    } completion:^(BOOL finished) {
        frameSetX(self.lblSelector, 205);
        frameSetX(self.viewContainer,-320);
    }];
}

//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Inhibe que las filas se puedan borrar pasando el dedo
    
    if(tableView==self.assignedTagsTableView) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }

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

//---------------------------------------------------------------------------------------------------------------------
- (UIView *)tableViewXXXX:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lbl = [[UILabel alloc] initWithFrame:(CGRect){0,0,200,21}];
    lbl.text = @"Section";
    return lbl;
}




//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *)tableViewXXXX:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"sec 1";
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(tableView==self.assignedTagsTableView) {
        return self.assignedTags.count;
    } else {
        return self.existingTags.count;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myTableViewCellID1";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    
    if(tableView==self.assignedTagsTableView) {
        cell.textLabel.text = [self.assignedTags objectAtIndex:[indexPath indexAtPosition:1]];
    } else {
        cell.textLabel.text = [self.existingTags objectAtIndex:[indexPath indexAtPosition:1]];
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


@end
