//
//  MapEditorController.m
//  iTravelPOI
//
//  Created by jzarzuela on 18/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MapEditorController.h"
#import "IconEditor.h"
#import <QuartzCore/QuartzCore.h>



//*********************************************************************************************************************
#pragma mark -
#pragma mark MapEditorController PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface MapEditorController()

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField *mapName;
@property (nonatomic, retain) IBOutlet UITextView *mapDescription;
@property (nonatomic, retain) IBOutlet UIToolbar *editToolBar;

@property (nonatomic, assign) UIView *activeField;

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
    [_scrollView release];
    [_mapName release];
    [_mapDescription release];
    [_editToolBar release];
    
    [_map release];
    
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
    
    CGRect aRect = self.view.bounds;
    aRect.size.height = 500;
    self.scrollView.contentSize = aRect.size;
    self.scrollView.contentInset=UIEdgeInsetsMake(0.0,0.0,84.0,0.0);

    CGRect rect;
    
    NSLog(@"view %@",self.view);
    rect = self.view.frame;
    NSLog(@"view frame rect %f,%f-%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    
    NSLog(@"scrollView %@",self.scrollView);
    rect = self.scrollView.frame;
    NSLog(@"scrollView frame rect %f,%f-%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    rect = self.scrollView.bounds;
    NSLog(@"scrollView bounds rect %f,%f-%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    rect = [[UIScreen mainScreen] applicationFrame];
    NSLog(@"applicationFrame frame rect %f,%f-%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    self.scrollView = nil;
    self.mapName = nil;
    self.mapDescription = nil;
    self.editToolBar = nil;
    
    self.map = nil;
    
    [super viewDidUnload];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    
    self.mapName.text = self.map.name;
    self.mapDescription.text = self.map.desc;
    self.activeField = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
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
- (IBAction)mapNameChangedAction:(id)sender {
    
    if([self.mapName.text length]>2 && [self.mapName.text hasPrefix:@"@"]) {
        self.navigationItem.rightBarButtonItem.enabled = true;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = false;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setInputAccessoryView:self.editToolBar];
    self.activeField = textField;
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
#pragma mark Table view data source
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
    return 1;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *mapEditorViewIdentifier = @"MapEditorCellView";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mapEditorViewIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mapEditorViewIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    //cell.textLabel.text = @"textLabel";
    cell.detailTextLabel.text = @"detailTextLabel";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
    cell.imageView.image = [UIImage imageNamed:@"GMapIcons.bundle/arts.png"];
    
    return cell;
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark Table view data delegate
//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self showIconSelector];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showIconSelector];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (void) showIconSelector {
    
    CGPoint p=self.scrollView.contentOffset;
    NSLog(@"%f %f",p.x,p.y);
    
    IconEditor *iconEditor = [[IconEditor alloc] initWithNibName:@"IconEditor" bundle:nil];
    [self.navigationController pushViewController:iconEditor animated:YES];
    [IconEditor release];
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
    CGRect start, end;
    
    // position of keyboard before animation
    [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&start];
    // and after..
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&end];
    
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // slide view up..
    [UIView beginAnimations:@"foo" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    self.view.frame = CGRectMake(0, -end.size.height, 480, 320);
    [UIView commitAnimations];
}

//---------------------------------------------------------------------------------------------------------------------
// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillBeHidden:(NSNotification *)notification {
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // slide view down
    [UIView beginAnimations:@"foo" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    self.view.frame = CGRectMake(0, 0, 480, 320);
    [UIView commitAnimations];
}

@end
