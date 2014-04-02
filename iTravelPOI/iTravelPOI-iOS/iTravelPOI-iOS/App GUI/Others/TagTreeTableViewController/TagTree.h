//
//  TagTreeNode.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//


@class MTag;
@class TagTree;
@class TagTreeNode;


//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************





//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface TagTree : NSObject


@property (strong, readonly, nonatomic) NSArray *children;



//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (TagTree *) tagTreeWithTags:(NSSet *)tags
                 expandedTags:(NSSet *)expandedTags
                 selectedTags:(NSSet *)selectedTags;




//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSArray *)flatDescendantArray;
- (NSSet *) allDeepestSelectedChildrenTags;
-(TagTreeNode *) deleteBranchForTag:(MTag *)tag;


@end





//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface TagTreeNode : NSObject

@property (weak, nonatomic, readonly)   TagTree *tree;
@property (weak, nonatomic, readonly)   TagTreeNode *parent;
@property (strong, readonly, nonatomic) NSArray *children;
@property (assign, readonly, nonatomic) int deepLevel;
@property (assign, readonly, nonatomic) int treeIndex;
@property (assign, nonatomic)           BOOL isExpanded;
@property (assign, nonatomic)           BOOL isSelected;


@property (strong, nonatomic) MTag *tag;




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
+ (TagTreeNode *) tagTreeNodeWithTag:(MTag *)tag inTree:(TagTree *)tree;




//=====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) toggleExpanded;
- (void) toggleSelected;
- (TagTreeNode *) selectedChild;
- (NSArray *)flatDescendantArray;


@end





