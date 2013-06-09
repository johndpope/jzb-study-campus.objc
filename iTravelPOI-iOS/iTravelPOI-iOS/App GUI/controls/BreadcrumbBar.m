//
//  BreadcrumbBar.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __BreadcrumbBar__IMPL__
#import "BreadcrumbBar.h"

#import <QuartzCore/QuartzCore.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define SHADOW_CAP_SIZE 2.0




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface BreadcrumbBar()

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableDictionary *dataForItems;
@property (nonatomic, assign) NSUInteger innerCount;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation BreadcrumbBar




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------






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
    
    // Inicializa el diccionario con la informacion asociada a los items
    self.dataForItems = [NSMutableDictionary dictionary];
    
    // Pone a cero la cuenta de elementos
    self.innerCount = 0;
    
    // Crea el scrollview que sirve de apoyo
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-SHADOW_CAP_SIZE)];
    scrollView.contentSize = CGSizeMake(0, scrollView.frame.size.height);
    scrollView.tag = -1;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;

    // Establece el fondo de la barra
    [self setBackgroundColor:[UIColor colorWithPatternImage:BreadcrumbBar.barBgImage]];
}




//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) addItemWithTitle:(NSString *)title image:(UIImage *)image data:(id)data {

    // Se necesita informacion del ultimo elemento añadido
    UIButton *lastAddedItem = [self _findLastAddedItem];

    // Si había una animacion previa la cancela y ajusta los valores 
    if(lastAddedItem.layer.animationKeys) {
        [lastAddedItem.layer removeAllAnimations];
        lastAddedItem.frame = CGRectOffset(lastAddedItem.frame, -4, 0);
    }
    
    // Crea una nueva instancia para representar el pathItem requerido
    __block UIButton *newItem = [self _createNewItemWithTitle:title image:image];
    
    // Si se indico algun tipo de informacion asociada se almacena
    [self.dataForItems setObject:(data!=nil ? data : NSNull.null) forKey:[NSNumber numberWithInteger:newItem.tag]];
    
    // Lo añade "debajo" del resto de elementos para "moverlo" a su posicion final
    // y ajusta el tamaño del contenido para tenerlo en cuenta (sabiendo que se solapa con el anterior)
    if(lastAddedItem) {
        [self.scrollView insertSubview:newItem belowSubview:lastAddedItem];
    } else {
        [self.scrollView addSubview:newItem];
    }
    CGFloat newContentWidth = self.scrollView.contentSize.width + newItem.frame.size.width - BreadcrumbBar.sizeBgImageCap;
    self.scrollView.contentSize = CGSizeMake(newContentWidth, self.scrollView.frame.size.height);
    
    // Al anterior ultimo elemento se le debe cambiar la imagen de fondo
    [lastAddedItem setBackgroundImage:BreadcrumbBar.unactiveBgImage forState:UIControlStateNormal];
    
    // Anima la aparicion del elemento
    [UIView animateWithDuration:0.3 animations:^{
        
        // Coloca el elemento en su posicion final + un poquito para "rebotar" 4 puntos
        newItem.frame = CGRectOffset(newItem.frame, newItem.frame.size.width-BreadcrumbBar.sizeBgImageCap+4, 0);
        
        // Ajusta la posicion de offset del contenido (scroll) para que lo ultimo sea visible
        if(self.scrollView.contentSize.width > self.scrollView.frame.size.width) {
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.frame.size.width, 0);
        } else {
            self.scrollView.contentOffset = CGPointMake(0, 0);
        }
        
    } completion:^(BOOL finished) {
        
        // Cuando termina la anterior animacion, "rebota" hacia atras y lo deja en su sitio
        if(finished) {
            [UIView animateWithDuration:0.1 animations:^{
                newItem.frame = CGRectOffset(newItem.frame, -4, 0);
            }];
        }
    }];
    
    // Incrementa la cuenta de elementos
    self.innerCount += 1;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSUInteger) count {
    return self.innerCount;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isEnabled {
    
    return self.scrollView.scrollEnabled;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)setEnabled:(BOOL)enabled {
    
    self.scrollView.scrollEnabled = enabled;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        btn.enabled = enabled;
    }];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
