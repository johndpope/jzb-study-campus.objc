//
//  MapListController.m
//  iTest
//
//  Created by jzarzuela on 17/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MapListController.h"
#import "PointListController.h"
#import "TDBadgedCell.h"


//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation MapListController


@synthesize mapViewCell = _mapViewCell;

//---------------------------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
 /*   
    //load the image
    UIImage *buttonImage ;
    buttonImage = [UIImage imageNamed:@"pencil.png"];
    
    //create the button and assign the image for window width and level
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(WWL:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:buttonImage forState:UIControlStateNormal];
    //set the frame of the button to the size of the image (see note below)
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    //create a UIBarButtonItem with the button as a custom view
    UIBarButtonItem *WindowWidthZoom = [[UIBarButtonItem alloc]  initWithCustomView:button  ];
    
    self.navigationItem.rightBarButtonItem=WindowWidthZoom;
    [WindowWidthZoom release];
*/


    
    self.title = @"Maps";
    
    //create the button and assign the image for window width and level
    UIButton *button = [UIButton buttonWithType:UIBarButtonSystemItemAdd];
    [button addTarget:self action:@selector(WWL:) forControlEvents:UIControlEventTouchUpInside];
    //set the frame of the button to the size of the image (see note below)
    button.frame = CGRectMake(0, 0, 32, 32);
    //create a UIBarButtonItem with the button as a custom view
    
    UIBarButtonItem *WindowWidthZoom = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:nil];
    
    self.navigationItem.rightBarButtonItem=WindowWidthZoom;
    [WindowWidthZoom release];

}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return 30;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *mapViewIdentifier = @"MapCellView";
    
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:mapViewIdentifier];
    if (cell == nil) {
        
        //[[NSBundle mainBundle] loadNibNamed:mapViewIdentifier owner:self options:nil];
        //cell = self.mapViewCell;
        //self.mapViewCell = nil;
        
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mapViewIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"textLabel: %u",indexPath.row];
    cell.detailTextLabel.text = @"detailTextLabel";
    
    static UIImage * myPngs[5] = {nil, nil, nil, nil, nil};
    if(myPngs[0]==nil) {
        for(int n=0;n<5;n++) {
            NSString *iconName = [NSString stringWithFormat:@"icon%u",(n+1)];
            NSString *path = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
            myPngs[n] = [[UIImage imageWithContentsOfFile:path] retain];
        }
    }
    
    srandom(time(NULL));
    int index = arc4random() % 5;
    cell.imageView.image = myPngs[index];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
    
    
    
    cell.badgeString = [NSString stringWithFormat:@"%u",indexPath.row];
    
	if (indexPath.row == 1)
		cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
    
	if (indexPath.row == 2)
    {
		cell.badgeColor = [UIColor colorWithRed:0.197 green:0.592 blue:0.219 alpha:1.000];
        cell.badge.radius = 9;
    }
    
    if(indexPath.row == 3)
    {
        cell.showShadow = YES;
    }
    
    
    
    //    UIImage *image = [[UIImage imageNamed:@"USA.jpeg"] 
    //                      _imageScaledToSize:CGSizeMake(30.0f, 32.0f) 
    //                      interpolationQuality:1];
    //    cell.imageView.image = image;
    
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


//=====================================================================================================================
#pragma mark - Table view delegate
//=====================================================================================================================


//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     PointListController *detailViewController = [[PointListController alloc] initWithNibName:@"PointListController" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
}

@end
