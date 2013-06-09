//
//  ScrollableToolbar.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __ScrollableToolbar__IMPL__
#import "ScrollableToolbar.h"

#import <QuartzCore/QuartzCore.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define BTN_FIXED_WIDTH 72.0
#define EDIT_CANCEL_WIDTH 80.0
#define BOTTOM_TEXT_PADDING 2.0
//#define TOP_IMAGE_PADDING 8.0
#define SHADOW_CAP_SIZE 2.0


#define CGRectMakeFromFrame(x,y,frame) CGRectMake(x,y, frame.size.width, frame.size.height)
typedef void (^AnimationBlock)(void);



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation STBItem

+ (STBItem * ) itemWithTitle:(NSString *)title image:(UIImage *)image tagID:(NSUInteger)tagID target:(id)target action:(SEL)action {
   
    STBItem *me = [[STBItem alloc] init];
    me.title = title;
    me.image = image;
    me.tagID = tagID;
    me.target = target;
    me.action = action;
    return  me;
}

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface ScrollableToolbar()

@property (nonatomic, assign) UIScrollView  *scrollView;
@property (nonatomic, assign) UIView        *editModePanel;
@property (nonatomic, assign) UIButton      *confirmBtn;
@property (nonatomic, assign) UIButton      *cancelBtn;
@property (nonatomic, strong) UIImageView   *leftShadow;
@property (nonatomic, strong) UIImageView   *rightShadow;

@property (nonatomic, assign) UIButton *editingModeBtn;
@property (nonatomic, strong) NSMutableArray *btnItems;
@property (nonatomic, strong) TConfirmBlock confirmBlock;
@property (nonatomic, strong) TCancelBlock  cancelBlock;
@property (nonatomic, assign) BOOL editingWasAnimated;


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation ScrollableToolbar




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------





//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) addItem:(STBItem *)item {

    // Crea la instancia del boton que contrendra el titulo y la imagen
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(self.btnItems.count*BTN_FIXED_WIDTH,0, BTN_FIXED_WIDTH, self.scrollView.frame.size.height);
    
    // Establece los atributos
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    [btn setImage:item.image forState:UIControlStateNormal];
    [btn setTitle:item.title forState:UIControlStateNormal];
    btn.titleLabel.font = ScrollableToolbar.itemLabelFont;
    btn.tag = item.tagID;
    
    // Establece la posicion de los elementos (hay que colocar el texto 2 veces porque la primera vez podría salir truncado)
    CGSize titleSize = btn.titleLabel.frame.size;
    btn.titleEdgeInsets = UIEdgeInsetsMake(0.0, (btn.frame.size.width-titleSize.width)/2-item.image.size.width, BOTTOM_TEXT_PADDING, 0.0);
    titleSize = btn.titleLabel.frame.size;
    btn.titleEdgeInsets = UIEdgeInsetsMake(0.0, (btn.frame.size.width-titleSize.width)/2-item.image.size.width, BOTTOM_TEXT_PADDING, 0.0);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0.0, (btn.frame.size.width-item.image.size.width)/2, titleSize.height+2*BOTTOM_TEXT_PADDING, 0.0);
    
    // Los eventos del boton se dirigen al target y selector especificados
    if(item.target!=nil && item.action!=nil) {
        [btn addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
    }

    // Añade el nuebo boton al conjunto de elementos
    [self.btnItems addObject:btn];
    [self.scrollView addSubview:btn];
    
    // Ajusta la posicion de los elementos
    [self _relocateItems];
    
    // Ajusta el contentSize y el scroll
    CGFloat overallSize = self.btnItems.count * BTN_FIXED_WIDTH;
    if(overallSize<=self.scrollView.frame.size.width) {
        self.scrollView.contentSize = self.scrollView.frame.size;
        self.scrollView.bounces = NO;
    } else {
        self.scrollView.contentSize = CGSizeMake(overallSize, self.scrollView.frame.size.height);
        self.scrollView.bounces = YES;
    }
    
    // Crea las sombras a los lados que indican que hay scroll
    [self _setScrollShadows];
}


