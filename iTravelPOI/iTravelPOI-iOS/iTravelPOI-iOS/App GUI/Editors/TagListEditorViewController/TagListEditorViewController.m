//
//  TagListEditorViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TagListEditorViewController__IMPL__
#import "TagListEditorViewController.h"
#import "TagTreeTableViewController.h"
#import "Util_Macros.h"
#import "UIImage+Tint.h"
#import "MMap.h"
#import "MPoint.h"
#import "MTag.h"



#import "BaseCoreDataService.h"




//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
typedef NS_ENUM(NSInteger, ActiveSection) {
    ActiveSectionAssigned,
    ActiveSectionAvailable
};




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TagListEditorViewController () <TagTreeTableViewControllerDelegate,
                                            UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>


@property (nonatomic, weak)     IBOutlet UIView             *viewContainer;
@property (nonatomic, weak)     IBOutlet UILabel            *lblSelector;
@property (nonatomic, weak)     IBOutlet UITextField        *txtNewTagName;
@property (nonatomic, weak)     IBOutlet UITableView        *assignedTagsTableView;
@property (nonatomic, strong)   TagTreeTableViewController  *tagTableView;

@property (nonatomic, strong)   NSManagedObjectContext      *moContext;
@property (nonatomic, strong)   NSMutableArray              *assignedTags;
@property (nonatomic, strong)   NSMutableSet                *availableTags;

@property (nonatomic, assign)   ActiveSection               activeSection;

@property (nonatomic, strong)   NSArray                     *searchedTags;
@property (nonatomic, assign)   BOOL                        isEditingTagName;

@property (nonatomic, assign) CGFloat                       tableHeight;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TagListEditorViewController

@synthesize activeSection = _activeSection;





//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) keyboardWillShow {
    
    [super keyboardWillShow];
    
    CGRect tblFrame = self.assignedTagsTableView.frame;
    
    // Tiene que quitar un poco mas de altura y desplazarlo hacia abajo para el textField
    CGFloat newY = self.txtNewTagName.frame.size.height + self.txtNewTagName.frame.origin.y * 2 /* espaciado */;
    CGFloat newH = self.assignedTagsTableView.frame.size.height;
    newH -= newY;
    
    self.assignedTagsTableView.frame = CGRectMake(0, newY, tblFrame.size.width, newH);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) keyboardWillHide {
    
    [super keyboardWillHide];
    
    CGRect tblFrame = self.assignedTagsTableView.frame;
    
    // Le devuelve la posicion a la tabla
    self.assignedTagsTableView.frame = CGRectMake(0, 0, tblFrame.size.width, tblFrame.size.height);
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setContext:(NSManagedObjectContext *)moContext assignedTags:(NSSet *)assignedTags availableTags:(NSMutableSet *)availableTags {
    
    self.moContext = moContext;
    // @TODO: hay que ordenarlos
    self.assignedTags = [NSMutableArray arrayWithArray:[assignedTags allObjects]];
    self.availableTags = availableTags;
}






//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.activeSection = ActiveSectionAssigned;
        self.isEditingTagName = FALSE;
    }
    return self;
}


//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txtNewTagName.placeholder = [NSString stringWithFormat:@"Tag path names separated by '%@'",TAG_NAME_SEPARATOR];
    self.kbContentView = self.assignedTagsTableView;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Ajusta el color dependiendo del tinte
    self.lblSelector.backgroundColor = self.view.tintColor;

    
    //****************************************************************************************************
    if(!self.moContext) {
        self.moContext = [BaseCoreDataService moContext];
        NSArray *pointsByName = [MPoint allWithName:@"Iglesia de San Pedro" sortOrder:@[MBaseOrderByNameAsc] inContext:self.moContext];
        MPoint *point = pointsByName[0];
        
        //@TODO Hay que ordenarlo
        self.assignedTags = [NSMutableArray arrayWithArray:[point.directNoAutoTags allObjects]];
        for(int n=0;n<20;n++) {
            [self.assignedTags addObject:[MTag tagWithFullName:[NSString stringWithFormat:@"un-tag-%d",n] inContext:self.moContext]];
        }
        //@TODO Hay que quitar los tags que sean automaticos
        NSArray *allPoints = [MPoint allWithMap:point.map sortOrder:@[MBaseOrderNone]];
        self.availableTags = [NSMutableSet set];
        for(MTag *tag in [MPoint allTagsFromPoints:allPoints]) {
            if(!tag.isAutoTagValue) [self.availableTags addObject:tag];
        }
    }
    //****************************************************************************************************
    
    // Establece los tags, una vez filtrados los asignados, a la tabla de seleccion de disponibles
    [self.tagTableView setTagList:[self _filteredAvailableTags] selectedTags:nil expandedTags:nil];
    
    // El estilo de los asignado es de edicion
    self.assignedTagsTableView.editing = TRUE;
    
    // La seccion activa es la de asignados
    self.activeSection = ActiveSectionAssigned;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"TagListEditor_to_TagTreeTable"])
    {
        // Get reference to the destination view controller
        self.tagTableView = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        self.tagTableView.delegate = self;
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------
- (IBAction)assignedButtonAction:(UIBarButtonItem *)sender {
    
    self.activeSection = ActiveSectionAssigned;
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)availableButtonAction:(UIBarButtonItem *)sender {
    
    self.activeSection = ActiveSectionAvailable;
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)doneButtonAction:(UIBarButtonItem *)sender {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(tagListEditor:assignedTags:)]) {
        [self.delegate tagListEditor:self assignedTags:self.assignedTags];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.moContext = nil;
        self.assignedTags = nil;
        self.availableTags = nil;
    }];

}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)addButtonAction:(UIBarButtonItem *)sender {
    
    [self _startTagNameEditing];
}

