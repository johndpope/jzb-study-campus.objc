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

#import "BreadcrumbBar.h"
#import "ScrollableToolbar.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TestViewController() <UITableViewDelegate, UITableViewDataSource, BreadcrumbBarDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *botones;
@property (weak, nonatomic) IBOutlet UIImageView *piquito;
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UIWebView *browser;

@property (strong, nonatomic) NSMutableSet *selectedEditingIndex;

@property (weak, nonatomic) IBOutlet BreadcrumbBar *scrollNavBar;
@property (weak, nonatomic) IBOutlet ScrollableToolbar *scrollableToolbar;

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
    
    self.browser.delegate = self;
    [self.browser loadHTMLString:@"<div id='example-one' contenteditable='true'>hola</div>" baseURL:[NSURL URLWithString:nil]];
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

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"1");
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"2");
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"3");
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"4");
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)ponerEdit:(UIButton *)sender {
    
    if(!self.scrollableToolbar.isEditModeActive)
        [self.scrollableToolbar activateEditModeForItemWithTagID:0 animated:YES confirmBlock:nil cancelBlock:nil];
    else
        [self.scrollableToolbar deactivateEditModeAnimated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)removeAllItems:(UIButton *)sender {
    [self.scrollableToolbar removeAllItemsAnimated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)setItems:(UIButton *)sender {

    NSMutableArray *items = [NSMutableArray array];
    UIImage *tbIcon1 = [UIImage imageNamed:@"tbIcon1" ];

    
    static int lastR = 0;
    int r;
    do {
        r = 1+arc4random() % 7;
    } while(r==lastR);
    lastR = r;
    
    for(int n=0;n<r;n++) {
        NSString *title = [NSString stringWithFormat:@"Weather %d",n];
        [items addObject:[STBItem itemWithTitle:title image:tbIcon1 tagID:0 target:nil action:nil]];
    }
    
    [self.scrollableToolbar setItems:items animated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)moverCosas:(UIButton *)sender {
    
    static int count;
    [self.scrollNavBar addItemWithTitle:@"Home" image:nil data:nil];
    [self.scrollNavBar addItemWithTitle:@"Images" image:nil data:nil];
    [self.scrollNavBar addItemWithTitle:@"Belgium" image:nil data:nil];
    
    
    NSString *label = [NSString stringWithFormat:@"L-%d", ++count];
    [self.scrollNavBar addItemWithTitle:@"" image:[UIImage imageNamed:@"checkmark-checked"] data:nil];
    [self.myTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
    
    
    UIImage *tbIcon1 = [UIImage imageNamed:@"tbIcon1" ];
    [self.scrollableToolbar addItem:[STBItem itemWithTitle:@"Weather 1" image:tbIcon1 tagID:0 target:self action:nil]];

}


//=====================================================================================================================
#pragma mark -
#pragma mark <BreadcrumbBarDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void) itemRemovedFromScrollableBarNav:(BreadcrumbBar *)sender
                        removedItemTitle:(NSString *)title
                         removedItemData:(id)data {

    NSLog(@"item removed - title %@",title);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) activeItemUptatedInScrollableBarNav:(BreadcrumbBar *)sender
                             activeItemTitle:(NSString *)title
                              activeItemData:(id)data
                           removedItemsCount:(NSUInteger)removedItemsCount {
    
    NSLog(@"item active - title %@",title);
}



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
        cell.leftCheckState = [self.selectedEditingIndex containsObject:[NSNumber numberWithInteger:indexPath.row]] ? ST_CHECKED : ST_UNCHECKED;
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

