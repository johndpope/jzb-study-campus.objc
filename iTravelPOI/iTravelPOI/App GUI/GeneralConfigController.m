//
//  GeneralConfigController.m
//  iTravelPOI
//
//  Created by JZarzuela on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeneralConfigController.h"

#import "SyncService.h"
#import "ModelService.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark GeneralConfigController PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface GeneralConfigController()

@property (nonatomic, readonly) NSManagedObjectContext *moContext;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark GeneralConfigController implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation GeneralConfigController

@synthesize moContext = _moContext;


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
    [_moContext release];

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
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (NSManagedObjectContext *) moContext {
    if(!_moContext) {
        _moContext = [[ModelService sharedInstance] initContext];
    }
    return _moContext;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark View lifecycle
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    // Sincroniza los mapas
    [[SyncService sharedInstance] syncMapsInCtx:self.moContext callback:^(NSError *error) {
        // codigo de gestion del error aqui;
        // Habría que salvar los cambios y, de alguna forma, hacer que se recarguen datos en otras ventanas
    }];
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


//*********************************************************************************************************************
#pragma mark -
#pragma mark Internal Event Handlers
//---------------------------------------------------------------------------------------------------------------------

//*********************************************************************************************************************
#pragma mark -
#pragma mark SortOptionsController delegate
//---------------------------------------------------------------------------------------------------------------------

//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------

@end
