//
//  SortOptionsController.m
//  iTravelPOI
//
//  Created by JZarzuela on 11/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SortOptionsController.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark SortOptionsController implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation SortOptionsController


@synthesize delegate = _delegate;


//*********************************************************************************************************************
#pragma mark -
#pragma mark initialization & finalization
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



//*********************************************************************************************************************
#pragma mark -
#pragma mark View lifecycle
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [self setDelegate:nil];
    
    [super viewDidUnload];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Internal Event Handlers
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)sortByUpdateTimeAction:(id)sender {
    [self.delegate sortMethodSelected:SORT_BY_UPDATING_DATE];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)sortByCreationTime:(id)sender {
    [self.delegate sortMethodSelected:SORT_BY_CREATING_DATE];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)sortByNameAction:(id)sender {
    [self.delegate sortMethodSelected:SORT_BY_NAME];
}


@end
