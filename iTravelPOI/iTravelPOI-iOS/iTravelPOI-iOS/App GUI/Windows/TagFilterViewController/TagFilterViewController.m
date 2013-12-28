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
#import "RPointTag.h"
#import "MPoint.h"
#import "MyTableViewCell.h"



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
@property (nonatomic, assign) int deepLevel;
@property (nonatomic, assign) int childLevel;

@end

@implementation TreeNode

@synthesize isExpanded = _isExpanded;

+ (TreeNode *) treeNodeWithTag:(MTag *)tag {
    TreeNode *me = [[TreeNode alloc] init];
    me.parent = nil;
    me.children = [NSMutableArray array];
    me.tag = tag;
    me.isExpanded = FALSE;
    me.deepLevel = 0;
    me.childLevel = 0;
    return me;
}

+ (TreeNode *) _nodeForTag:(MTag *)tag inDict:(NSMutableDictionary *)dict rootNode:(TreeNode *)root {
    
    TreeNode *node = [dict objectForKey:[tag objectID]];
    if(!node) {
        node = [TreeNode treeNodeWithTag:tag];
        [dict setObject:node forKey:[tag objectID]];
        [root _addChild:node];
    }
    return node;
}

+ (TreeNode *) treeNodesFromTags:(NSArray *)tags expandedTags:(NSArray *)expandedTags {
    
    NSMutableDictionary *tagToNode = [NSMutableDictionary dictionary];
    TreeNode *rootNode = [TreeNode treeNodeWithTag:nil];
    rootNode.deepLevel = -1;
    
    for(MTag *childTag in tags) {
        TreeNode *childNode = [TreeNode _nodeForTag:childTag inDict:tagToNode rootNode:rootNode];
        for(MTag *parentTag in tags) {
            TreeNode *parentNode = [TreeNode _nodeForTag:parentTag inDict:tagToNode rootNode:rootNode];
            if([parentTag isDirectParentOfTag:childTag]) {
                [parentNode _addChild:childNode];
            }
        }
    }

    NSArray *allNodes = [rootNode toFlatArray:ALL_NODES];
    for(TreeNode *node in allNodes) {
        if([expandedTags containsObject:node.tag]) {
            node.parent.isExpanded = TRUE;
        }
    }
    
    [rootNode _calcChildLevel:-1];
    
    NSLog(@"tree - %@",rootNode);
    rootNode.isExpanded = TRUE;
    return rootNode;
}

- (void) _calcChildLevel:(int)startLevel {
    self.childLevel = startLevel;
    for(TreeNode *child in self.children) {
        [child _calcChildLevel:++startLevel];
    }
}

- (void) setIsExpanded:(BOOL)isExpanded {
    _isExpanded = isExpanded;
    if(isExpanded) self.parent.isExpanded = TRUE;
}

- (void) toggleExpanded {
    self.isExpanded = !self.isExpanded;
}

- (void) _setDeepLevel:(int)level {
    self.deepLevel = level;
    for(TreeNode *child in self.children) {
        [child _setDeepLevel:level+1];
    }
}

- (void) _addChild:(TreeNode *)child {

    if(child.parent) {
        [child.parent.children removeObject:child];
    }
    
    [self.children addObject:child];
    child.parent = self;
    [child _setDeepLevel:self.deepLevel + 1];
    
    NSLog(@"parent = %@ (%d)(%d) / child = %@ (%d)(%d)",self.tag.name,self.deepLevel, self.childLevel, child.tag.name, child.deepLevel, child.childLevel);
}

