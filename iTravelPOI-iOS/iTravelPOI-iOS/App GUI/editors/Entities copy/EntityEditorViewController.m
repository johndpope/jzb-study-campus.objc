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




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface EntityEditorViewController() <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) UILabel *titleBar;
@property (nonatomic, weak) UIScrollView *scrollView;


@property (nonatomic, weak)   UIViewController *target;
@property (nonatomic, assign) SEL confirm;

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
- (void) modalEditEntity:(MBaseEntity *)entity target:(UIViewController *)target confirm:(SEL)confirm {

    if(entity!=nil && target!=nil && confirm!=nil) {
        
        // Guarda la informacion y lanza la edicion de forma modal
        self.target = target;
        self.confirm = confirm;
        self.entity = entity;
        self.moContext = entity.managedObjectContext; // La referencia es weak y se pierde
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [target presentViewController:self animated:YES completion:nil];
        
    } else {
        DDLogVerbose(@"Warning: EntityEditorViewController-initModalEditEntity called with 'nil' controller, entity or confirmBlock");
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
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40)];
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

    // Crea las opciones de salvar y cancelar
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height-10-30, 70, 30)];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    UIImage *img1 = [UIImage imageNamed:@"scrollableBarConfirmBtn"];
    UIImage *img2 = [img1 resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch];
    [btnCancel setBackgroundImage:img2 forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:12];
    [btnCancel addTarget:self action:@selector(_btnCloseCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];

    UIButton *btnSave = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-10-70, self.view.frame.size.height-10-30, 70, 30)];
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    UIImage *img11 = [UIImage imageNamed:@"scrollableBarConfirmBtn"];
    UIImage *img22 = [img11 resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch];
    [btnSave setBackgroundImage:img22 forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont systemFontOfSize:12];
    [btnSave addTarget:self action:@selector(_btnCloseSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSave];

    
    // Le pone un borde a los editores UIViewText y se añade como delegate de los campos de texto
    for(id subview in self.scrollView.subviews){
        if([subview isKindOfClass:UITextView.class]) {
            UITextView *textView = subview;
            textView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.25] CGColor];
            textView.layer.borderWidth = 2.0;
            textView.layer.cornerRadius = 6.0;
            textView.clipsToBounds = YES;
            textView.delegate = self;
        } else if([subview isKindOfClass:UITextField.class]) {
            UITextField *textField = subview;
            textField.delegate = self;
        }
    }
    
    
    // Establece un gestor de gestos para retirar el teclado cuando se toque fuera de un editor
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    // Pone el color de fondo para los editorres
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"myTableBg"]];

    
    // Actualiza los campos desde la entidad a editar
    [self _setFieldValuesFromEntity];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    
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
    self.target = nil;
    self.confirm = nil;
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
- (void) _btnCloseSave:(id)sender {
    
    // Actualiza la entidad en edicion con los valores de los campos
    [self _setEntityFromFieldValues];

    // Avisa de que el editor se quiere cerrar
    NSNumber *close = [NSNumber numberWithBool:YES];
    SuppressPerformSelectorLeakWarning(
        [self.target performSelector:self.confirm withObject:self withObject:self.entity];
    );
    if(close.boolValue) {
        [self _dismissEditor];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseCancel:(id)sender {
    
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
- (void) _setFieldValuesFromEntity {
    [[NSException exceptionWithName:@"AbstractMethodException"
                             reason:@"_setFieldValuesFromEntity must be implemented by subclass"
                           userInfo:nil] raise];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues {
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




@end

