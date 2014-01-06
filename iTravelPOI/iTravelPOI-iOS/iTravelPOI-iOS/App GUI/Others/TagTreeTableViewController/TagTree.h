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


@property (nonatomic, strong, readonly) NSArray *children;



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

@property (nonatomic, weak, readonly)   TagTree *tree;
@property (nonatomic, weak, readonly)   TagTreeNode *parent;
@property (nonatomic, strong, readonly) NSArray *children;
@property (nonatomic, assign, readonly) int deepLevel;
@property (nonatomic, assign, readonly) int treeIndex;
@property (nonatomic, assign)           BOOL isExpanded;
@property (nonatomic, assign)           BOOL isSelected;


@property (nonatomic, strong) MTag *tag;




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