//---------------------------------------------------------------------------------------------------------------------
- (void) setItems:(NSArray *)items animated:(BOOL)animated {

    __block NSArray *theItems = items;
    
    
    // Cancela el modo de edicion
    if(self.editingModeBtn!=nil) {
        self.editModePanel.frame = CGRectMakeFromFrame(0, self.frame.size.height, self.editModePanel.frame);
        self.scrollView.frame = CGRectMakeFromFrame(0, 0, self.scrollView.frame);
        self.editingModeBtn = nil;
    }
    
    // Crea el bloque que añadira los elementos
    AnimationBlock setItemsBlock = ^(void) {
        [self removeAllItemsAnimated:NO];
        [theItems enumerateObjectsUsingBlock:^(STBItem *item, NSUInteger idx, BOOL *stop) {
            [self addItem:item];
        }];
    };

    // Actua dependiendo de si hay que animar el trabajo o no
    if(animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.frame = CGRectMakeFromFrame(0, self.frame.size.height, self.scrollView.frame);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.0 animations:^{
                setItemsBlock();
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.scrollView.frame = CGRectMakeFromFrame(0, 0, self.scrollView.frame);
                }];
            }];
        }];
    } else {
        setItemsBlock();
    }
    
    // Precalcula el tamaño que tendra al finalizar para establecer las sombras por adelantado
    CGFloat overallSize = self.btnItems.count * BTN_FIXED_WIDTH;
    self.scrollView.contentSize = CGSizeMake(overallSize, self.scrollView.frame.size.height);
    [self _setScrollShadows];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) removeAllItemsAnimated:(BOOL)animated {
    
    // Cancela el modo de edicion
    if(self.editingModeBtn!=nil) {
        self.editModePanel.frame = CGRectMakeFromFrame(0, self.frame.size.height, self.editModePanel.frame);
        self.scrollView.frame = CGRectMakeFromFrame(0, 0, self.scrollView.frame);
        self.editingModeBtn = nil;
    }
    
    // Crea el bloque que borrara todos los elementos
    AnimationBlock removeItemsBlock = ^(void) {
        [self.btnItems enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
            [btn removeFromSuperview];
        }];
        [self.btnItems removeAllObjects];
        self.scrollView.contentSize = self.scrollView.frame.size;
        [self _removeScrollShadows];
    };
    
    // Actua dependiendo de si hay que animar el trabajo o no
    if(animated) {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.frame = CGRectMakeFromFrame(0, self.frame.size.height, self.scrollView.frame);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 removeItemsBlock();
                                 self.scrollView.frame = CGRectMakeFromFrame(0, 0, self.scrollView.frame);
                             }];
        }];
        
    } else {
        removeItemsBlock();
    }

}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isEditModeActive {
    return self.editingModeBtn!=nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) activateEditModeForItemWithTagID:(NSUInteger)tagID
                                 animated:(BOOL)animated
                             confirmBlock:(TConfirmBlock)confirmBlock
                              cancelBlock:(TCancelBlock)cancelBlock {

    // Busca el item para el cual se quiere poner en modo de edicion
    UIButton *btn = (UIButton *)[self viewWithTag:tagID];
    if(btn==nil) return;
        
    // Calcula el tamaño del boton de confirmacion en funcion del texto, la imagen y los espacios a los lados
    NSString *btnText = [NSString stringWithFormat:@"%@ (99)",btn.titleLabel.text];
    CGSize titleSize=[btnText sizeWithFont:ScrollableToolbar.editBtnLabelFont forWidth:self.editModePanel.frame.size.width/2 lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat itemWidth = btn.imageView.image.size.width  + titleSize.width + 2 * 2; // Le añade 2 puntos de extra a ambos lados
    self.confirmBtn.frame = CGRectMake(0, self.confirmBtn.frame.origin.y, itemWidth, self.confirmBtn.frame.size.height);
    
    // Establece los valores del boton de confirmacion
    [self.confirmBtn setTitle:btn.titleLabel.text forState:UIControlStateNormal];
    [self.confirmBtn setImage:btn.imageView.image forState:UIControlStateNormal];
    self.confirmBtn.enabled=NO;

    // Recoloca los botones segun el tamaño final
    CGFloat spaceWidh = (self.editModePanel.frame.size.width-self.confirmBtn.frame.size.width-self.cancelBtn.frame.size.width)/3;
    self.confirmBtn.frame = CGRectMakeFromFrame(spaceWidh, self.confirmBtn.frame.origin.y, self.confirmBtn.frame);
    self.cancelBtn.frame = CGRectMakeFromFrame(2*spaceWidh+itemWidth, self.cancelBtn.frame.origin.y, self.cancelBtn.frame);
    
    
    // Si había una animacion previa la cancela y ajusta los valores
    if(self.scrollView.layer.animationKeys || self.editModePanel.layer.animationKeys) {
        [self.scrollView.layer removeAllAnimations];
        [self.editModePanel.layer removeAllAnimations];
    }
    
    // Crea el bloque que mostrara el panel edicion
    AnimationBlock showEditPanelBlock = ^(void) {
        self.scrollView.frame = CGRectMakeFromFrame(0, self.frame.size.height, self.scrollView.frame);
        self.editModePanel.frame = CGRectMakeFromFrame(0, SHADOW_CAP_SIZE, self.editModePanel.frame);
    };

    // Actua dependiendo de si hay que animar el trabajo o no
    if(animated) {
        [UIView animateWithDuration:0.3 animations:showEditPanelBlock];
    } else {
        showEditPanelBlock();
    }
    
    //Quita las sombras
    [self _removeScrollShadows];
    
    // Almacena los bloques de codigo a utilizar como callback y si entro aqui con una animacion activa
    self.confirmBlock = confirmBlock;
    self.cancelBlock = cancelBlock;
    self.editingWasAnimated = animated;
    
    // Indica que ha entrado en modo de edicion
    self.editingModeBtn = btn;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) deactivateEditModeAnimated:(BOOL)animated {

    // Si había una animacion previa la cancela y ajusta los valores
    if(self.scrollView.layer.animationKeys || self.editModePanel.layer.animationKeys) {
        [self.scrollView.layer removeAllAnimations];
        [self.editModePanel.layer removeAllAnimations];
    }
    
    // Crea el bloque que ocultara el panel edicion
    AnimationBlock hideEditPanelBlock = ^(void) {
        self.scrollView.frame = CGRectMakeFromFrame(0, SHADOW_CAP_SIZE, self.scrollView.frame);
        self.editModePanel.frame = CGRectMakeFromFrame(0, self.frame.size.height, self.editModePanel.frame);
    };
    
    // Actua dependiendo de si hay que animar el trabajo o no
    if(animated) {
        [UIView animateWithDuration:0.3 animations:hideEditPanelBlock];
    } else {
        hideEditPanelBlock();
    }

    // Pone las sombras
    [self _setScrollShadows];
    
    // Indica que ha salido del modo de edicion
    [self enableConfirmButton:NO count:0];
    self.editingModeBtn = nil;
    
    // Avisa de que se ha cancelado si se especifico un bloque de codigo
    if(self.cancelBlock!=nil) {
        self.cancelBlock();
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) enableConfirmButton:(BOOL)enable count:(NSInteger)count {

    if(self.editingModeBtn!=nil) {
        self.confirmBtn.enabled = enable;
        NSString *text;
        if(enable && count>0) {
             text = [NSString stringWithFormat:@"%@ (%d)",self.editingModeBtn.titleLabel.text, count];
        } else {
            text = self.editingModeBtn.titleLabel.text;
        }
        [self.confirmBtn setTitle:text forState:UIControlStateNormal];
    }
}


//=====================================================================================================================
#pragma mark -
#pragma mark <UIScrollView> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
    
    self=[super initWithFrame:frame];
    if(self) [self _initializeView];
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) awakeFromNib {
    [super awakeFromNib];
    if(self) [self _initializeView];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _initializeView {
    
    // Indica que no esta editando
    self.editingModeBtn = nil;
    
    // Crea el scrollview que sirve de apoyo
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SHADOW_CAP_SIZE, self.frame.size.width, self.frame.size.height-SHADOW_CAP_SIZE)];
    scrollView.contentSize = self.frame.size;
    scrollView.tag = -1;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    // Crea el panel para el modo de edicion fuera de la vista y oculto
    UIView *editModePanel = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height-SHADOW_CAP_SIZE)];
    editModePanel.tag = -1;
    [self addSubview:editModePanel];
    self.editModePanel = editModePanel;
    
    // Crea los botones de edicion
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(0, (self.editModePanel.frame.size.height-ScrollableToolbar.bgConfirmBtnImage.size.height)/2, 0,ScrollableToolbar.bgConfirmBtnImage.size.height);
    confirmBtn.tag = -1;
    [confirmBtn setBackgroundImage:ScrollableToolbar.bgConfirmBtnImage forState:UIControlStateNormal];
    confirmBtn.enabled = NO;
    [confirmBtn setTitle:@"" forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = ScrollableToolbar.editBtnLabelFont;
    [confirmBtn addTarget:self action:@selector(_editingBtnConfirmPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.editModePanel addSubview:confirmBtn];
    self.confirmBtn = confirmBtn;

    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, (self.editModePanel.frame.size.height-ScrollableToolbar.bgCancelBtnImage.size.height)/2, EDIT_CANCEL_WIDTH,ScrollableToolbar.bgCancelBtnImage.size.height);
    cancelBtn.tag = -1;
    [cancelBtn setBackgroundImage:ScrollableToolbar.bgCancelBtnImage forState:UIControlStateNormal];
    cancelBtn.enabled = YES;
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = ScrollableToolbar.editBtnLabelFont;
    [cancelBtn addTarget:self action:@selector(_editingBtnCancelPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.editModePanel addSubview:cancelBtn];
    self.cancelBtn = cancelBtn;
    
    // Establece el fondo de la barra
    [self setBackgroundColor:[UIColor colorWithPatternImage:ScrollableToolbar.defaultBgImage]];
    
    // Crea el array para almacenar los items
    self.btnItems = [NSMutableArray array];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
+ (UIFont *) itemLabelFont {

    static UIFont *__lblFont = nil;
    if(__lblFont==nil) {
        __lblFont = [UIFont systemFontOfSize:10];
    }
    return __lblFont;
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIFont *) editBtnLabelFont {
    
    static UIFont *__editBtnLabelFont = nil;
    if(__editBtnLabelFont==nil) {
        __editBtnLabelFont = [UIFont systemFontOfSize:12];
    }
    return __editBtnLabelFont;
}


//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) defaultBgImage {
    
    UIImage *__unactiveBgImage = nil;
    if(__unactiveBgImage==nil){
        __unactiveBgImage = [UIImage imageNamed:@"scrollableBarBckgrnd"];
    }
    return __unactiveBgImage;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) bgConfirmBtnImage {
    
    UIImage *__bgConfirmBtnImage = nil;
    if(__bgConfirmBtnImage==nil){
        UIImage *img = [UIImage imageNamed:@"scrollableBarConfirmBtn"];
        __bgConfirmBtnImage =[img resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch];
    }
    return __bgConfirmBtnImage;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) bgCancelBtnImage {
    
    UIImage *__bgCancelBtnImage = nil;
    if(__bgCancelBtnImage==nil){
        UIImage *img = [UIImage imageNamed:@"scrollableBarCancelBtn"];
        __bgCancelBtnImage =[img resizableImageWithCapInsets:UIEdgeInsetsMake(6, 5, 6, 6) resizingMode:UIImageResizingModeStretch];
    }
    return __bgCancelBtnImage;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) leftShadowImage {
    
    UIImage *__leftShadowImage = nil;
    if(__leftShadowImage==nil){
        __leftShadowImage = [UIImage imageNamed:@"scrollableBarShadowLeft"];
    }
    return __leftShadowImage;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) rightShadowImage {
    
    UIImage *__rightShadowImage = nil;
    if(__rightShadowImage==nil){
        __rightShadowImage = [UIImage imageNamed:@"scrollableBarShadowRight"];
    }
    return __rightShadowImage;
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _relocateItems {
    
    if(self.btnItems.count==1) {
        // Caso especial para un elemento. Lo deja alineado a la izquierda
        UIButton *btn = self.btnItems[0];
        btn.frame = CGRectMakeFromFrame(12, btn.frame.origin.y, btn.frame);
    } else {
        // Distribuye los elementos. Espaciandolos mientras pueda y dejandolos juntos, con scroll, cuando sean muchos
        CGFloat totalSize = BTN_FIXED_WIDTH * self.btnItems.count;
        CGFloat spaceWidth;
        
        if(totalSize<self.scrollView.frame.size.width) {
            spaceWidth = (self.scrollView.frame.size.width-totalSize) / (self.btnItems.count+1);
        } else {
            spaceWidth = 0.0;
        }
                
        [self.btnItems enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
            CGFloat newX = spaceWidth + idx * (spaceWidth + BTN_FIXED_WIDTH);
            CGRect newFrame = CGRectMake(newX, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
            btn.frame = newFrame;
        }];
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _removeScrollShadows {
    
    if(self.leftShadow!=nil) {
        [self.leftShadow removeFromSuperview];
        self.leftShadow = nil;
    }
    if(self.rightShadow!=nil) {
        [self.rightShadow removeFromSuperview];
        self.rightShadow = nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setScrollShadows {

    // Las sombras se ponen o quitan dependiendo del numero de elementos y, por tanto, del contentSize
    if(self.scrollView.contentSize.width>self.scrollView.frame.size.width) {
        
        // Solo las crea si no lo estaban ya
        if(self.leftShadow==nil) {
            UIImageView *leftShadow = [[UIImageView alloc] initWithImage:[ScrollableToolbar leftShadowImage]];
            //leftShadow.frame = CGRectMakeFromFrame(0, SHADOW_CAP_SIZE, leftShadow.frame);
            leftShadow.frame = CGRectMakeFromFrame(4, (self.frame.size.height-leftShadow.frame.size.height+SHADOW_CAP_SIZE)/2, leftShadow.frame);
            leftShadow.tag = -1;
            [self insertSubview:leftShadow aboveSubview:self.scrollView];
            self.leftShadow = leftShadow;
        }
        if(self.rightShadow==nil) {
            UIImageView *rightShadow = [[UIImageView alloc] initWithImage:[ScrollableToolbar rightShadowImage]];
            //rightShadow.frame = CGRectMakeFromFrame(self.frame.size.width-rightShadow.frame.size.width, SHADOW_CAP_SIZE, rightShadow.frame);
            rightShadow.frame = CGRectMakeFromFrame(self.frame.size.width-rightShadow.frame.size.width-4, (self.frame.size.height-rightShadow.frame.size.height+SHADOW_CAP_SIZE)/2, rightShadow.frame);
            rightShadow.tag = -1;
            [self insertSubview:rightShadow aboveSubview:self.scrollView];
            self.rightShadow = rightShadow;
        }
        
    } else {

        // Si existían previamente las elimina
        [self _removeScrollShadows];
    }
        
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _editingBtnConfirmPressed:(UIButton *)sender {
    
    if(self.confirmBlock!=nil) {
        self.confirmBlock();
    }
    self.confirmBlock = nil;
    self.cancelBlock = nil;
    [self deactivateEditModeAnimated:self.editingWasAnimated];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _editingBtnCancelPressed:(UIButton *)sender {

    if(self.cancelBlock!=nil) {
        self.cancelBlock();
    }
    self.confirmBlock = nil;
    self.cancelBlock = nil;
    [self deactivateEditModeAnimated:self.editingWasAnimated];
}


@end

