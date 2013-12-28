//
//  TagFilterViewController.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TagFilterViewController__IMPL__
#import "TagFilterViewController.h"
#import "BaseCoreDataService.h"
#import "MTag.h"
#import "MIcon.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
typedef enum NodeExpandedStateTypes
{
    ALL_NODES,
    JUST_EXPANDED
} NodeExpandedState;

@interface TreeNode : NSObject

@property (nonatomic, assign) TreeNode *parent;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, assign) MTag *tag;
@property (nonatomic, assign) BOOL isExpanded;

@end

@implementation TreeNode

@synthesize isExpanded = _isExpanded;

+ (TreeNode *) treeNodeWithTag:(MTag *)tag {
    TreeNode *me = [[TreeNode alloc] init];
    me.parent = nil;
    me.children = [NSMutableArray array];
    me.tag = tag;
    me.isExpanded = FALSE;
    return me;
}

+ (TreeNode *) _nodeForTag:(MTag *)tag inDict:(NSMutableDictionary *)dict rootNode:(TreeNode *)root {
    
    TreeNode *node = [dict objectForKey:[tag objectID]];
    if(!node) {
        NSLog(@"--- creating node for tag: %@", tag.name);
        node = [TreeNode treeNodeWithTag:tag];
        [dict setObject:node forKey:[tag objectID]];
        [root.children addObject:node];
        node.parent = root;
    }
    return node;
}

+ (TreeNode *) treeNodesFromTags:(NSArray *)tags expandedTags:(NSArray *)expandedTags {
    
    NSMutableDictionary *tagToNode = [NSMutableDictionary dictionary];
    TreeNode *rootNode = [TreeNode treeNodeWithTag:nil];
    
    for(MTag *childTag in tags) {
        TreeNode *childNode = [TreeNode _nodeForTag:childTag inDict:tagToNode rootNode:rootNode];
        for(MTag *parentTag in tags) {
            TreeNode *parentNode = [TreeNode _nodeForTag:parentTag inDict:tagToNode rootNode:rootNode];
            if([parentTag isDirectParentOfTag:childTag]) {
                childNode.parent = parentNode;
                [parentNode.children addObject:childNode];
                [rootNode.children removeObject:childNode];
            }
        }
    }

    NSArray *allNodes = [rootNode toFlatArray:ALL_NODES];
    for(TreeNode *node in allNodes) {
        NSLog(@"tag - %@",node.tag.name);
        if([expandedTags containsObject:node.tag]) {
            node.parent.isExpanded = TRUE;
        }
    }
    rootNode.isExpanded = TRUE;
    return rootNode;
}

- (void) setIsExpanded:(BOOL)isExpanded {
    _isExpanded = isExpanded;
    if(isExpanded) self.parent.isExpanded = TRUE;
}

- (void) toggleExpanded {
    self.isExpanded = !self.isExpanded;
}

- (NSString *) description {

    return [self displayTreeNode:@""];
}

- (NSString *) displayTreeNode:(NSString *)padding {

    NSMutableString *str =  [NSMutableString stringWithFormat:@"%@%@%@\n",(self.isExpanded?@"+":@" "), padding, self.tag.name];
    for(TreeNode *child in self.children) {
        [str appendString:[child displayTreeNode:[NSString stringWithFormat:@"%@%@",padding,@"  "]]];
    }
    return str;
}

- (NSArray *) toFlatArray:(NodeExpandedState)expandedState {
    
    NSMutableArray *flatNodes = [NSMutableArray array];
    
    if(expandedState==ALL_NODES || (expandedState==JUST_EXPANDED && self.isExpanded)) {
        for(TreeNode *childNode in self.children) {
            [flatNodes addObject:childNode];
            if(expandedState==ALL_NODES || (expandedState==JUST_EXPANDED && self.isExpanded)) {
                [flatNodes addObjectsFromArray:[childNode toFlatArray:expandedState]];
            }
        }
    }
    return flatNodes;
}

@end


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TagFilterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) IBOutlet UITableView *tagsTable;

