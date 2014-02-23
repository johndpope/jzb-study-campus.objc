//
//  TagTreeTableViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TagTreeTableViewController__IMPL__
#import "TagTreeTableViewController.h"
#import "TreeTableViewCell.h"
#import "UIImage+Tint.h"
#import "BenchMark.h"
#import "MTag.h"
#import "MIcon.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
// @TODO:   hacer una ordenacion de los tags mejor???
//          Poner los seleccionados los primeros? /separarlos en otra seccion=


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TagTreeTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tagsTable;

@property (strong, nonatomic) TagTree *tagTree;
@property (strong, nonatomic) NSArray *flatNodes;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TagTreeTableViewController


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------


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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib
}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    //@TODO: ¿si estoy embebido en otro que debo responder?
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) setTagList:(NSSet *)tagList selectedTags:(NSSet *)selectedTags expandedTags:(NSSet *)expandedTags {

    BenchMark *benchMark = [BenchMark benchMarkLogging:@"TagTreeTableViewController:setTagList"];
    
    // Crea el arbol de nodos expandiendo los tags indicados y los seleccionados
    self.tagTree = [TagTree tagTreeWithTags:tagList expandedTags:expandedTags selectedTags:selectedTags];
    [benchMark logStepTime:@"Created root tree node from tags"];
    
    // Genera la lista plana de elementos inicial para la tabla
    self.flatNodes = [self.tagTree flatDescendantArray];
    [benchMark logStepTime:@"Created flat tree nodes array"];
    
    // Recarga visualmente la tabla
    [self.tagsTable reloadData];
    
    [benchMark logTotalTime:@"Tags info loaded"];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) clearTagList {
    self.tagTree = nil;
    self.flatNodes = nil;
    [self.tagsTable reloadData];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) deleteBranchForTag:(MTag *)tag {

    
    // Elimina los nodos que sean "parientes" del tag indicado
    TagTreeNode *branchNode = [self.tagTree deleteBranchForTag:tag];
    
    // Calcula los indices de los nodos que habria que quitar visualmente de la tabla
    NSMutableSet *deletedNodes = [NSMutableSet setWithObject:branchNode];
    [deletedNodes addObjectsFromArray:[branchNode flatDescendantArray]];

    NSMutableArray *indexPaths = [NSMutableArray array];
    [self.flatNodes enumerateObjectsUsingBlock:^(TagTreeNode *node, NSUInteger idx, BOOL *stop) {
        if([deletedNodes containsObject:node]) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
        }
    }];
    
    // Actualiza el array de elementos de la tabla despues del borrado
    self.flatNodes = [self.tagTree flatDescendantArray];
    
    // Si se encontro algo que borrar lo ejecuta
    if(indexPaths.count>0) {
        [self.tagsTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    }
    
}


//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Inhibe que las filas se puedan borrar pasando el dedo
    return UITableViewCellEditingStyleNone;
}

//---------------------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static CGFloat rowHeights[] = {70,55,40};
    
    // Ajusta la altura de la fila segun la profundidad
    TagTreeNode *nodeSelected = (TagTreeNode *)[self.flatNodes objectAtIndex:[indexPath indexAtPosition:1]];
    return rowHeights[nodeSelected.deepLevel%3];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TagTreeNode *nodeSelected = (TagTreeNode *)[self.flatNodes objectAtIndex:[indexPath indexAtPosition:1]];

    if(self.delegate && [self.delegate respondsToSelector:@selector(tagTreeTable:tappedTagTreeNode:)]) {
        [self.delegate tagTreeTable:self tappedTagTreeNode:nodeSelected];
    }
    
    // No dejamos nada seleccionado
    return nil;
}