+ (UIFont *) labelFont {

    static UIFont *__lblFont = nil;
    if(__lblFont==nil) {
        __lblFont = [UIFont systemFontOfSize:15];
    }
    return __lblFont;
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) activeBgImage {
  
    UIImage *__activeBgImage = nil;
    if(__activeBgImage==nil){
        __activeBgImage = [[UIImage imageNamed:@"breadcrumb-active-path"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 13, 5, 13) resizingMode:UIImageResizingModeStretch];
    }
    return __activeBgImage;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) unactiveBgImage {
    
    UIImage *__unactiveBgImage = nil;
    if(__unactiveBgImage==nil){
        __unactiveBgImage = [[UIImage imageNamed:@"breadcrumb-unactive-path"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 13, 5, 13) resizingMode:UIImageResizingModeStretch];
    }
    return __unactiveBgImage;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) barBgImage {
    
    UIImage *__unactiveBgImage = nil;
    if(__unactiveBgImage==nil){
        __unactiveBgImage = [[UIImage imageNamed:@"breadcrumb-barBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch];
    }
    return __unactiveBgImage;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (CGFloat) sizeBgImageCap {

    // Se da por hecho que ambos valores, izquierdo y derecho, son iguales
    static CGFloat __sizeBgImageCaps = -1;
    if(__sizeBgImageCaps == -1) {
        __sizeBgImageCaps = BreadcrumbBar.activeBgImage.capInsets.left;
    }
    return __sizeBgImageCaps;
    
}

//---------------------------------------------------------------------------------------------------------------------
+ (NSInteger) nextTag {
    
    static NSInteger __nextTag = 0;
    return ++__nextTag;
}

//---------------------------------------------------------------------------------------------------------------------
- (CGFloat) maxPathItemWidth {

    // En principio podría ser tan grande como el ancho del frame menos lo que se reserve
    // Por si acaso la pantalla "rota" cogeremos el ancho del dispositivo como punto de partida
    // (Item inicial de Home, un botón al final, etc)
    return [[UIScreen mainScreen] applicationFrame].size.width * 2 * 40; // Le damos 40 puntos a cada lado para "botones";
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _itemClicked:(UIButton *)sender {
    
    
    // Si el elemento pulsado es el ultimo no se hace nada
    if(sender==self.scrollView.subviews[0]) {
        return;
    }
    
    // Ajusta la cuenta de elmentos que quedaran (hace falta por si se llama a count desde el delegate)
    self.innerCount = [self _indexOfItemPlusOne:sender];
    
    // Avisa al delegate de los cambios
    [self _callDelegateWithNewActiveItem:sender];
    
    // Hay que "quitar" todos los items que esten a la derecha del presionado (animado)
    [UIView animateWithDuration:0.3 animations:^{
        
        // Los mueve hacia la izquierda
        for(UIButton *item in self.scrollView.subviews) {
            if(item==sender) break;
            CGFloat offsetX = item.frame.origin.x - sender.frame.origin.x + item.frame.size.width;
            item.frame = CGRectOffset(item.frame, -offsetX, 0);
        }
        
        // Al seleccionado hay que cambiarle la imagen de fondo
        [sender setBackgroundImage:BreadcrumbBar.activeBgImage forState:UIControlStateNormal];
        
        // Ajusta el tamaño del contenido
        CGFloat newContentWidth = sender.frame.origin.x + sender.frame.size.width;
        self.scrollView.contentSize = CGSizeMake(newContentWidth, self.scrollView.frame.size.height);
        
        // Ajusta la posicion de offset del contenido (scroll) para que lo ultimo sea visible
        if(self.scrollView.contentSize.width > self.scrollView.frame.size.width) {
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.frame.size.width, 0);
        } else {
            self.scrollView.contentOffset = CGPointMake(0, 0);
        }
        
    } completion:^(BOOL finished) {
        
        // Destruye todos los elementos que hemos ocultado
        for(UIButton *subview in self.scrollView.subviews) {

            if(subview==sender) break;
            // Elimina el elemento de su vista padre
            [subview removeFromSuperview];
        }
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _callDelegateWithNewActiveItem:(UIButton *)activeItem {

    // Avisa al delegate con el "data" asociado
    NSUInteger removedItemsCount = 0;
    for(UIButton *subview in self.scrollView.subviews) {
        
        if(subview==activeItem) break;
        
        // Avisa al delegate de que se elimina un elemento
        id aKey = [NSNumber numberWithInteger:subview.tag];
        id data = [self.dataForItems objectForKey:aKey];
        if(data==NSNull.null) {
            data = nil;
        }
        [self.dataForItems removeObjectForKey:aKey];
        if([self.delegate respondsToSelector:@selector(itemRemovedFromBreadcrumbBar:removedItemTitle:removedItemData:)]) {
            [self.delegate itemRemovedFromBreadcrumbBar:self removedItemTitle:subview.titleLabel.text removedItemData:data];
        }
        
        // incrementa la cuenta de elementos eliminados
        removedItemsCount++;
    }
    
    // Avisa al delegate de que hay un nuevo elemento activo
    if([self.delegate respondsToSelector:@selector(activeItemUptatedInBreadcrumbBar:activeItemTitle:activeItemData:removedItemsCount:)]) {
        id aKey = [NSNumber numberWithInteger:activeItem.tag];
        id data = [self.dataForItems objectForKey:aKey];
        if(data==NSNull.null) {
            data = nil;
        }
        [self.delegate activeItemUptatedInBreadcrumbBar:self
                                        activeItemTitle:activeItem.titleLabel.text
                                         activeItemData:data
                                      removedItemsCount:removedItemsCount];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (UIButton *) _createNewItemWithTitle:(NSString *)title image:(UIImage *)image {

    // Se necesita informacion del ultimo elemento añadido
    UIButton *lastAddedItem = self.scrollView.subviews.count>0 ? self.scrollView.subviews[0] : nil;
    
    // Calcula el tamaño del elemento en funcion del texto y los espacios a los lados de este
    CGSize titleSize=[title sizeWithFont:BreadcrumbBar.labelFont forWidth:self.maxPathItemWidth lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat itemWidth = 2 * BreadcrumbBar.sizeBgImageCap + titleSize.width + 2*3; // Le añade 3 puntos de extra a ambos lados

    // Añade el tamaño de la imagen
    itemWidth += image.size.width;
    
    // El item estara representado por un boton tipo custom
    // Su posicion inicial será "debajo" del ultimo elemento para "aparecer" con una animacion
    UIButton *newItem = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat initialX = lastAddedItem.frame.origin.x + lastAddedItem.frame.size.width - itemWidth;
    newItem.frame = CGRectMake(initialX, 0, itemWidth, self.scrollView.frame.size.height);
    
    // Establece el fondo en un estado "activo"
    [newItem setBackgroundImage:BreadcrumbBar.activeBgImage forState:UIControlStateNormal];

    // Establece el texto indicado, asi como el font y el color
    [newItem setTitle:title forState:UIControlStateNormal];
    [newItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    newItem.titleLabel.font = BreadcrumbBar.labelFont;
    
    // Establece la imagen especificada
    [newItem setImage:image forState:UIControlStateNormal];
    
    // Asigna el  siguiente TAG en la secuencia
    newItem.tag = BreadcrumbBar.nextTag;
    
    // Los eventos del boton se dirigen a un metodo interno
    [newItem addTarget:self action:@selector(_itemClicked:) forControlEvents:UIControlEventTouchUpInside];

    // Retorna el elemento creado
    return newItem;
}

//---------------------------------------------------------------------------------------------------------------------
- (UIButton *) _findLastAddedItem {
    
    for(UIView *subview in self.scrollView.subviews) {
        if([subview isKindOfClass:UIButton.class]) {
            return (UIButton *)subview;
        }
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSUInteger) _indexOfItemPlusOne:(UIView *)item {
    
    int n=self.scrollView.subviews.count;
    for(UIView *subView in self.scrollView.subviews) {
        if(subView==item) return n;
        n--;
    }
    return -1;
}



@end

