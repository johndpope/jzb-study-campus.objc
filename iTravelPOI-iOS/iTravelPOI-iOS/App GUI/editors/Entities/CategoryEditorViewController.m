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
#import "CategorySelectorViewController.h"
#import "TDBadgedCell.h"
#import "UIView+FirstResponder.h"
#import "ImageManager.h"
#import "NSString+JavaStr.h"
#import "MPoint.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface CategoryEditorViewController() <UITextFieldDelegate, UITextViewDelegate,
                                           UITableViewDelegate, UITableViewDataSource,
                                           CategorySelectorDelegate, IconEditorDelegate>


@property (nonatomic, assign) IBOutlet UIImageView *iconImageField;
@property (nonatomic, assign) IBOutlet UITextField *nameField;
@property (nonatomic, assign) IBOutlet UILabel *extraInfo;
@property (nonatomic, assign) IBOutlet UITableView *parentCatTable;

@property (nonatomic, assign) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, assign) IBOutlet UISwitch *modifyInAllMaps;
@property (nonatomic, strong) IBOutlet UIView *kbToolView;

@property (nonatomic, assign) UIViewController<EntityEditorDelegate> *delegate;
@property (nonatomic, strong) NSManagedObjectContext *moContext;
@property (nonatomic, strong) MCategory *parentCat;
@property (nonatomic, strong) NSString *catIconHREF;

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
        me.parentCat = category.parent;
        me.catIconHREF = category.iconHREF;
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
    
    self.parentCatTable.backgroundColor = [UIColor clearColor];
    
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
    
    self.parentCatTable.allowsSelection = NO;
}

//---------------------------------------------------------------------------------------------------------------------
-(void)keyboardWillHide:(NSNotification*)notification {
    
    CGFloat maxScrollHeight = self.view.frame.size.height - self.navigationBar.frame.size.height;

    self.contentScrollView.frame = CGRectMake(self.contentScrollView.frame.origin.x,
                                              self.contentScrollView.frame.origin.y,
                                              self.contentScrollView.contentSize.width,
                                              maxScrollHeight);

    self.parentCatTable.allowsSelection = YES;
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
#pragma mark <IconEditorDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeIconEditor:(IconEditorViewController *)senderEditor {
    [self _setImageFieldFromIconHREF:senderEditor.iconBaseHREF];
    return true;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <CategorySelectorDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) closeCategorySelector:(CategorySelectorViewController *)senderEditor selectedCategories:(NSArray *)selectedCategories {

    MCategory *selectedCat = nil;
    if(selectedCategories.count>0) {
         selectedCat = selectedCategories[0];
    }
    
    // No puede ser su categoria padre ni el mismo, ni ningun descendiente suyo
    if(selectedCat.internalIDValue!=self.category.internalIDValue && ![selectedCat isDescendatOf:self.category]) {
        self.parentCat = selectedCat;
        [self.parentCatTable reloadData];
    }
    
    return YES;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // No dejamos nada seleccionado
    [CategorySelectorViewController startCategoriesSelectorInContext:self.moContext
                                                         selectedMap:self.map
                                                 currentSelectedCats:self.parentCat!=nil ? [NSArray arrayWithObject:self.parentCat] : nil
                                                 excludeFromCategory:self.category
                                                      multiSelection:NO
                                                            delegate:self];
    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Parent Category";
}


//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";
    
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    

    if(self.parentCat!=nil) {
        cell.imageView.image = self.parentCat.entityImage;
        cell.textLabel.text = self.parentCat.fullName;
    } else {
        cell.imageView.image = nil;
        cell.textLabel.text = @"<none>";
    }
    
    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark BIAction methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)iconImageTapAction:(UITapGestureRecognizer *)sender {
    
    // Aquí se hacia una comprobación de que no se estuviese editando un texto????
    if(sender.state == UIGestureRecognizerStateEnded) {
        [self.view findFirstResponderAndResign];
        [IconEditorViewController startEditingIcon:self.catIconHREF delegate:self];
    }
}


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
    self.catIconHREF = nil;
    self.parentCat = nil;
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
- (void) _setImageFieldFromIconHREF:(NSString *)iconHREF {
    
    IconData *icon = [ImageManager iconDataForHREF:iconHREF];
    self.catIconHREF = iconHREF;
    self.iconImageField.image = icon.image;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _setFieldValuesFromEntity {
    
    self.nameField.text = self.category.name;
    [self _setImageFieldFromIconHREF:self.category.iconHREF];
    self.extraInfo.text = [NSString stringWithFormat:@"Updated:\t%@\n",
                                       [MBaseEntity stringFromDate:self.category.updateTime]];
    
    self.modifyInAllMaps.on = YES;
    self.modifyInAllMaps.enabled = (self.map!=nil);

    [self.parentCatTable reloadData];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _setEntityFromFieldValues {

    
    NSString *catName = [self.nameField.text trim];
    if(catName.length==0) {
        IconData *icon = [ImageManager iconDataForHREF:self.catIconHREF];
        catName = icon.shortName;
    }

    
    NSString *destFullName;
    if(self.parentCat==nil) {
        // Es una categoria raiz
        destFullName = catName;
    } else {
        destFullName = [NSString stringWithFormat:@"%@%@%@",self.parentCat.fullName,CATEGORY_NAME_SEPARATOR,catName];
    }
    
    
    // Busca la categoria que concuerda con los valores actuales
    MCategory *destCat = [MCategory categoryWithFullName:destFullName inContext:self.moContext];
    
    // Si ha habido cambios en el nombre o la categoria padre hay que transferir la informacion
    if(self.category.internalIDValue!=destCat.internalIDValue) {
        destCat.iconHREF = self.catIconHREF;
        MMap *useMap = self.modifyInAllMaps.on ? nil : self.map;
        [self.category transferTo:destCat inMap:useMap];
        [self.category markAsModified];
        self.category = destCat;
    }
    
    self.category.iconHREF = self.catIconHREF;
    [self.category markAsModified];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) _allSubcategoriesFor:(MCategory *)cat allSubCats:(NSMutableArray *)allSubCats {
    
    [allSubCats addObject:cat];
    for(MCategory *subCat in cat.subCategories) {
        [self _allSubcategoriesFor:subCat allSubCats:allSubCats];
    }
}


@end

