//
//  CategoryEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __CategoryEditorViewController__IMPL__

#import <QuartzCore/QuartzCore.h>

#import "CategoryEditorViewController.h"
#import "IconEditorViewController.h"
#import "UIView+FirstResponder.h"
#import "ImageManager.h"
#import "NSString+JavaStr.h"
#import "MPoint.h"

#import "GMTItem.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface CategoryEditorViewController() <UITextFieldDelegate, UITextViewDelegate, IconEditorDelegate>


@property (nonatomic, assign) IBOutlet UIImageView *iconImageField;
@property (nonatomic, assign) IBOutlet UITextField *nameField;
@property (nonatomic, assign) IBOutlet UITextField *pathField;
@property (nonatomic, assign) IBOutlet UILabel *extraInfo;

@property (nonatomic, assign) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UIView *kbToolView;

@property (nonatomic, assign) UIViewController<EntityEditorDelegate> *delegate;
@property (nonatomic, strong) NSManagedObjectContext *moContext;
@property (nonatomic, strong) NSString *iconBaseHREF;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation CategoryEditorViewController




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (UIViewController<EntityEditorViewController> *) startEditingCategory:(MCategory *)category
                                                                  inMap:(MMap *)map
                                                               delegate:(UIViewController<EntityEditorDelegate> *)delegate {

    if(category!=nil && delegate!=nil) {
        CategoryEditorViewController *me = [[CategoryEditorViewController alloc] initWithNibName:@"CategoryEditorViewController" bundle:nil];
        me.delegate = delegate;
        me.category = category;
        me.map = map;
        me.moContext = category.managedObjectContext; // La referencia es weak y se pierde
        me.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [delegate presentViewController:me animated:YES completion:nil];
        return me;
    } else {
        DDLogVerbose(@"Warning: CategoryEditorViewController-startEditingMap called with nil Category or Delegate");
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
- (void)viewDidAppear:(BOOL)animated {
    [self _rotateImageField];
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
#pragma mark <UITextFieldDelegate, UITextViewDelegate> and Keyboard Notification methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeIconEditor:(IconEditorViewController *)senderEditor {
    [self _setImageFieldFromHREF:senderEditor.iconBaseHREF];
    return true;
}


//=====================================================================================================================
#pragma mark -
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)iconImageTapAction:(UITapGestureRecognizer *)sender {
    
    // Aquí se hacia una comprobación de que no se estuviese editando un texto????
    if(sender.state == UIGestureRecognizerStateEnded) {
        [IconEditorViewController startEditingIcon:self.iconBaseHREF delegate:self];
    }
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
    self.category = nil;
    self.map = nil;
    self.delegate = nil;
    self.moContext = nil;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _btnCloseSave:(id)sender {
    
    [self _setEntityFromFieldValues];
    if([self.delegate editorSaveChanges:self modifiedEntity:self.category]) {
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
- (void) _rotateImageField {
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotate.duration = 0.7f;
    rotate.repeatCount = 1;
    [self.iconImageField.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [self.iconImageField.layer addAnimation:rotate forKey:@"trans_rotation"];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _setImageFieldFromHREF:(NSString *)iconHREF {
    
    self.iconBaseHREF = iconHREF;
    IconData *icon = [ImageManager iconDataForHREF:iconHREF];
    self.iconImageField.image = icon.image;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    self.nameField.text = self.category.name;
    self.pathField.text = self.category.pathName;
    [self _setImageFieldFromHREF:self.category.iconBaseHREF];
    self.extraInfo.text = [NSString stringWithFormat:@"Updated:\t%@\n",
                                       [GMTItem stringFromDate:self.category.updated_date]];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues {

    // Los cambios en esta entidad son, REALMENTE, CAMBIOS EN LOS PUNTOS ASOCIADOS
    
    
    NSString *name = [self.nameField.text trim];
    if(name.length==0) {
        IconData *icon = [ImageManager iconDataForHREF:self.iconBaseHREF];
        name = icon.shortName;
    }
    
    NSString *fullCatName;
    NSString *path = [self.pathField.text trim];
    if(path.length==0) {
        fullCatName = name;
    } else {
        fullCatName = [NSString stringWithFormat:@"%@%@%@", self.pathField.text, CAT_NAME_SEPARATOR, self.nameField.text];
    }
    
    NSString *cleanCatFullName = [fullCatName replaceStr:@"&" with:@"%"];
    
    
    MCategory *destCategory = [MCategory categoryForIconBaseHREF:self.iconBaseHREF
                                                        fullName:cleanCatFullName
                                                       inContext:self.category.managedObjectContext];
    
    // Si hubo cambios relevantes actualiza los puntos impactados
    if(![self.category.objectID isEqual:destCategory.objectID]) {
        [self _movePointsFromCategory:self.category toCategory:destCategory inMap:self.map];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _movePointsFromCategory:(MCategory *)origCategory toCategory:(MCategory *)destCategory inMap:(MMap *)map {
    
    // Comprueba si se quiere mover a otra categoria diferente
    if([origCategory.objectID isEqual:destCategory.objectID]) return;
    
    // Longitud del nombre base
    NSUInteger baseFullNameLength = origCategory.fullName.length;
    
    // Recopila todas las subcateforias
    // Se hace asi por si se moviese "hacia abajo". Lo que podría hacer un bucle infinito
    NSMutableArray *allSubCats = [NSMutableArray array];
    [self _allSubcategoriesFor:origCategory allSubCats:allSubCats];
    
    // Cambia todos los puntos de cada categoria a la nueva categoria equivalente
    // Si se indica un mapa, se restringiran los puntos a los de ese mapa
    // Se están moviendo incluso los puntos borrados
    for(MCategory *cat in allSubCats) {
        
        // Caso especial en el que se mueve "hacia abajo"
        if([cat.objectID isEqual:destCategory.objectID]) continue;
        
        
        NSString *newFullName = [NSString stringWithFormat:@"%@%@", destCategory.fullName, [cat.fullName subStrFrom:baseFullNameLength]];
        
        MCategory *newSubCategory = [MCategory categoryForIconBaseHREF:destCategory.iconBaseHREF
                                                              fullName:newFullName
                                                             inContext:destCategory.managedObjectContext];
        
        NSArray *allPoints = [NSArray arrayWithArray:cat.points.allObjects];
        for(MPoint *point in allPoints) {
            if(map==nil || [point.map.objectID isEqual:map.objectID]) {
                [point moveToCategory:newSubCategory];
                [point updateModifiedMark];
                [point.map updateModifiedMark];
            }
        }
    }
    
    // Marca la hora de actualizacion de ambas categorias
    origCategory.updated_date = [NSDate date];
    destCategory.updated_date = [NSDate date];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _allSubcategoriesFor:(MCategory *)cat allSubCats:(NSMutableArray *)allSubCats {
    
    [allSubCats addObject:cat];
    for(MCategory *subCat in cat.subCategories) {
        [self _allSubcategoriesFor:subCat allSubCats:allSubCats];
    }
}


@end