@property (nonatomic, strong) TreeNode *rootNode;
@property (nonatomic, strong) NSArray *flatNodes;

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
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    if(self.moContext==nil) {
        self.moContext = BaseCoreDataService.moContext;
    }
    self.filter = [NSMutableArray array];
    /*
    self.tagList = [MTag tagsForPointsTaggedWith:self.filter InContext:self.moContext];
     */
    

    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {
    [self _loadTags];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) _loadTags {
    
    NSMutableArray *allTags = [NSMutableArray arrayWithArray:[MTag tagsForPointsTaggedWith:[NSSet setWithArray:self.filter] InContext:self.moContext]];
    self.rootNode = [TreeNode treeNodesFromTags:allTags expandedTags:self.filter];
    self.flatNodes = [self.rootNode toFlatArray:JUST_EXPANDED];
    [self.tagsTable reloadData];
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"pepe");
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
- (void) _rotateView:(UIView *)view {
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotate.duration = 0.5f;
    rotate.repeatCount = 1;
    [view.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [view.layer addAnimation:rotate forKey:@"trans_rotation" ];
}

//---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    TreeNode *nodeSelected = (TreeNode *)[self.flatNodes objectAtIndex:[indexPath indexAtPosition:1]];
    [nodeSelected toggleExpanded];

    
    NSArray *newFlatNodes = [self.rootNode toFlatArray:JUST_EXPANDED];
    int diff = newFlatNodes.count-self.flatNodes.count;
    BOOL insertRows = diff>0;
    diff = diff>=0?diff:-diff;
    
    NSMutableArray *indexes = [NSMutableArray array];
    for(int n=1;n<=diff;n++) {
        [indexes addObject:[NSIndexPath indexPathForItem:indexPath.row+n inSection:indexPath.section]];
    }
    
    self.flatNodes = newFlatNodes;
    
    if(insertRows) {
        [tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImage __block *image = (nodeSelected.isExpanded) ? [UIImage imageNamed:@"unfolded.png"] : [UIImage imageNamed:@"folded.png"];
    UIButton __block *button = (UIButton *)cell.accessoryView;
    
    [UIView animateWithDuration:0.3 animations:^{
        button.transform = CGAffineTransformMakeRotation((nodeSelected.isExpanded?1:-1)*M_PI/2);
    } completion:^(BOOL finished) {
        button.transform = CGAffineTransformIdentity;
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }];
    
}

//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    TreeNode *nodeSelected = (TreeNode *)[self.flatNodes objectAtIndex:[indexPath indexAtPosition:1]];
    MTag *itemSelected = nodeSelected.tag;
    if([self.filter containsObject:itemSelected]) {
        [self.filter removeObject:itemSelected];
    } else {
        [self.filter addObject:itemSelected];
    }
    [self _loadTags];
    
    // No dejamos nada seleccionado
    //    return indexPath;
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
- (void) _setDetailDisclosureButtonForCell:(UITableViewCell *)cell expanded:(BOOL)expanded {

    UIImage *image = (expanded) ? [UIImage imageNamed:@"unfolded.png"] : [UIImage imageNamed:@"folded.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(_checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
}


//---------------------------------------------------------------------------------------------------------------------
- (void) _checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tagsTable];
    NSIndexPath *indexPath = [self.tagsTable indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil)
    {
        [self tableView: self.tagsTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myTableCell2";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    
    TreeNode *nodeToShow = (TreeNode *)[self.flatNodes objectAtIndex:[indexPath indexAtPosition:1]];
    MTag *itemToShow = nodeToShow.tag;
    
    if(itemToShow.shortName) {
        cell.textLabel.text = itemToShow.shortName;
    } else {
        cell.textLabel.text = itemToShow.name;
    }
    if([self.filter containsObject:itemToShow]) {
        cell.textLabel.textColor = [UIColor blueColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    if(nodeToShow.children.count==0) {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    } else {
        //cell.accessoryType = UITableViewCellAccessoryDetailButton;
        [self _setDetailDisclosureButtonForCell:cell expanded:nodeToShow.isExpanded];
    }
    
    cell.imageView.image = itemToShow.icon.image;

    
    /*
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    
    MBaseEntity *itemToShow = (MBaseEntity *)[self.itemLists objectAtIndex:[indexPath indexAtPosition:1]];
    
    cell.textLabel.text=itemToShow.name;
    cell.imageView.image = itemToShow.entityImage;
    
    if(itemToShow.entityType == MET_POINT) {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text=@" ";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.badgeString=nil;
    } else {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.detailTextLabel.text=@"";
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        if (itemToShow.entityType == MET_MAP) {
            cell.badgeString=[(MMap*)itemToShow strViewCount];
        } else {
            cell.badgeString=[(MCategory*)itemToShow strViewCountForMap:self.selectedMap];
        }
    }
    
    if(tableView.isEditing) {
        [self _setLeftCheckStatusFor:itemToShow cell:cell];
    }
    */
    return cell;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------


@end
