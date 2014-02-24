//
//  BaseKeyboardViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 03/01/14.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

#import "BaseKeyboardViewController.h"
#import "Util_Macros.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface BaseKeyboardViewController () <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL      notifiedWillShow;
@property (nonatomic, assign) BOOL      notifiedDidShow;
@property (nonatomic, assign) CGSize    prevSize;

@property (nonatomic, assign) CGRect    keyboardRect;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation BaseKeyboardViewController


@synthesize isKeyboardVisible = _isKeyboardVisible;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isKeyboardVisible {
    return self.notifiedWillShow|self.notifiedDidShow;
}

//---------------------------------------------------------------------------------------------------------------------
- (CGSize) calcNewKeyboardContentViewSize:(UIView *)aView kbRect:(CGRect)kbRect {
    
    // Pone al teclado y la vista en el mismo origen de coordenadas
    CGRect aViewRect = [self.view convertRect:aView.frame fromView:aView];

    // Retorna la nueva altura de la ventana para quitarla de debajo del teclado
    CGFloat newHeight = kbRect.origin.y-aViewRect.origin.y;
    return CGSizeMake(aView.frame.size.width, newHeight);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) keyboardWillShow {
    
    // Si se ha establecido una vista con el contenido la redimensiona
    if(!self.kbContentView) return;
    UIView *kbContentView = self.kbContentView;
    
    // El comportamiento depende de si kbContentView esta dentro de un UIScrollView
    if(![kbContentView.superview isKindOfClass:UIScrollView.class]) {
        
        CGSize newSize = [self calcNewKeyboardContentViewSize:kbContentView kbRect:self.keyboardRect];
        self.prevSize = kbContentView.frame.size;
        frameSetSize(kbContentView, newSize.width, newSize.height);
        
    } else {
        
        UIScrollView *sv = (UIScrollView *)kbContentView.superview;
        sv.contentInset = (UIEdgeInsets){0, 0, self.keyboardRect.size.height, 0};
        sv.contentSize = kbContentView.frame.size;
        
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) keyboardDidShow {
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) keyboardWillHide {
    
    // Si se ha establecido una vista con el contenido la redimensiona
    if(!self.kbContentView) return;
    UIView *kbContentView = self.kbContentView;
    
    // El comportamiento depende de si kbContentView esta dentro de un UIScrollView
    if(![kbContentView.superview isKindOfClass:UIScrollView.class]) {
        
        frameSetSize(kbContentView, self.prevSize.width, self.prevSize.height);
        
    } else {
        
        UIScrollView *sv = (UIScrollView *)kbContentView.superview;
        sv.contentInset = (UIEdgeInsets){0, 0, 0, 0};
        sv.contentSize = kbContentView.frame.size;
        
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) keyboardDidHide {
    
}






//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}


//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Establece un control de gestos para retirar el teclado cuando se toque fuera de un editor
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}


//---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (CGRect) _keyboardRectFromNotification:(NSNotification*)notification {
    
    // Consigue el tamaño del teclado
    NSDictionary* info = [notification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation==UIDeviceOrientationLandscapeLeft || orientation==UIDeviceOrientationLandscapeRight) {
        keyboardRect.origin.y = 0;
        CGFloat value = keyboardRect.size.width;
        keyboardRect.size.width = keyboardRect.size.height;
        keyboardRect.size.height = value;

        keyboardRect.origin.x = 0;
        keyboardRect.origin.y = [UIScreen mainScreen].bounds.size.width-keyboardRect.size.height;
    } else {
        keyboardRect.origin.x = 0;
        keyboardRect.origin.y = [UIScreen mainScreen].bounds.size.height-keyboardRect.size.height;
    }
    

    return keyboardRect;
}

//---------------------------------------------------------------------------------------------------------------------
-(void) __keyboardWillShow:(NSNotification*)notification {
    
    // Previene que se redimensione varias veces
    if(self.notifiedWillShow) return;

    // Recuerda que redimensiono
    self.notifiedWillShow = TRUE;
    self.notifiedDidShow = FALSE;

    // Recuerda la posicion del teclado
    self.keyboardRect = [self _keyboardRectFromNotification:notification];
    
    
    // Realiza los cambios dentro de una animacion
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    //NSNumber *animationDuration = [notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView beginAnimations:nil context:nil];
    //[UIView setAnimationDuration:animationDuration.doubleValue];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:keyboardTransitionAnimationCurve];

    // Avisa de la aparicion y el tamaño
    [self keyboardWillShow];

    [UIView commitAnimations];
}

//---------------------------------------------------------------------------------------------------------------------
-(void) __keyboardDidShow:(NSNotification*)notification {
    
    // Previene que se redimensione varias veces
    if(self.notifiedDidShow) return;
    
    // Recuerda que redimensiono
    self.notifiedWillShow = TRUE;
    self.notifiedDidShow = TRUE;
    
    // Recuerda la posicion del teclado
    self.keyboardRect = [self _keyboardRectFromNotification:notification];

    // Avisa de la aparicion y el tamaño
    [self keyboardDidShow];
}

//---------------------------------------------------------------------------------------------------------------------
-(void) __keyboardWillHide:(NSNotification*)notification {
    
    // Previene que se redimensione varias veces
    if(!self.notifiedWillShow) return;

    // Recuerda que se restauro
    self.notifiedWillShow = FALSE;

    // Recuerda la posicion del teclado
    self.keyboardRect = [self _keyboardRectFromNotification:notification];

    // Avisa de la aparicion y el tamaño
    [self keyboardWillHide];
}

//---------------------------------------------------------------------------------------------------------------------
-(void) __keyboardDidHide:(NSNotification*)notification {
    
    // Previene que se redimensione varias veces
    if(!self.notifiedDidShow) return;
    
    // Recuerda que se restauro
    self.notifiedDidShow = FALSE;
    self.notifiedWillShow = FALSE;

    // Recuerda la posicion del teclado
    self.keyboardRect = [self _keyboardRectFromNotification:notification];

    // Avisa de la aparicion y el tamaño
    [self keyboardDidHide];
}

//---------------------------------------------------------------------------------------------------------------------
- (UIView *) _findFirsResponder:(UIView *)view {

    if(view.isFirstResponder) return view;
    for(UIView *subview in view.subviews) {
        UIView *frsp=[self _findFirsResponder:subview];
        if(frsp) return frsp;
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (UIView *) _findNavigationBar:(UIView *)view {
    
    if([view isKindOfClass:UINavigationBar.class]) return view;
    for(UIView *subview in view.subviews) {
        UIView *navBar=[self _findNavigationBar:subview];
        if(navBar) return navBar;
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
-(void) _dismissKeyboard:(UITapGestureRecognizer *)sender {
    
    // Si el campo activo es una UITextView, permite retirar el teclado tocando fuera
    if(!self.isKeyboardVisible) return;
    
    // Amplia los casos a la barra de navegacion en cualquier caso
    UIView *navBar = [self _findNavigationBar:self.view];
    if(navBar){
        CGPoint point = [sender locationInView:navBar];
        BOOL inSide = [navBar pointInside:point withEvent:nil];
        if(inSide) {
            [self.view endEditing:TRUE];
            return;
        }
    }
    
    UIView *frsp = [self _findFirsResponder:self.view];
    if(![frsp isKindOfClass:UITextView.class]) return;
    
    CGPoint point = [sender locationInView:frsp];
    BOOL inSide = [frsp pointInside:point withEvent:nil];
    if(!inSide) {
        [self.view endEditing:TRUE];
    }
}



@end
