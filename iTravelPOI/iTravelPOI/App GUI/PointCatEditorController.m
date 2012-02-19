//
//  PointCatEditorController.m
//  iTravelPOI
//
//  Created by jzarzuela on 19/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PointCatEditorController.h"



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface PointCatEditorController ()

@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UITextView *desc;

@end




//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation PointCatEditorController


@synthesize name = _name;
@synthesize desc = _desc;
@synthesize entity = _entity;


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
    
    self.desc.layer.cornerRadius = 5.0;
    self.desc.clipsToBounds = YES;
    
    if(self.entity) {
        self.name.text = self.entity.name;
        self.desc.text = self.entity.desc;
    }
    
    UIScrollView *scrollView = (UIScrollView *)self.view;
    
    scrollView.contentSize = CGSizeMake(320,800);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_name release];
    [_desc release];
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
