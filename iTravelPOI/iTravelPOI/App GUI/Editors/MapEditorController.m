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
    aRect.size.height *=4;
    self.scrollView.contentSize = aRect.size;

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
- (void)keyboardWasShown3:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect bkgndRect = self.activeField.superview.frame;
    bkgndRect.size.height += kbSize.height;
    [self.activeField.superview setFrame:bkgndRect];
    [self.scrollView setContentOffset:CGPointMake(0.0, self.activeField.frame.origin.y-kbSize.height) animated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWasShown:(NSNotification*) aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    

    
    CGFloat n1= self.editToolBar.frame.origin.y;
    n1 = self.mapDescription.inputAccessoryView.frame.origin.y;
    CGFloat n2= self.mapDescription.frame.origin.y;
    CGFloat n3= self.mapDescription.frame.size.height;
    NSLog(@"%f, %f, %f",n1,n2,n3);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.activeField.frame.origin.y-kbSize.height);
//        [self.scrollView setContentOffset:scrollPoint animated:YES];
        [self.scrollView setContentOffset:(CGPoint){0,220} ];
    }
     
}

//---------------------------------------------------------------------------------------------------------------------
// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillBeHidden:(NSNotification*) aNotification {

    CGFloat n1= self.editToolBar.frame.origin.y;
    CGFloat n2= self.mapDescription.frame.origin.y;
    CGFloat n3= self.mapDescription.frame.size.height;
    NSLog(@"%f, %f, %f",n1,n2,n3);

    NSLog(@"%f,%f",self.scrollView.contentOffset.x,self.scrollView.contentOffset.y);
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    self.scrollView.contentOffset = (CGPoint){0,0};
}

@end
