//
//  TagFilterViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TagFilterViewController__IMPL__
#import "TagFilterViewController.h"
#import "TagTreeTableViewController.h"
#import "MComplexFilter.h"
#import "MTag.h"
#import "MPoint.h"
#import "MMap.h"
#import "MIcon.h"
#import "BenchMark.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TagFilterViewController () <TagTreeTableViewControllerDelegate>

@property (strong, nonatomic)   TagTreeTableViewController  *tagTableView;
@property (strong, nonatomic)   MComplexFilter              *filter;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TagFilterViewController



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
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
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Crea un filtro vacio y sin contexto (no se puede ejecutar)
    self.filter = [MComplexFilter filter];
    
    
    // Se establece como el delegate del TagTreeTableViewController hijo
    for(UIViewController *childController in self.childViewControllers) {
        if([childController isKindOfClass:[TagTreeTableViewController class]]) {
            self.tagTableView = (TagTreeTableViewController *)childController;
            self.tagTableView.delegate = self;
        }
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.tagTableView setTagList:self.filter.tagList selectedTags:self.filter.filterTags expandedTags:nil];
}


//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark <TagTreeTableViewControllerDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (void)tagTreeTable:(TagTreeTableViewController *)sender tappedTagTreeNode:(TagTreeNode *)tappedNode {
    
    // Cambiar la seleccion depende de si es el nodo mas profundo seleccionado
    TagTreeNode *selChild = tappedNode.selectedChild;
    if(selChild) {
        selChild.isSelected = FALSE;
    } else {
        [tappedNode toggleSelected];
    }
    
    // Establece el nuevo nivel de filtro
    self.filter.filterTags = [tappedNode.tree allDeepestSelectedChildrenTags];
    NSSet *expandedTags = tappedNode.tag?[NSSet setWithObject:tappedNode.tag]:[NSSet set];
    [self.tagTableView setTagList:self.filter.tagList selectedTags:self.filter.filterTags expandedTags:expandedTags];
    
    // Avisa al delegate del cambio en el filtro
    if(self.delegate && [self.delegate respondsToSelector:@selector(filterHasChanged:filter:)]) {
        [self.delegate filterHasChanged:self filter:self.filter];
    }

}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------


@end
