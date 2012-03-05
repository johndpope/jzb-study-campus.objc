//
//  MapEditorController.m
//  iTravelPOI
//
//  Created by jzarzuela on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MapEditorController.h"
#import <QuartzCore/QuartzCore.h>



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@interface MapEditorController()

@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UITextField *mapName;
@property (nonatomic, retain) IBOutlet UITextView *mapDescription;
@property (nonatomic, retain) IBOutlet UIToolbar *editToolBar;

- (IBAction)saveAction:(id)sender;

@end



//*********************************************************************************************************************
//---------------------------------------------------------------------------------------------------------------------
@implementation MapEditorController

@synthesize saveButton = _saveButton;
@synthesize mapName = _mapName;
@synthesize mapDescription = _mapDescription;
@synthesize editToolBar = _editToolBar;

@synthesize delegate = _delegate;
@synthesize map = _map;



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
- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    // Inicializa el resto de la vista
    self.title = @"Map Editor";
    
    // Creamos el boton para crear o editar mapas
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                              target:self
                                                                              action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem=saveBtn;
    [saveBtn release];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    
    self.mapDescription.layer.cornerRadius = 5.0;
    self.mapDescription.clipsToBounds = YES;
    
    if(self.map) {
        self.mapName.text = self.map.name;
        self.mapDescription.text = self.map.desc;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_saveButton release];
    [_mapName release];
    [_mapDescription release];
    [_editToolBar release];
    
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
#pragma mark - Internap Event Handlers
//=====================================================================================================================



//---------------------------------------------------------------------------------------------------------------------
- (IBAction)mapNameChangedAction:(id)sender {
    //if([self.mapName.text length]>0) {
    if([self.mapName.text length]>2 && [self.mapName.text hasPrefix:@"@"]) {
        self.saveButton.enabled = true;
    } else {
        self.saveButton.enabled = false;
    }
}


//---------------------------------------------------------------------------------------------------------------------
- (IBAction)saveAction:(id)sender {
    
    if(self.delegate) {
        if(!self.map) {
            self.map = [self.delegate mapEditorCreateMapInstance];
        }
        self.map.name = self.mapName.text;
        self.map.desc = self.mapDescription.text;
        [self.delegate mapEditorSave:self map:self.map];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setInputAccessoryView:self.editToolBar];
    edittingText = textField;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    [textView setInputAccessoryView:self.editToolBar];
    edittingText = textView;
    return YES;
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)editToolBarOKAction:(id)sender {
    [edittingText resignFirstResponder];
}



//=====================================================================================================================
#pragma mark - View lifecycle
//=====================================================================================================================





//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [self setMapName:nil];
    [self setMapDescription:nil];

    [super viewDidUnload];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
