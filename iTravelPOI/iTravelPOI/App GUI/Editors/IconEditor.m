//
//  IconEditor.m
//  iTravelPOI
//
//  Created by jzarzuela on 02/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IconEditor.h"


@implementation IconEditor

@synthesize selectedIcon = _selectedIcon;
@synthesize imageMap = _imageMap;
@synthesize scrollerView = _scrollerView;



- (void) setSelectedImage:(UIImage *) image {
    self.selectedIcon.image = image;
}


- (void) viewWillAppear:(BOOL)animated {
    CGSize size = {320,640};
    self.scrollerView.contentSize = size;
    self.imageMap.delegate2 = self;
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
- (void)dealloc
{
    [_selectedIcon release];
    [_imageMap release];
    [_scrollerView release];
    [super dealloc];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [self setSelectedIcon:nil];
    [self setImageMap:nil];
    [self setScrollerView:nil];
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

@end
