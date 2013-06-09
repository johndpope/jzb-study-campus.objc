//
//  EntityEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __EntityEditorViewController__IMPL__
#define __EntityEditorViewController__SUBCLASSES__PROTECTED__

#import <QuartzCore/QuartzCore.h>
#import "EntityEditorViewController.h"

#import "BaseCoreData.h"
#import "UIView+FirstResponder.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define BTN_ID_EDIT            4001
#define BTN_ID_EDIT_OK         4002
#define BTN_ID_EDIT_CANCEL     4003




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface EntityEditorViewController() <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, assign) UILabel *titleBar;
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) ScrollableToolbar *scrollableToolbar;


@property (nonatomic, assign) BOOL isNewEntity;
@property (nonatomic, assign) BOOL isEditing;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation EntityEditorViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
- (void) modalEditEntity:(MBaseEntity *)entity isNew:(BOOL)isNewEntity controller:(UIViewController *)controller {

    if(entity!=nil) {
        
        // Guarda la informacion y lanza la edicion de forma modal
        self.entity = entity;
        self.moContext = entity.managedObjectContext; // La referencia es weak y se pierde
        self.isNewEntity = isNewEntity;
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [controller presentViewController:self animated:YES completion:nil];
        
    } else {
        DDLogVerbose(@"Warning: EntityEditorViewController-initModalEditEntity called with 'nil' entity");
    }
}







//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Crea el scrollView y mueve a el todos los elementos actuales
    // En el proceso calcula la altura maxima del contentSize
    CGFloat maxHeight = -1;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40-48)];
    for(UIView *subView in self.view.subviews) {
        [scrollView addSubview:subView];
        CGFloat h = subView.frame.origin.y+subView.frame.size.height;
        maxHeight = MAX(maxHeight, h);
    }
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, maxHeight);
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    
    // Crea la barra de titulo, el scrollView y la de herramientas
    UILabel *titleBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
    titleBar.textAlignment = NSTextAlignmentCenter;
    titleBar.textColor = [UIColor whiteColor];
    titleBar.font = [UIFont boldSystemFontOfSize:18];
    titleBar.text = [self _editorTitle];
    titleBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"breadcrumb-barBg"]];
    [self.view addSubview:titleBar];
    self.titleBar = titleBar;

    
    // Crea la barra de herramientas con las opciones por defecto
    ScrollableToolbar *scrollableToolbar = [[ScrollableToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-51, self.view.frame.size.width, 51)];
    [self.view addSubview:scrollableToolbar];
    self.scrollableToolbar = scrollableToolbar;

    
    // Crea el boton de back
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0,5,50,30)];
    [btnBack setImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(_btnCloseCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];

    
    // Le pone un borde a los editores UIViewText y se añade como delegate de los campos de texto
    for(id subview in self.scrollView.subviews){
        if([subview isKindOfClass:UITextView.class]) {
            UITextView *textView = subview;
            /*
            textView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.25] CGColor];
            textView.layer.borderWidth = 2.0;
            textView.layer.cornerRadius = 6.0;
            textView.clipsToBounds = YES;
             */
            textView.delegate = self;
        } else if([subview isKindOfClass:UITextField.class]) {
            UITextField *textField = subview;
            textField.delegate = self;
        }
    }
    
    
    // Establece un control de gestos para retirar el teclado cuando se toque fuera de un editor
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    // Pone el color de fondo para los editorres
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"myTableBg"]];

    
    // Actualiza los campos desde la entidad a editar
    [self _setFieldValuesFromEntity:self.entity];
    
    // Los deshabilita inicialmente
    [self _disableFieldsFromEditing];

}


