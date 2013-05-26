//
//  TestViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TestViewController__IMPL__
#import "TestViewController.h"

#import "ImageManager.h"
#import "TDBadgedCell.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TestViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISegmentedControl *botones;
@property (weak, nonatomic) IBOutlet UIImageView *piquito;
@property (weak, nonatomic) IBOutlet UITableView *myTable;

@property (strong, nonatomic) NSMutableSet *selectedEditingIndex;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TestViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (TestViewController *) startTestController {

    TestViewController *me = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:nil];
    return me;
}






//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.botones setDividerImage:[UIImage imageNamed:@"separator"]
              forLeftSegmentState:UIControlStateNormal
                rightSegmentState:UIControlStateNormal
                       barMetrics:UIBarMetricsDefault];
    
    
    [self.botones setDividerImage:[UIImage imageNamed:@"separator"]
              forLeftSegmentState:UIControlStateSelected
                rightSegmentState:UIControlStateNormal
                       barMetrics:UIBarMetricsDefault];
    
    [self.botones setDividerImage:[UIImage imageNamed:@"separator"]
              forLeftSegmentState:UIControlStateNormal
                rightSegmentState:UIControlStateSelected
                       barMetrics:UIBarMetricsDefault];
    
    
    [self.botones setBackgroundImage:[UIImage imageNamed:@"stateNormal"]
                            forState:UIControlStateNormal
                          barMetrics:UIBarMetricsDefault];

    
    [self.botones setBackgroundImage:[UIImage imageNamed:@"stateHighlighted"]
                            forState:UIControlStateHighlighted
                          barMetrics:UIBarMetricsDefault];

    [self.botones setBackgroundImage:[UIImage imageNamed:@"stateSelected"]
                            forState:UIControlStateSelected
                          barMetrics:UIBarMetricsDefault];

    
    [self.botones addTarget:self
                     action:@selector(optionClicked:)
            forControlEvents:UIControlEventValueChanged];

    [self movePiquilloToSelectedIndex];

    
    self.selectedEditingIndex = [NSMutableSet set];
    [self.myTable setEditing:NO animated:YES];
}



//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) movePiquilloToSelectedIndex {
    
    CGRect frame = self.piquito.frame;
    frame.origin.x = (1+2*self.botones.selectedSegmentIndex)*(self.botones.frame.size.width / 6.0) - (self.piquito.frame.size.width / 2.0);
    [UIView animateWithDuration:0.3 animations:^{
        self.piquito.frame = frame;
    } completion: ^(BOOL finished) {
    }];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) optionClicked:(UISegmentedControl *)sender {
    [self movePiquilloToSelectedIndex];
    
    
    [self.myTable setEditing:!self.myTable.isEditing animated:YES];
}


//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------


//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
   
}

//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.myTable.isEditing) {
        NSNumber *itemIndex = [NSNumber numberWithInteger:indexPath.row];
        if([self.selectedEditingIndex containsObject:itemIndex]) {
            [self.selectedEditingIndex removeObject:itemIndex];
        } else {
            [self.selectedEditingIndex addObject:itemIndex];
        }
        [self.myTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if(self.myTable.isEditing) {
        cell.leftChecked = [self.selectedEditingIndex containsObject:[NSNumber numberWithInteger:indexPath.row]];
    }
    
    cell.badgeString = @"100";
    cell.textLabel.text=[NSString stringWithFormat:@"celda %d",indexPath.row];
    cell.imageView.image = [ImageManager imageForName:@"SyncIcon_doneOK"];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.detailTextLabel.text = @"\U0001F513 \u2630";
    return cell;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {
}



@end

