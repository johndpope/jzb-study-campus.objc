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

#import "MCategory.h"

#import "ScrollableToolbar.h"

#import "NSManagedObjectContext+Utils.h"
#import "UIView+FirstResponder.h"
#import "SVProgressHUD.h"



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

#define BTN_ID_EDIT_OK         4001
#define BTN_ID_EDIT_CANCEL     4002
#define BTN_ID_EDIT            4003

#define ITEMSETID_VIEW      1001
#define ITEMSETID_EDIT      1002



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface EntityEditorViewController() <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, assign) UILabel *titleBar;
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) ScrollableToolbar *scrollableToolbar;

@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL wasSaved;
@property (nonatomic, assign) BOOL startEditing;
@property (nonatomic, strong) TCloseSavedCallback closeSavedCallback;
@property (nonatomic, assign) BOOL alreadyDismissed;

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
- (void) initWithEntity:(MBaseEntity *)entity moContext:(NSManagedObjectContext *)moContext {

    if(entity!=nil && moContext!=nil) {
        
        // Guarda la informacion y lanza la edicion de forma modal
        self.entity = entity;
        self.moContext = moContext;
    } else {
        DDLogVerbose(@"Warning: EntityEditorViewController-initWithEntity called with 'nil' entity or managed context");
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) showModalWithController:(UIViewController *)controller startEditing:(BOOL)startEditing closeSavedCallback:(TCloseSavedCallback)closeSavedCallback {

    self.closeSavedCallback = closeSavedCallback;
    self.modalTransitionStyle = [self _editorTransitionStyle];
    self.startEditing = startEditing;
    [controller presentViewController:self animated:YES completion:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (UIModalTransitionStyle) _editorTransitionStyle {
    return UIModalTransitionStyleFlipHorizontal;
}




//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];

    
    // Crea el scrollView y mueve a el todos los elementos actuales
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40-48)];
    for(UIView *subView in self.view.subviews) {
        [scrollView addSubview:subView];
    }
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    // Calcula los tamaños con el contenido actual
    [self _calcScrollContentSize];
    
    
    // Crea la barra de titulo, el scrollView y la de herramientas
    UILabel *titleBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
    titleBar.textAlignment = NSTextAlignmentCenter;
    titleBar.textColor = [UIColor whiteColor];
    titleBar.font = [UIFont boldSystemFontOfSize:18];
    titleBar.text = [self _editorTitle];
    titleBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"breadcrumb-barBg"]];
    [self.view addSubview:titleBar];
    self.titleBar = titleBar;

    
    // Crea el boton de back
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0,5,50,30)];
    [btnBack setImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(_btnCloseBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];

    
    // Crea la barra de herramientas con las opciones por defecto
    ScrollableToolbar *scrollableToolbar = [[ScrollableToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-51, self.view.frame.size.width, 51)];
    [self.view addSubview:scrollableToolbar];
    self.scrollableToolbar = scrollableToolbar;

    

    // Procesa, forma recursiva, todos los controles de edicion de texto
    [self _processAllTextControlsIn:self.view];
    
    // Establece un control de gestos para retirar el teclado cuando se toque fuera de un editor
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    // Pone el color de fondo para los editorres
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"myTableBg"]];

    
    // Actualiza los campos desde la entidad a editar
    [self _setFieldValuesFromEntity];
    
    // Los deshabilita inicialmente
    [self _disableFieldsFromEditing];

}


//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if(self.wasNewAdded || self.startEditing || self.isEditing) {
        if(self.wasNewAdded) self.isEditing = YES;
        [self _begingEditing];
    } else {
        if(self.scrollableToolbar.itemSetID!=ITEMSETID_VIEW) {
            NSArray *defaultBtns = [self _tbItemsForDefaultOptions];
            [self.scrollableToolbar setItems:defaultBtns itemSetID:ITEMSETID_VIEW animated:YES];
        }
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
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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

    CGRect rect =    CGRectMake(self.scrollView.frame.origin.x,
                                self.scrollView.frame.origin.y,
                                self.scrollView.frame.size.width,
                                self.scrollView.frame.size.height - keyboardSize.height+51);

    self.scrollView.frame = rect;
}