//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.flatNodes.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myTreeTableCell";

    TreeTableViewCell *cell = (TreeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [self _newtableViewCellIntance:myViewCellID];
    }
    
    // consigue la informacion con la que trabajar
    TagTreeNode *nodeToShow = (TagTreeNode *)[self.flatNodes objectAtIndex:[indexPath indexAtPosition:1]];
    MTag *itemToShow = nodeToShow.tag;

    // Estable el texto del nombre del tag
    cell.textLabel.text = itemToShow.shortName ? itemToShow.shortName : itemToShow.name;
    
    // El color del texto depende de si el elemento esta seleccionado
    cell.textLabel.textColor = nodeToShow.isSelected ? [UIColor blueColor] : [UIColor blackColor];

    // La aparicion del icono de expansion depende de si tiene elementos hijos
    if(nodeToShow.children.count>0) {
        ((UIImageView *)cell.accessoryView).image = [self _tableViewCellArrowImageExpanded:nodeToShow.isExpanded];
        ((UIImageView *)cell.accessoryView).hidden = FALSE;
    } else {
        ((UIImageView *)cell.accessoryView).hidden = TRUE;
    }

    // La imagen de la fila depende de si la etiqueta era automatica (viene de otro elemento)
    cell.imageView.image = itemToShow.isAutoTagValue ? itemToShow.icon.image : [self _tagImageForNode:nodeToShow seleted:nodeToShow.isSelected];

    
    cell.indentationLevel = nodeToShow.deepLevel;
    cell.indentationWidth = 0.0;
    //.Helvetica NeueUI
    //.HelveticaNeueInterface-M3
    cell.textLabel.font = [UIFont fontWithName:@".Helvetica NeueUI" size:26.0-5.0*nodeToShow.deepLevel];
    

    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) _tagColors {
    
    // Carga de forma estatica el array de imagenes
    static NSArray *_tagColors = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        _tagColors = @[
                       [UIColor colorWithIntRed:222 intGreen:113 intBlue:115 alpha:1.0],
                       [UIColor colorWithIntRed:255 intGreen:160 intBlue: 66 alpha:1.0],
                       [UIColor colorWithIntRed:232 intGreen:212 intBlue: 78 alpha:1.0],
                       [UIColor colorWithIntRed:161 intGreen:207 intBlue: 81 alpha:1.0],
                       [UIColor colorWithIntRed:111 intGreen:167 intBlue:205 alpha:1.0],
                       [UIColor colorWithIntRed:223 intGreen:121 intBlue:247 alpha:1.0],
                       [UIColor colorWithIntRed:166 intGreen:166 intBlue:166 alpha:1.0]
                       ];
    });
    return _tagColors;
}

//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) _tagImageForNode:(TagTreeNode *)node seleted:(BOOL) selected {
    
    static NSString *normalTagImageName = @"BlackTag";
    static NSString *selectedTagImageName = @"CircledTag";
    
    
    static NSArray *_normalTagImages = nil;
    static NSArray *_selectedTagImages = nil;
    static NSUInteger tCount = 0;
    
    // Carga de forma estatica el array de imagenes
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        
        // Colores
        NSArray *tagColors = [self _tagColors];
        tCount = tagColors.count;
        
        // Etiquetas normales
        NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:3 * tagColors.count];
        for(UIColor *color in tagColors) {
            [imgs addObject:[UIImage imageNamed:normalTagImageName burnTint:color]];
            [imgs addObject:[[UIImage imageNamed:normalTagImageName burnTint:[color incrementBrightness:-0.1]] scaledToSize:(CGSize){27,27} offsetX:5.0 offsetY:2.5 containerW:32 containerH:32]];
            [imgs addObject:[[UIImage imageNamed:normalTagImageName burnTint:[color incrementBrightness:-0.2]] scaledToSize:(CGSize){22,22} offsetX:10.0 offsetY:5.0 containerW:32 containerH:32]];
        }
        _normalTagImages = imgs;
        
        // Etiquetas seleccionadas
        imgs = [NSMutableArray arrayWithCapacity:3 * tagColors.count];
        for(UIColor *color in tagColors) {
            [imgs addObject:[UIImage imageNamed:selectedTagImageName burnTint:[color incrementBrightness:-0.1]]];
            [imgs addObject:[[UIImage imageNamed:selectedTagImageName burnTint:[color incrementBrightness:-0.3]] scaledToSize:(CGSize){27,27} offsetX:5.0 offsetY:2.5 containerW:32 containerH:32]];
            [imgs addObject:[[UIImage imageNamed:selectedTagImageName burnTint:[color incrementBrightness:-0.4]] scaledToSize:(CGSize){22,22} offsetX:10.0 offsetY:5.0 containerW:32 containerH:32]];
        }
        _selectedTagImages = imgs;
    });
    
    
    NSUInteger index = 3 * (node.treeIndex % tCount) + (node.deepLevel<3?node.deepLevel:2);
    return selected?_selectedTagImages[index]:_normalTagImages[index];
}

