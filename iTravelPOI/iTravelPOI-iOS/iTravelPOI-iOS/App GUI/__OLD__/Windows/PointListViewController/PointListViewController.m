//
//  PointListViewController.m
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointListViewController__IMPL__
#import "PointListViewController.h"
#import "PointListViewCell.h"
#import "MPoint.h"
#import "MIcon.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointListViewController () <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView        *pointsTable;


@property (strong, nonatomic) UIView                    *tableAccesoryView;

@property (strong, nonatomic) NSIndexPath               *prevSelIndexPath;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation PointListViewController


@synthesize delegate = _delegate;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) pointsHaveChanged {

    // Elimina la seleccion anterior
    self.prevSelIndexPath = nil;
    
    // Recarga la informacion
    [self.pointsTable reloadData];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) startMultiplePointSelection {
    [self.pointsTable setEditing:TRUE animated:TRUE];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) doneMultiplePointSelection {
    [self.pointsTable setEditing:FALSE animated:TRUE];
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib
    self.tableAccesoryView = [self createTableAccesoryView];

    // Empieza sin celdas seleccionadas
    self.prevSelIndexPath = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {

    
    [super viewWillAppear:animated];
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
- (void)cellBtnOpenInAction:(UIButton *)sender {
    
    if(self.prevSelIndexPath) {
        MPoint *selectedPoint = (MPoint *)[self.delegate.pointList objectAtIndex:[self.prevSelIndexPath indexAtPosition:1]];
        [self.delegate openInExternalApp:selectedPoint];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)cellBtnEditAction:(UIButton *)sender {
    
    if(self.prevSelIndexPath) {
        MPoint *selectedPoint = (MPoint *)[self.delegate.pointList objectAtIndex:[self.prevSelIndexPath indexAtPosition:1]];
        [self.delegate editPoint:selectedPoint];
    }
}



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

    if(tableView.isEditing || ![indexPath isEqual:self.prevSelIndexPath]) {
        return 76;//76;
    } else {
        return 102;//112;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if(tableView.isEditing) {
        
        MPoint *itemToShow = (MPoint *)[self.delegate.pointList objectAtIndex:[indexPath indexAtPosition:1]];
        if([self.delegate.selectedPoints containsObject:itemToShow.objectID]) {
            [self.delegate.selectedPoints removeObject:itemToShow.objectID];
        } else {
            [self.delegate.selectedPoints addObject:itemToShow.objectID];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else {
        
        [tableView beginUpdates];
        
        BOOL equals = [indexPath compare:self.prevSelIndexPath]==NSOrderedSame;
        
        if(!self.prevSelIndexPath || equals) {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [tableView reloadRowsAtIndexPaths:@[indexPath,self.prevSelIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        self.prevSelIndexPath = equals ? nil : indexPath;
        
        [tableView endUpdates];
    }

    return nil;
    
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.delegate.pointList.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";

    PointListViewCell *cell = (PointListViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[PointListViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    MPoint *itemToShow = (MPoint *)[self.delegate.pointList objectAtIndex:[indexPath indexAtPosition:1]];
    
    cell.textLabel.text = itemToShow.name;
    cell.detailTextLabel.text = @"kkvaca";
    cell.imageView.image = itemToShow.icon.image;

    if(tableView.isEditing) {

        cell.checked = [self.delegate.selectedPoints containsObject:itemToShow.objectID];

    } else {
        
        if([indexPath isEqual:self.prevSelIndexPath]) {
            cell.accessoryView = self.createTableAccesoryView;
        } else {
            cell.accessoryView = nil;
        }
        
    }
    
    return cell;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (UIView *) createTableAccesoryView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 42, 90)];
    
    UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeInfoLight];
    btnEdit.frame = CGRectMake(0, 0, 42, 42);
    btnEdit.imageView.contentMode = UIViewContentModeCenter;
    [btnEdit addTarget:self action:@selector(cellBtnEditAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnEdit];
    
    UIButton *btnOpenIn = [UIButton buttonWithType:UIButtonTypeSystem];
    btnOpenIn.frame = CGRectMake(0, 48, 42, 42);
    [btnOpenIn setImage:[UIImage imageNamed:@"actions-share"] forState:UIControlStateNormal];
    btnOpenIn.imageView.contentMode = UIViewContentModeCenter;
    [btnOpenIn addTarget:self action:@selector(cellBtnOpenInAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnOpenIn];
    
    return view;
}


@end