//---------------------------------------------------------------------------------------------------------------------
- (IBAction)newTagNameChangedAction:(UITextField *)textField {
    
    NSArray *tags = [MTag allWithNameLike:textField.text sortOrder:@[MBaseOrderByNameAsc] maxNumItems:21 inContext:self.moContext];
    self.searchedTags = tags;
    [self.assignedTagsTableView reloadData];
}


//=====================================================================================================================
#pragma mark -
#pragma mark <UITextFieldDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {

    [self _restoreAssignedTable];
    return TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    // Busca, o crea, el tag con el nombre especificado y lo añade
    MTag *newTag = [MTag tagWithFullName:textField.text inContext:self.moContext];
    [self _assignNewAddedTag:newTag];
    [self.view endEditing:TRUE];
    return TRUE;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <TagTreeTableViewControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void)tagTreeTable:(TagTreeTableViewController *)sender tappedTagTreeNode:(TagTreeNode *)tappedNode {

    MTag *selectedTag = tappedNode.tag;

    // Añade el nuevo tag a la lista de asignados
    // @TODO: Falata ordenarlos
    [self.assignedTags addObject:selectedTag];
    [self.assignedTagsTableView reloadData];
    
    // refresca el contenido del arbol de disponibles al haber ahora un nuevo tag (y sus familiares)
    [self.tagTableView deleteBranchForTag:selectedTag];
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.isEditingTagName) {
        
        MTag *tag = [self.searchedTags objectAtIndex:[indexPath indexAtPosition:1]];
        
        // Para la edicion añadiendo el nuevo tag
        [self _assignNewAddedTag:tag];
        [self _restoreAssignedTable];
        [self.view endEditing:TRUE];
    }
    
    // No dejamos nada seleccionado
    return nil;
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.isEditingTagName ? self.searchedTags.count : self.assignedTags.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Elimina el tag de la lista de asignados y de la tabla
    [self.assignedTags removeObjectAtIndex:[indexPath indexAtPosition:1]];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // refresca el contenido del arbol de disponibles al haber ahora un nuevo tag (y sus familiares)
    [self.tagTableView setTagList:[self _filteredAvailableTags] selectedTags:nil expandedTags:nil];
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myTableViewCellID1";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    MTag *tag;

    if(self.isEditingTagName) {
        tag = (MTag *)[self.searchedTags objectAtIndex:[indexPath indexAtPosition:1]];
    } else {
        tag = (MTag *)[self.assignedTags objectAtIndex:[indexPath indexAtPosition:1]];
    }
    
    cell.textLabel.text = tag.shortName;
    cell.detailTextLabel.text = tag.parent.name;

    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setActiveSection:(ActiveSection) section {
    
    static CGFloat OFFSET_X1 = 36;
    static CGFloat OFFSET_X2 = 205;
    static CGFloat SCREEN_WIDTH = 320;
    
    // Solo hay que hacer algo en caso de cambio
    if(self.activeSection == section) return;
    
    // Almacena el nuevo valor
    _activeSection = section;

    // Mueve los elementos segun la seccion indicada
    if(self.activeSection == ActiveSectionAssigned) {
        
        [UIView animateWithDuration:0.3 animations:^{
            frameSetX(self.lblSelector, OFFSET_X1);
            frameSetX(self.viewContainer, 0);
        } completion:^(BOOL finished) {
            frameSetX(self.lblSelector, OFFSET_X1);
            frameSetX(self.viewContainer, 0);
        }];
        
    } else {
        
        [UIView animateWithDuration:0.3 animations:^{
            frameSetX(self.lblSelector, OFFSET_X2);
            frameSetX(self.viewContainer,-SCREEN_WIDTH);
        } completion:^(BOOL finished) {
            frameSetX(self.lblSelector, OFFSET_X2);
            frameSetX(self.viewContainer,-SCREEN_WIDTH);
        }];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSMutableSet *) _filteredAvailableTags {
    
    NSMutableSet *filteredTags = [NSMutableSet set];
    for(MTag *tag in self.availableTags) {
        if(![self.assignedTags containsObject:tag] && ![tag isRelativeOfAnyTag:self.assignedTags]) {
            [filteredTags addObject:tag];
        }
    }
    return filteredTags;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _startTagNameEditing {
    
    if(self.isEditingTagName) return;

    self.activeSection = ActiveSectionAssigned;
    
    [self.txtNewTagName becomeFirstResponder];
    
    self.txtNewTagName.text = nil;
    self.isEditingTagName = TRUE;
    self.assignedTagsTableView.editing = FALSE;
    [self.assignedTagsTableView reloadData];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _restoreAssignedTable {
    
    self.searchedTags = nil;
    self.isEditingTagName = FALSE;
    self.assignedTagsTableView.editing = TRUE;
    [self.assignedTagsTableView reloadData];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _assignNewAddedTag:(MTag *)newTag {
    
    if(newTag) {
        // Se añade el tag especificado a los asignados (si no existe ya)
        if(![self.assignedTags containsObject:newTag]) {

            //@TODO: Hay que ordenarlos
            [self.assignedTags addObject:newTag];
            
            // Añade el tag localizado, y sus padres, a la lista de disponibles
            while(newTag!=nil) {
                [self.availableTags addObject:newTag];
                newTag = newTag.parent;
            }
            
            // Refresca el contenido de la tabla de tags disponibles
            [self.tagTableView setTagList:[self _filteredAvailableTags] selectedTags:nil expandedTags:nil];
        }
    }
}


@end