//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) _tableViewCellArrowImageExpanded:(BOOL)isExpanded {
    
    // Carga de forma estatica las imagenes
    static UIImage *_imageFolded = nil;
    static UIImage *_imageExpanded = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        _imageFolded = [UIImage imageNamed:@"folded" burnTint:self.view.tintColor];
        _imageExpanded = [UIImage imageNamed:@"expanded" burnTint:self.view.tintColor];
    });

    return  isExpanded?_imageExpanded : _imageFolded;
}

//---------------------------------------------------------------------------------------------------------------------
- (TreeTableViewCell *) _newtableViewCellIntance:(NSString *)reuseIdentifier {
    
    TreeTableViewCell *cell = [[TreeTableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:(CGRect){0,0,24,24}];
    iv.image = [self _tableViewCellArrowImageExpanded:FALSE];
    iv.contentMode = UIViewContentModeCenter;
    iv.hidden = TRUE;
    iv.userInteractionEnabled = TRUE;

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tableViewCellArrowTapped:)];
    singleTap.numberOfTapsRequired = 1;
    [iv addGestureRecognizer:singleTap];

    cell.accessoryView = iv;
    
    return cell;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _tableViewCellArrowTapped:(UITapGestureRecognizer *)sender {
    
    CGPoint currentTouchPosition = [sender locationInView:self.tagsTable];
    NSIndexPath *indexPath = [self.tagsTable indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath == nil) return;
    
    // Cambia el estado de expansion del nodo
    TagTreeNode *nodeSelected = (TagTreeNode *)[self.flatNodes objectAtIndex:[indexPath indexAtPosition:1]];
    [nodeSelected toggleExpanded];
    
    // Consigue los nodos hijos con el nuevo estado y la diferencia con el anterior
    NSArray *newFlatNodes = [self.tagTree flatDescendantArray];
    long diff = newFlatNodes.count-self.flatNodes.count;
    BOOL newRowsInserted = diff>0;
    diff = diff>=0?diff:-diff;
    
    // Calcula los indexPath de los nodos hijos afectados
    NSMutableArray *indexes = [NSMutableArray array];
    for(int n=1;n<=diff;n++) {
        [indexes addObject:[NSIndexPath indexPathForItem:indexPath.row+n inSection:indexPath.section]];
    }
    
    // Establece los nuevos nodos a utilizar en la tabla
    self.flatNodes = newFlatNodes;
    
    // Borra/inserta los nodos afectados
    if(newRowsInserted) {
        [self.tagsTable insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationLeft];
    } else {
        [self.tagsTable deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    // Anima la flecha de seleccion de las filas
    UITableViewCell *cell = [self.tagsTable cellForRowAtIndexPath:indexPath];
    UIImage __block *image = [self _tableViewCellArrowImageExpanded:nodeSelected.isExpanded];
    UIImageView __block *imageView = (UIImageView *)cell.accessoryView;
    [UIView animateWithDuration:0.3 animations:^{
        imageView.transform = CGAffineTransformMakeRotation((nodeSelected.isExpanded?1:-1)*M_PI/2);
    } completion:^(BOOL finished) {
        imageView.transform = CGAffineTransformIdentity;
        imageView.image = image;
    }];
}


@end