- (NSString *) description {

    
    NSString *padding = self.deepLevel<0?@"":[[NSString string] stringByPaddingToLength:4*self.deepLevel withString:@" " startingAtIndex:0];
    NSMutableString *str =  [NSMutableString stringWithFormat:@"%@%@%@ (%d)(%d)\n",(self.isExpanded?@"+":@" "), padding, self.tag.name, self.deepLevel, self.childLevel];
    for(TreeNode *child in self.children) {
        [str appendString:[child description]];
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
- (UIImage *)image:(UIImage *)img withBurnTint:(UIColor *)color
{
    // lets tint the icon - assumes your icons are black
    UIGraphicsBeginImageContextWithOptions(img.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
    
}

//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) _tagImageForIndex:(NSUInteger)index deepLevel:(int)deepLevel {
    switch (index%6) {
        case 0:
            if(deepLevel==0)
                return [self image:[UIImage imageNamed:@"LBlackTag-1.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.000 blue:0.500 alpha:1.0]];
            else if(deepLevel==1)
                return [self image:[UIImage imageNamed:@"LBlackTag-2.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.500 blue:0.000 alpha:1.0]];
            else
                return [self image:[UIImage imageNamed:@"LBlackTag-3.png"] withBurnTint:[UIColor colorWithRed:0.500 green:0.000 blue:0.000 alpha:1.0]];
        case 1:
            if(deepLevel==0)
                return [self image:[UIImage imageNamed:@"LBlackTag-1.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.000 blue:0.583 alpha:1.0]];
            else if(deepLevel==1)
                return [self image:[UIImage imageNamed:@"LBlackTag-2.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.583 blue:0.000 alpha:1.0]];
            else
                return [self image:[UIImage imageNamed:@"LBlackTag-3.png"] withBurnTint:[UIColor colorWithRed:0.583 green:0.000 blue:0.000 alpha:1.0]];
        case 2:
            if(deepLevel==0)
                return [self image:[UIImage imageNamed:@"LBlackTag-1.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.000 blue:0.667 alpha:1.0]];
            else if(deepLevel==1)
                return [self image:[UIImage imageNamed:@"LBlackTag-2.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.667 blue:0.000 alpha:1.0]];
            else
                return [self image:[UIImage imageNamed:@"LBlackTag-3.png"] withBurnTint:[UIColor colorWithRed:0.667 green:0.000 blue:0.000 alpha:1.0]];
        case 3:
            if(deepLevel==0)
                return [self image:[UIImage imageNamed:@"LBlackTag-1.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.000 blue:0.750 alpha:1.0]];
            else if(deepLevel==1)
                return [self image:[UIImage imageNamed:@"LBlackTag-2.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.750 blue:0.000 alpha:1.0]];
            else
                return [self image:[UIImage imageNamed:@"LBlackTag-3.png"] withBurnTint:[UIColor colorWithRed:0.750 green:0.000 blue:0.000 alpha:1.0]];
        case 4:
            if(deepLevel==0)
                return [self image:[UIImage imageNamed:@"LBlackTag-1.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.000 blue:0.833 alpha:1.0]];
            else if(deepLevel==1)
                return [self image:[UIImage imageNamed:@"LBlackTag-2.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.833 blue:0.000 alpha:1.0]];
            else
                return [self image:[UIImage imageNamed:@"LBlackTag-3.png"] withBurnTint:[UIColor colorWithRed:0.833 green:0.000 blue:0.000 alpha:1.0]];
        case 5:
            if(deepLevel==0)
                return [self image:[UIImage imageNamed:@"LBlackTag-1.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.000 blue:0.917 alpha:1.0]];
            else if(deepLevel==1)
                return [self image:[UIImage imageNamed:@"LBlackTag-2.png"] withBurnTint:[UIColor colorWithRed:0.000 green:0.917 blue:0.000 alpha:1.0]];
            else
                return [self image:[UIImage imageNamed:@"LBlackTag-3.png"] withBurnTint:[UIColor colorWithRed:0.917 green:0.000 blue:0.000 alpha:1.0]];
    }
    return nil;}

//---------------------------------------------------------------------------------------------------------------------
- (UIImage *) _old_tagImageForIndex:(NSUInteger)index deepLevel:(int)deepLevel {
    switch (index%6) {
        case 0:
            if(deepLevel==0)
                return [self image:[UIImage imageNamed:@"BlackTag-1.png"] withBurnTint:[UIColor redColor]];
            //return [UIImage imageNamed:@"OrangeTag-11.png"];
            else if(deepLevel==1)
                return [UIImage imageNamed:@"OrangeTag-2.png"];
            else
                return [UIImage imageNamed:@"OrangeTag-3.png"];
        case 1:
            if(deepLevel==0)
                return [UIImage imageNamed:@"GreenTag-11.png"];
            else if(deepLevel==1)
                return [UIImage imageNamed:@"GreenTag-2.png"];
            else
                return [UIImage imageNamed:@"GreenTag-3.png"];
        case 2:
            if(deepLevel==0)
                return [UIImage imageNamed:@"BlueTag-1.png"];
            else if(deepLevel==1)
                return [UIImage imageNamed:@"BlueTag-2.png"];
            else
                return [UIImage imageNamed:@"BlueTag-3.png"];
        case 3:
            if(deepLevel==0)
                return [UIImage imageNamed:@"DOrangeTag-1.png"];
            else if(deepLevel==1)
                return [UIImage imageNamed:@"DOrangeTag-2.png"];
            else
                return [UIImage imageNamed:@"DOrangeTag-3.png"];
        case 4:
            if(deepLevel==0)
                return [UIImage imageNamed:@"DGreenTag-1.png"];
            else if(deepLevel==1)
                return [UIImage imageNamed:@"DGreenTag-2.png"];
            else
                return [UIImage imageNamed:@"DGreenTag-3.png"];
        case 5:
            if(deepLevel==0)
                return [UIImage imageNamed:@"DBlueTag-1.png"];
            else if(deepLevel==1)
                return [UIImage imageNamed:@"DBlueTag-2.png"];
            else
                return [UIImage imageNamed:@"DBlueTag-3.png"];
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Inhibe que las filas se puedan borrar pasando el dedo
    return UITableViewCellEditingStyleNone;
}

//---------------------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TreeNode *nodeSelected = (TreeNode *)[self.flatNodes objectAtIndex:[indexPath indexAtPosition:1]];
    return 55-nodeSelected.deepLevel*11;
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

    MyTableViewCell *cell = (MyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[MyTableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
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
    
    if(itemToShow.isAutoTagValue) {
        cell.imageView.image = itemToShow.icon.image;
    } else {
        cell.imageView.image = [self _tagImageForIndex:nodeToShow.childLevel deepLevel:nodeToShow.deepLevel];
    }
    //cell.indentationLevel = nodeToShow.deepLevel;
    cell.indentationWidth = 16.0;
    cell.textLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:21.0-5.0*nodeToShow.deepLevel];
    
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
