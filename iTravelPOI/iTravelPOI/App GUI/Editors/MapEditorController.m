//
//  MapEditorController.m
//  iTravelPOI
//
//  Created by jzarzuela on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MapEditorController.h"
#import "GMapIconEditor.h"
#import <QuartzCore/QuartzCore.h>



//*********************************************************************************************************************
#pragma mark -
#pragma mark MapEditorController PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MapEditorController() 

@property (retain, nonatomic) IBOutlet UIImageView *imageIcon;
@property (nonatomic, retain) IBOutlet UITextField *mapName;
@property (nonatomic, retain) IBOutlet UITextView *mapDescription;
@property (retain, nonatomic) IBOutlet UIView *editToolBar;
@property (retain, nonatomic) IBOutlet UILabel *usageLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;


@property (nonatomic, assign) UIView *activeField;


@property (nonatomic, retain) NSString *tempName;
@property (nonatomic, retain) NSString *tempDesc;
@property (nonatomic, retain) GMapIcon *tempIcon;


- (IBAction)saveAction:(id)sender;
- (void) showIconSelector;


- (void) registerForKeyboardNotifications;
- (void) unregisterForKeyboardNotifications;
- (void) keyboardWasShown:(NSNotification*) aNotification;
- (void) keyboardWillBeHidden:(NSNotification*) aNotification;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark MapEditorController implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MapEditorController

@synthesize scrollView = _scrollView;
@synthesize mapName = _mapName;
@synthesize mapDescription = _mapDescription;
@synthesize editToolBar = _editToolBar;

@synthesize activeField = _activeField;

@synthesize tempName = _tempName;
@synthesize tempDesc = _tempDesc;
@synthesize tempIcon = _tempIcon;

@synthesize imageIcon = _imageIcon;
@synthesize usageLabel = _usageLabel;
@synthesize delegate = _delegate;
@synthesize map = _map;



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
    [_imageIcon release];
    [_mapName release];
    [_mapDescription release];
    [_editToolBar release];
    [_usageLabel release];
    [_scrollView release];
    
    [_map release];
    [_tempName release];
    [_tempDesc release];
    [_tempIcon release];
    
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
- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    // Inicializa el resto de la vista
    self.title = @"Map Editor";
    
    // Creamos el boton para crear o editar mapas
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                              target:self
                                                                              action:@selector(saveAction:)];
    saveBtn.enabled = NO;
    self.navigationItem.rightBarButtonItem=saveBtn;
    [saveBtn release];
    
    // Redondea el borde de la caja de texto de la descripcion
    self.mapDescription.layer.cornerRadius = 5.0;
    self.mapDescription.clipsToBounds = YES;
    
    
    [self registerForKeyboardNotifications];
    
    // Establece el tamaño del contenido en base al elemento que esta mas abajo y padding de 6
    GLuint csWidth = self.scrollView.frame.size.width;
    GLuint csHeight = 6 + self.usageLabel.frame.origin.y + self.usageLabel.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(csWidth, csHeight);
    
    self.editToolBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kbToolBar.png"]];

    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgMap2.png"]];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    self.imageIcon = nil;
    self.mapName = nil;
    self.mapDescription = nil;
    self.editToolBar = nil;
    self.usageLabel = nil;
    self.scrollView = nil;
    
    self.map = nil;
    self.tempName = nil;
    self.tempDesc = nil;
    self.tempIcon = nil;
    
    [super viewDidUnload];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
        
    if(!self.tempName) {
        self.tempName = self.map.name;
    }
    
    if(!self.tempDesc) {
        self.tempDesc = self.map.desc;
    }
    
    if(!self.tempIcon) {
        if(self.map) {
            self.tempIcon = self.map.icon;
        } else {
            self.tempIcon = [GMapIcon iconForURL:[MEMap defaultIconURL]];
        }
    }
    
    self.imageIcon.image = self.tempIcon.image;
    self.mapName.text = self.tempName;
    self.mapDescription.text = self.tempDesc;
    self.activeField = nil;
    
    [self mapNameChangedAction:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.imageIcon cache:YES];
    self.imageIcon.image = self.tempIcon.image;
    [UIView commitAnimations];
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
- (IBAction)tapDetected:(UITapGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateEnded && self.activeField == nil) {
        [self showIconSelector];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)mapNameChangedAction:(id)sender {
    
    if([self.mapName.text length]>2 && [self.mapName.text hasPrefix:@"@"]) {
        self.navigationItem.rightBarButtonItem.enabled = true;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = false;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //[textField setInputAccessoryView:self.editToolBar];
    self.activeField = textField;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.activeField resignFirstResponder];
    self.activeField = nil;
    return YES;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    [textView setInputAccessoryView:self.editToolBar];
    self.activeField = textView;
    return YES;
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)editToolBarOKAction:(id)sender {
    [self.activeField resignFirstResponder];
    self.activeField = nil;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (void) showIconSelector {
    
    self.tempName = self.mapName.text;
    self.tempDesc = self.mapDescription.text;
    
    GMapIconEditor *gmapIconEditor = [[GMapIconEditor alloc] initWithNibName:@"GMapIconEditor" bundle:nil];
    [self.navigationController pushViewController:gmapIconEditor animated:YES];
    [gmapIconEditor release];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Keyboard handling methods
//---------------------------------------------------------------------------------------------------------------------
// Call this method somewhere in your view controller setup code.
- (void) registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

//---------------------------------------------------------------------------------------------------------------------
// Call this method somewhere in your view controller setup code.
- (void) unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//---------------------------------------------------------------------------------------------------------------------
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification *)notification {

    CGRect kbEnd;
    
    // Gets position of keyboard after animation, duration and curve
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&kbEnd];
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // Calc new frame size based on keyboard size
    GLuint frHeight = self.view.frame.size.height - kbEnd.size.height;
    GLuint frWidth = self.view.frame.size.width;
    
    // slide view up..
    [UIView beginAnimations:@"foo" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    self.scrollView.frame = CGRectMake(0, 0, frWidth, frHeight);
    [UIView commitAnimations];
}

//---------------------------------------------------------------------------------------------------------------------
// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillBeHidden:(NSNotification *)notification {

    
    // Gets keyboard animation's duration and curve
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // Calc new frame size based on self.view size
    GLuint frHeight = self.view.frame.size.height;
    GLuint frWidth = self.view.frame.size.width;

    // slide view down
    [UIView beginAnimations:@"foo" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    self.scrollView.frame = CGRectMake(0, 0, frWidth, frHeight);
    [UIView commitAnimations];
}

@end