//---------------------------------------------------------------------------------------------------------------------
-(void) _keyboardWillHide:(NSNotification*)notification {
    
    CGFloat maxScrollHeight = self.view.frame.size.height-40-48;
    
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,
                                       self.scrollView.frame.origin.y,
                                       self.scrollView.contentSize.width,
                                       maxScrollHeight);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _calcScrollContentSize {
    
    CGFloat maxHeight = -1;
    for(UIView *subView in self.scrollView.subviews) {
        CGFloat h = subView.frame.origin.y+subView.frame.size.height;
        maxHeight = MAX(maxHeight, h);
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, maxHeight);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _processAllTextControlsIn:(UIView *)view {
    
    // Le pone un borde a los editores UIViewText y se añade como delegate de los campos de texto
    for(id subview in view.subviews){
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

        // Itera con los elementos de esta subview
        [self _processAllTextControlsIn:subview];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _nullifyEditor {
    
    // Set properties to nil
    self.entity = nil;
    self.associatedEntity = nil;
    self.moContext = nil;
    self.scrollableToolbar = nil;
    self.scrollView = nil;
    self.titleBar = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _dismissEditor {

    if(!self.alreadyDismissed) {
        
        // Avisa al llamante de que se cierra si se salvo la entidad
        if(self.wasSaved && self.closeSavedCallback!=nil) {
            self.closeSavedCallback(self.entity);
        }
        
        // Cierra el teclado y la ventana modal
        [self.view findFirstResponderAndResign];
        
        // Libera informacion asociada
        [self _nullifyEditor];
        
        // Cierra el editor
        [self dismissViewControllerAnimated:YES completion:nil];
        
        // Recuerda que ya se retiro el editor
        self.alreadyDismissed = YES;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseBack:(id)sender {

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
- (void) _rotateView:(UIView *)view {

    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotate.duration = 0.5f;
    rotate.repeatCount = 1;
    [view.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [view.layer addAnimation:rotate forKey:@"trans_rotation"];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _createTagsViewContent:(UIView *)view categories:(NSSet *)categories nextView:(UIView *)nextView {
    
    CGFloat maxWidth = view.frame.size.width / 3;
    NSMutableArray *tags = [NSMutableArray array];
    
    // Primero elimina cualquier cosa anterior que pudiese haber y reestablece el tamaño por defecto
    for(UIView *subview in view.subviews) {
        [subview removeFromSuperview];
    }
    CGRect rect = view.frame;
    rect.size.height = 0;
    view.frame = rect;
    
    // Crea un array de TAGs a partir de las categorias y lo ordena por tamaño para que quepan mas en una linea
    if(categories.count>0) {
        for(MCategory *category in categories) {
            [tags addObject:[self _tagImageViewWithlabel:category.name icon:category.entityImage maxWidth:maxWidth enabled:YES]];
        }
    }else {
        [tags addObject:[self _tagImageViewWithlabel:@"No Tags" icon:nil maxWidth:maxWidth enabled:NO]];
    }
    
    
    [tags sortUsingComparator:^NSComparisonResult(UIImageView *tagImgView1, UIImageView *tagImgView2) {
        return [[NSNumber numberWithFloat:tagImgView1.frame.size.width] compare:[NSNumber numberWithFloat:tagImgView2.frame.size.width]];
    }];
    
    
    // Itera el array de tags añadiendo lineas en la vista contenedora indicada
    CGFloat maxPX = view.frame.size.width;
    CGFloat maxPY = view.frame.size.height;
    CGFloat py = 0;
    CGFloat px = 0;
    for(UIImageView *tagImgView in tags) {
        
        if(px+tagImgView.frame.size.width>maxPX) {
            px = 0;
            py += tagImgView.frame.size.height;
        }
        
        if(maxPY<py+tagImgView.frame.size.height) {
            maxPY=py+tagImgView.frame.size.height;
        }
        
        tagImgView.frame = CGRectOffset(tagImgView.frame, px, py);
        [view addSubview:tagImgView];
        
        px += tagImgView.frame.size.width;
    }
    
    
    // Ajusta la altura de la vista contenedora y de la siguiente
    if(maxPY!=view.frame.size.height) {
        CGRect rect = view.frame;
        rect.size.height = maxPY;
        view.frame = rect;
        
        if(nextView!=nil) {
            rect = nextView.frame;
            rect.origin.y = view.frame.origin.y+maxPY+10;
            nextView.frame = rect;
        }
    }
    
    // Con los nuevos tamaños ajusta el scroll
    [self _calcScrollContentSize];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (UIImageView *) _tagImageViewWithlabel:(NSString *)label icon:(UIImage *)icon maxWidth:(CGFloat)maxWidth enabled:(BOOL)enabled {
    
    // Font a utilizar en la creacion de las etiquetas
    __strong static UIFont *_lblFontEnabled = nil;
    __strong static UIFont *_lblFontDisabled = nil;
    if(_lblFontEnabled==nil) {
        _lblFontEnabled = [UIFont fontWithName:@"Avenir-Medium" size:13];
        _lblFontDisabled = [UIFont fontWithName:@"Avenir-BookOblique" size:13];
        
    }
    
    // Color para el texto habilitado y deshabilitado
    __strong static UIColor *_lblColorEnabled = nil;
    __strong static UIColor *_lblColorDisabled = nil;
    if(_lblColorEnabled==nil) {
        _lblColorEnabled = [UIColor colorWithRed:0.1961 green:0.3098 blue:0.5216 alpha:1.0];
        _lblColorDisabled = [UIColor colorWithRed:0.6392 green:0.6392 blue:0.6392 alpha:1.0];
    }
    
    // Imagen de fondo de las etiquetas habilitadas y deshabilitadas
    __strong static UIImage *_tagBgImgEnabled = nil;
    __strong static UIImage *_tagBgImgDisabled = nil;
    if(_tagBgImgEnabled==nil) {
        _tagBgImgEnabled = [[UIImage imageNamed:@"tag"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 28, 8, 14) resizingMode:UIImageResizingModeStretch];
        _tagBgImgDisabled = [[UIImage imageNamed:@"tag-disabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 28, 8, 14) resizingMode:UIImageResizingModeStretch];
    }
    
    
    // Elige el valor adecuado para el estado de "enabled"
    UIImage *_tagBgImg = enabled ? _tagBgImgEnabled : _tagBgImgDisabled;
    UIColor *_lblColor = enabled ? _lblColorEnabled : _lblColorDisabled;
    UIFont *_lblFont = enabled ? _lblFontEnabled : _lblFontDisabled;
    
    
    // Calcula el tamaño del texto estableciendo (maxWidth x 24) pt como el maximo
    CGSize _lblSize=[label sizeWithFont:_lblFont constrainedToSize:CGSizeMake(maxWidth, 24) lineBreakMode:NSLineBreakByCharWrapping];
    
    // Calcula las dimensiones totales de la etiqueta
    CGSize totalSize = CGSizeMake(28 + _lblSize.width + 14, _tagBgImg.size.height);
    
    // Crea el UIImageView
    UIImageView *tagImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2, totalSize.width, totalSize.height)];
    tagImgView.image = _tagBgImg;
    
    // Añade el texto
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(28, 0+(_tagBgImg.size.height-_lblSize.height)/2, _lblSize.width, _lblSize.height)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = _lblColor;
    lbl.text = label;
    lbl.font = _lblFont;
    [tagImgView addSubview:lbl];
    
    // Añade el icono reducido a 16x16
    UIImageView *_tagIcon = [[UIImageView alloc] initWithImage:[self _scaleImage:icon toSize:CGSizeMake(16.0, 16.0)]];
    _tagIcon.frame = CGRectOffset(_tagIcon.frame, 6.5, 6);
    [tagImgView addSubview:_tagIcon];
    
    // Retorna el UIImageView resultante
    return tagImgView;
}

//---------------------------------------------------------------------------------------------------------------------
-(UIImage*) _scaleImage: (UIImage*)image toSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tbItemsForDefaultOptions {
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:
                             [STBItem itemWithTitle:@"Edit Info" image:[UIImage imageNamed:@"btn-edit"] tagID:BTN_ID_EDIT target:self action:@selector(_begingEditing)],
                             nil];
    
    NSArray *others = [self _tbItemsDefaultOthers];
    if(others!=nil) {
        [items addObjectsFromArray:others];
    }

    return items;
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
- (NSArray *) _tbItemsDefaultOthers {
    return  nil;
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
- (NSString *) _validateFields {
    [[NSException exceptionWithName:@"AbstractMethodException"
                             reason:@"_validateFields must be implemented by subclass"
                           userInfo:nil] raise];
    return nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _begingEditing {

    // Si no estaba ya en edicion (se inicio asi el editor) crea un contexto hijo y copias de las entidades
    if(!self.isEditing) {
        
        // Crea un contexto hijo para que cualquier cambio ocurra ahi
        NSManagedObjectContext *childMoc = self.moContext.childContext;
        self.moContext = childMoc;
        
        // Hace una copia de la entidad para poder deshechar los cambios (suyos y de las relaciones)
        MBaseEntity *copyOfEntity = (MBaseEntity *)[childMoc objectWithID:self.entity.objectID];
        self.entity = copyOfEntity;
        
        // Si hay una entidad asociada en este editor hace lo mismo con ella
        if(self.associatedEntity!=nil) {
            MBaseEntity *copyOfEntity = (MBaseEntity *)[childMoc objectWithID:self.associatedEntity.objectID];
            self.associatedEntity = copyOfEntity;
        }
    }
    
    // Activa los controles de edicion para que se puedan hacer cambios
    [self _enableFieldsForEditing];

    // Establece las nuevas opciones de la barra de herramientas
    if(self.scrollableToolbar.itemSetID!=ITEMSETID_EDIT) {
        NSArray *editingBtns = [self _tbItemsForEditing];
        [self.scrollableToolbar setItems:editingBtns itemSetID:ITEMSETID_EDIT animated:YES];
    }
    
    // Marca que esta editando
    self.isEditing = YES;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _endEditingCommon {

    // Desactiva de nuevo los controles de edicion para evitar cambios
    [self _disableFieldsFromEditing];
    
    // Reestablece las opciones por defecto del modo normal
    NSArray *defaultBtns = [self _tbItemsForDefaultOptions];
    [self.scrollableToolbar setItems:defaultBtns itemSetID:ITEMSETID_VIEW animated:YES];
    
    // Establece que ya no esta en modo de edicion
    self.isEditing = NO;
    
    // Si se termina la edicion de un elemento que se estaba añadiendo o que comenzon editando se cierra el editor
    if(self.wasNewAdded || self.startEditing || self.entity==nil) {
        [self _dismissEditor];
    }

}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _endEditingCancel {
    
    // Deshecha el contexto hijo con todos sus cambios (restaura los originales)
    NSManagedObjectContext *parentMoc = self.moContext.parentContext;
    
    // La entidad previa solo existira en el contexto hijo si no fue de nueva creacion (directamente en el contexto hijo)
    if(!self.wasNewAdded) {
        MBaseEntity *copyOfEntity = (MBaseEntity *)[parentMoc objectWithID:self.entity.objectID];
        self.entity = copyOfEntity;
        if(self.associatedEntity!=nil) {
            MBaseEntity *copyOfEntity = (MBaseEntity *)[parentMoc objectWithID:self.associatedEntity.objectID];
            self.associatedEntity = copyOfEntity;
        }
    } else {
        self.entity = nil;
        self.associatedEntity = nil;
        
    }
    self.moContext = parentMoc;

    
    // Revierte cualquier cambio que se haya podido hacer
    // Si existe la entidad (no existiria en un cancel de un ADD_NEW)
    if(self.entity) {
        [self _setFieldValuesFromEntity];
    }

    // Restaura el estado al modo normal
    [self _endEditingCommon];    
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _endEditingSave {
    
    // Valida la informacion antes de salvarla
    NSString *errorMsg = [self _validateFields];
    if(errorMsg!=nil) {
        [SVProgressHUD showErrorWithStatus:errorMsg];
        return;
    }
    
    // Establece los valores de la entidad desde los controles
    [self _setEntityFromFieldValues];

    // Graba los cambios en todos los contextos y desecha el contexto hijo
    NSManagedObjectContext *childContext = self.moContext;
    NSManagedObjectContext *parentContext = self.moContext.parentContext;
    [childContext saveChanges];
    [parentContext saveChanges];
    
    // Recupera la informacion en el contexto padre
    self.moContext = parentContext;
    
    MBaseEntity *copyOfEntity = (MBaseEntity *)[self.moContext objectWithID:self.entity.objectID];
    self.entity = copyOfEntity;
    if(self.associatedEntity!=nil) {
        MBaseEntity *copyOfEntity = (MBaseEntity *)[self.moContext objectWithID:self.associatedEntity.objectID];
        self.associatedEntity = copyOfEntity;
    }
    
    // Refresca los valores de los controles desde la entidad para tener la seguridad de que todo esta sincronizado
    [self _setFieldValuesFromEntity];

    // Recuerda que la entidad fue salvada y, por tanto, posiblemente fue modificada.
    self.wasSaved = YES;

    // Restaura el estado al modo normal
    [self _endEditingCommon];
}





@end