//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if(self.isNewEntity) {
        [self _begingEditing];
    } else {
        NSArray *defaultBtns = [self _tbItemsForDefaultOptions];
        [self.scrollableToolbar setItems:defaultBtns animated:YES];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    

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
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark <UITextFieldDelegate, UITextViewDelegate>
//---------------------------------------------------------------------------------------------------------------------
-(void)textFieldDidBeginEditing:(UITextField *)sender {
    
    [self.scrollView scrollRectToVisible:sender.frame animated:YES];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
    [sender resignFirstResponder];
    return YES;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)textViewDidBeginEditing:(UITextView *)sender {

    [self.scrollView scrollRectToVisible:sender.frame animated:YES];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
-(void) _dismissKeyboard {
    [self.view findFirstResponderAndResign];
}

//---------------------------------------------------------------------------------------------------------------------
-(void) _keyboardWillShow:(NSNotification*)notification {
    
    // Recorta del scrollView el tamaño del teclado
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,
                                       self.scrollView.frame.origin.y,
                                       self.scrollView.frame.size.width,
                                       self.scrollView.frame.size.height - keyboardSize.height);
}

//---------------------------------------------------------------------------------------------------------------------
-(void) _keyboardWillHide:(NSNotification*)notification {
    
    CGFloat maxScrollHeight = self.view.frame.size.height - self.titleBar.frame.size.height;
    
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,
                                       self.scrollView.frame.origin.y,
                                       self.scrollView.contentSize.width,
                                       maxScrollHeight);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _nullifyEditor {
    
    // Set properties to nil
    self.entity = nil;
    self.moContext = nil;
    self.scrollableToolbar = nil;
    self.scrollView = nil;
    self.titleBar = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {

    // Cierra el teclado y la ventana modal
    [self.view findFirstResponderAndResign];
    [self dismissViewControllerAnimated:YES completion:nil];

    // Libera informacion asociada
    [self _nullifyEditor];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseCancel:(id)sender {

    if(self.isEditing) {
        [self _endEditingCancel];
    }
    
    // El cierre por cancelacion es incondicional
    [self _dismissEditor];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _editorTitle {
    [[NSException exceptionWithName:@"AbstractMethodException"
                             reason:@"_editorTitle must be implemented by subclass"
                           userInfo:nil] raise];
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity:(MBaseEntity *)entity {
    [[NSException exceptionWithName:@"AbstractMethodException"
                             reason:@"_setFieldValuesFromEntity must be implemented by subclass"
                           userInfo:nil] raise];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues:(MBaseEntity *)entity {
    [[NSException exceptionWithName:@"AbstractMethodException"
                             reason:@"_setEntityFromFieldValues must be implemented by subclass"
                           userInfo:nil] raise];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _rotateImageField:(UIImageView *)imgField {
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotate.duration = 0.7f;
    rotate.repeatCount = 1;
    [imgField.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [imgField.layer addAnimation:rotate forKey:@"trans_rotation"];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbItemsForDefaultOptions {
    
    NSArray *__tbItemsForDefaultOptions = [NSArray arrayWithObjects:
                                           [STBItem itemWithTitle:@"Edit Info" image:[UIImage imageNamed:@"btn-edit"] tagID:BTN_ID_EDIT target:self action:@selector(_begingEditing)],
                                           nil];
    return __tbItemsForDefaultOptions;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbItemsForEditing {
    
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:
                             [STBItem itemWithTitle:@"Cancel" image:[UIImage imageNamed:@"btn-checkCancel"] tagID:BTN_ID_EDIT_CANCEL target:self action:@selector(_endEditingCancel)],
                             [STBItem itemWithTitle:@"Done" image:[UIImage imageNamed:@"btn-checkOK"] tagID:BTN_ID_EDIT_OK target:self action:@selector(_endEditingSave)],
                             nil];

    NSArray *others = [self _tbItemsForEditingOthers];
    if(others!=nil) {
        [items addObjectsFromArray:others];
    }
    return items;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbItemsForEditingOthers {

    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _disableFieldsFromEditing {
    [[NSException exceptionWithName:@"AbstractMethodException"
                             reason:@"_disableFieldsFromEditing must be implemented by subclass"
                           userInfo:nil] raise];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _enableFieldsForEditing {
    [[NSException exceptionWithName:@"AbstractMethodException"
                             reason:@"_enableFieldsForEditing must be implemented by subclass"
                           userInfo:nil] raise];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _begingEditing {

    // Crea un contexto hijo para que cualquier cambio ocurra ahi
    NSManagedObjectContext *childMoc = [BaseCoreData moChildContextFrom:self.moContext];
    self.moContext = childMoc;
    
    // Hace una copia de la entidad para poder deshechar los cambios (suyos y de las relaciones)
    MBaseEntity *copyOfEntity = (MBaseEntity *)[childMoc objectWithID:self.entity.objectID];
    self.entity = copyOfEntity;
    
    // Activa los controles de edicion para que se puedan hacer cambios
    [self _enableFieldsForEditing];

    // Establece las nuevas opciones de la barra de herramientas
    NSArray *editingBtns = [self _tbItemsForEditing];
    [self.scrollableToolbar setItems:editingBtns animated:YES];
    
    // Marca que esta editando
    self.isEditing = YES;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _endEditingCommon {

    // Desactiva de nuevo los controles de edicion para evitar cambios
    [self _disableFieldsFromEditing];
    
    // Reestablece las opciones por defecto del modo normal
    NSArray *defaultBtns = [self _tbItemsForDefaultOptions];
    [self.scrollableToolbar setItems:defaultBtns animated:YES];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _endEditingCancel {
    
    // Deshecha el contexto hijo con todos sus cambios (restaura los originales)
    NSManagedObjectContext *parentMoc = self.moContext.parentContext;
    self.moContext = parentMoc;
    MBaseEntity *copyOfEntity = (MBaseEntity *)[parentMoc objectWithID:self.entity.objectID];
    self.entity = copyOfEntity;
    
    // Revierte cualquier cambio que se haya podido hacer
    [self _setFieldValuesFromEntity:self.entity];

    // Restaura el estado al modo normal
    [self _endEditingCommon];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _endEditingSave {
    
    // Establece los valores de la entidad desde los controles
    [self _setEntityFromFieldValues:self.entity];

    // Graba los cambios en todos los contextos y desecha el contexto hijo
    NSManagedObjectContext *parentMoc = self.moContext.parentContext;
    [BaseCoreData saveMOContext:self.moContext upToParentMOContext:parentMoc];
    self.moContext = parentMoc;
    MBaseEntity *copyOfEntity = (MBaseEntity *)[parentMoc objectWithID:self.entity.objectID];
    self.entity = copyOfEntity;
    
    // Refresca los valores de los controles desde la entidad para tener la seguridad de que todo esta sincronizado
    [self _setFieldValuesFromEntity:self.entity];

    // Restaura el estado al modo normal
    [self _endEditingCommon];
}





@end

