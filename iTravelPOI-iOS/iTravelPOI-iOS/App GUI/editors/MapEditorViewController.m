//
//  MapEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __MapEditorViewController__IMPL__

#import <QuartzCore/QuartzCore.h>

#import "MapEditorViewController.h"
#import "UIView+FirstResponder.h"
#import "GMTItem.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface MapEditorViewController() <UITextFieldDelegate, UITextViewDelegate>


@property (nonatomic, assign) IBOutlet UITextField *nameField;
@property (nonatomic, assign) IBOutlet UITextView *summaryField;
@property (nonatomic, assign) IBOutlet UILabel *extraInfo;

@property (nonatomic, assign) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UIView *kbToolView;

@property (nonatomic, assign) UIViewController<EntityEditorDelegate> *delegate;
@property (nonatomic, strong) NSManagedObjectContext *moContext;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation MapEditorViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (UIViewController<EntityEditorViewController> *) startEditingMap:(MMap *)map
                                                          delegate:(UIViewController<EntityEditorDelegate> *)delegate {

    if(map!=nil && delegate!=nil) {
        MapEditorViewController *me = [[MapEditorViewController alloc] initWithNibName:@"MapEditorViewController" bundle:nil];
        me.delegate = delegate;
        me.map = map;
        me.moContext = map.managedObjectContext; // La referencia es weak y se pierde
        me.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [delegate presentViewController:me animated:YES completion:nil];
        return me;
    } else {
        DDLogVerbose(@"Warning: MapEditorViewController-startEditingMap called with nil Map or Delegate");
        return nil;
    }
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
    
    // Le pone un borde al editor de la descripción
    self.summaryField.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    self.summaryField.layer.borderWidth = 2.0;
    self.summaryField.layer.cornerRadius = 10.0;
    self.summaryField.clipsToBounds = YES;
    

    // Se prepara para editar con el teclado adecuadamente
    UIView *lastControl = self.extraInfo;
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width,
                                                    lastControl.frame.origin.y + lastControl.frame.size.height);
    
    
    self.kbToolView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kbToolBar.png"]];

    // Botones de Save & Cancel
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(_btnCloseCancel:)];

    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                         target:self
                                                                                         action:@selector(_btnCloseSave:)];

    self.navigationBar.topItem.leftBarButtonItem = cancelBarButtonItem;
    self.navigationBar.topItem.rightBarButtonItem = saveBarButtonItem;
    
    // Actualiza los campos desde la entidad a editar
    [self _setFieldValuesFromEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




//=====================================================================================================================
#pragma mark -
#pragma mark <UITextFieldDelegate, UITextViewDelegate> and Keyboard Notification methods
//---------------------------------------------------------------------------------------------------------------------
-(void)keyboardWillShow:(NSNotification*)notification {
    
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat maxScrollHeight = self.view.frame.size.height - self.navigationBar.frame.size.height;
    
    self.contentScrollView.frame = CGRectMake(self.contentScrollView.frame.origin.x,
                                              self.contentScrollView.frame.origin.y,
                                              self.contentScrollView.contentSize.width,
                                              maxScrollHeight - keyboardSize.height);
}

//---------------------------------------------------------------------------------------------------------------------
-(void)keyboardWillHide:(NSNotification*)notification {
    
    CGFloat maxScrollHeight = self.view.frame.size.height - self.navigationBar.frame.size.height;

    self.contentScrollView.frame = CGRectMake(self.contentScrollView.frame.origin.x,
                                              self.contentScrollView.frame.origin.y,
                                              self.contentScrollView.contentSize.width,
                                              maxScrollHeight);
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)kbToolBarOKAction:(UIButton *)sender {
    [self.view findFirstResponderAndResign];
}

//---------------------------------------------------------------------------------------------------------------------
-(void)textFieldDidBeginEditing:(UITextField *)sender {
    
    [self.contentScrollView scrollRectToVisible:sender.frame animated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
    [sender resignFirstResponder];
    return YES;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) textViewShouldBeginEditing:(UITextView *)sender {
    [sender setInputAccessoryView:self.kbToolView];
    return YES;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)textViewDidBeginEditing:(UITextView *)sender {

    [self.contentScrollView scrollRectToVisible:sender.frame animated:YES];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Getter & Setter methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {

    [self.view findFirstResponderAndResign];
    [self dismissViewControllerAnimated:YES completion:nil];

    // Set properties to nil
    self.map = nil;
    self.delegate = nil;
    self.moContext = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseSave:(id)sender {
    
    [self _setEntityFromFieldValues];
    if([self.delegate editorSaveChanges:self modifiedEntity:self.map]) {
        [self _dismissEditor];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseCancel:(id)sender {
    
    if([self.delegate editorCancelChanges:self]) {
        [self _dismissEditor];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    self.nameField.text = self.map.name;
    self.summaryField.text = self.map.summary;
    self.extraInfo.text = [NSString stringWithFormat:@"Published:\t%@\nUpdated:\t%@\nETAG:\t%@",
                                       [GMTItem stringFromDate:self.map.published_date],
                                       [GMTItem stringFromDate:self.map.updated_date],
                                       self.map.etag];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues {

    // *** CONTROL DE SEGURIDAD (@name) PARA NO TOCAR MAPAS BUENOS ***
    NSString *name = self.nameField.text;
    if([name hasPrefix:@"@"]) {
        self.map.name = name;
    } else {
        self.map.name = [NSString stringWithFormat:@"@%@", name];
    }
    self.map.summary = self.summaryField.text;
    [self.map updateModifiedMark];
}



@end

