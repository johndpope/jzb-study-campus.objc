//
//  TagTreeNode.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import "TagTree.h"
#import "BenchMark.h"
#import "MTag.h"


//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TagTree()

// Redefine como de escritura
@property (nonatomic, strong) NSMutableArray *wChildren;
@property (nonatomic, strong) NSMutableDictionary *tagToNodeDict;

+ (void) _sortChildren:(NSMutableArray *)children andCalcTreeIndexFrom:(int)index;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TagTreeNode()

// Redefine como de escritura
@property (nonatomic, weak)   TagTree *tree;
@property (nonatomic, strong) NSMutableArray *wChildren;
@property (nonatomic, weak)   TagTreeNode *parent;
@property (nonatomic, assign) int deepLevel;
@property (nonatomic, assign) int treeIndex;


- (void) addChildNode:(TagTreeNode *)childNode;
- (NSArray *)flatDescendantArray;
- (TagTreeNode *) deepestSelectedNode;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TagTree


@synthesize children = _children;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (TagTree *) tagTreeWithTags:(NSSet *)tags
                 expandedTags:(NSSet *)expandedTags
                 selectedTags:(NSSet *)selectedTags
{
    
    BenchMark *benchMark = [BenchMark benchMarkLogging:@"TagTree:tagTreeWithTags"];
    
    // Arbol del que colgara el resto de nodos
    TagTree *tree = [TagTree new];
    tree.wChildren = [NSMutableArray array];
    
    // Diccionario para poder enlazar tags y nodos
    tree.tagToNodeDict = [NSMutableDictionary dictionaryWithCapacity:tags.count];
    
    // Crea un nodo por cada tag indicado y lo almacena en el diccionario
    // Se salta los filtrados y SUS PARIENTES
    for(MTag *tag in tags) {
        TagTreeNode *node = [TagTreeNode tagTreeNodeWithTag:tag inTree:tree];
        [tree.tagToNodeDict setObject:node forKey:tag.objectID];
        node.isExpanded = [expandedTags containsObject:tag];
        node.isSelected = [selectedTags containsObject:tag];
    }
    
    [benchMark logStepTime:@"TreeNodes created an put into dictionary. Creating tree structure"];
    
    
    // Enlaza los nodos creados formando un arbol buscando el padre de cada uno en el diccionario
    for(MTag *tag in tags) {
        TagTreeNode *node = [tree.tagToNodeDict objectForKey:tag.objectID];
        if(tag.parent) {
            TagTreeNode *parentNode = [tree.tagToNodeDict objectForKey:tag.parent.objectID];
            if(parentNode) {
                [parentNode addChildNode:node];
            }
        } else {
            [tree.wChildren addObject:node];
        }
    }
    
    [benchMark logTotalTime:@"Tree structure created"];
    
    // Ordena los nodos y les asigna un indiceLineal
    [TagTree _sortChildren:tree.wChildren andCalcTreeIndexFrom:-1];
    
    [benchMark logTotalTime:@"Tree structure sorted"];
    
    return tree;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {
    
    NSMutableString *str = [NSMutableString stringWithString:@"TagTree:\n"];
    for(TagTreeNode *child in self.children) {
        [str appendString:[child description]];
    }
    return str;
}


//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) children {
    return self.wChildren;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *)flatDescendantArray {
    
    NSMutableArray *flatNodes = [NSMutableArray array];
    
    // Lo hacemos asi para que los "nietos" vayan en orden detras de los "hijos"
    for(TagTreeNode *childNode in self.children) {
        [flatNodes addObject:childNode];
        if(childNode.isExpanded) {
            [flatNodes addObjectsFromArray:[childNode flatDescendantArray]];
        }
    }
    return flatNodes;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSSet *) allDeepestSelectedChildrenTags {
    
    NSMutableSet *selectedChildTags = [NSMutableSet set];
    for(TagTreeNode *childNode in self.children) {
        TagTreeNode *node = [childNode deepestSelectedNode];
        if(node) [selectedChildTags addObject:node.tag];
    }
    
    return selectedChildTags;
}

//---------------------------------------------------------------------------------------------------------------------
-(TagTreeNode *) deleteBranchForTag:(MTag *)tag {
    
    TagTreeNode *branchNode = nil;
    
    // Busca el nodo hijo cuyo tag es un "pariente" del tag indicado
    for(TagTreeNode *child in self.children) {
        if([child.tag.objectID isEqual:tag.objectID] || [child.tag isRelativeOfTag:tag]) {
            branchNode = child;
            break;
        }
    }
    
    // Borra el nodo localizado y renumera de nuevo los nodos
    if(branchNode) {
        [self.wChildren removeObject:branchNode];
        branchNode.parent = nil;
        [TagTree _sortChildren:self.wChildren andCalcTreeIndexFrom:-1];
    }
    
    return branchNode;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
+ (void) _sortChildren:(NSMutableArray *)children andCalcTreeIndexFrom:(int)index {

    // Lo primero es ordenar los nodos
    [children sortUsingComparator:^NSComparisonResult(TagTreeNode *node1, TagTreeNode *node2) {
        
        NSComparisonResult result;
        
        result = [node1.tag.isAutoTag compare:node2.tag.isAutoTag];
        if(result!=NSOrderedSame) return result;
        
        result = [node1.tag.name compare:node2.tag.name];
        return result;
    }];
    
    // Lo segundo es asignarles un indice de forma recursiva
    [children enumerateObjectsUsingBlock:^(TagTreeNode *child, NSUInteger idx, BOOL *stop) {
        child.treeIndex = index + 1 + idx;
        [TagTree _sortChildren:child.wChildren andCalcTreeIndexFrom:child.treeIndex];
    }];
}


@end








//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TagTreeNode

@synthesize children = _children;
@synthesize isExpanded = _isExpanded;
@synthesize isSelected = _isSelected;
@synthesize deepLevel = _deepLevel;




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (TagTreeNode *) tagTreeNodeWithTag:(MTag *)tag inTree:(TagTree *)tree {
    
    TagTreeNode *me = [[TagTreeNode alloc] init];
    me.parent = nil;
    me.wChildren = [NSMutableArray array];
    me.isExpanded = FALSE;
    me.deepLevel = 0;
    me.treeIndex = -1;

    me.tree = tree;
    
    me.tag = tag;
    
    return me;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (NSString *) description {
    
    NSString *padding = self.deepLevel<0?@"":[[NSString string] stringByPaddingToLength:4*self.deepLevel withString:@" " startingAtIndex:0];
    NSMutableString *str =  [NSMutableString stringWithFormat:@"%@%@%@ (deep=%d/index=%d)\n",
                             (self.isExpanded?@"+":@" "), padding, self.tag.name, self.deepLevel, self.treeIndex];
    for(TagTreeNode *child in self.children) {
        [str appendString:[child description]];
    }
    return str;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) children {
    return self.wChildren;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setIsExpanded:(BOOL)isExpanded {
    
    // Solo hace algo en caso de cambio
    if(isExpanded == _isExpanded) return;
    
    // Si se expande un elemento, todos sus ancestros tambien deben ser expandidos
    _isExpanded = isExpanded;
    if(isExpanded) self.parent.isExpanded = TRUE;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setIsSelected:(BOOL)isSelected {
    
    // Solo hace algo en caso de cambio
    if(isSelected == _isSelected) return;
    
    // Si se selecciona un elemento, todos sus ancestros tambien deben ser seleccionados
    // Si se deselecciona, todos sus descendientes deben ser deseleccionados
    // Adicionalmente, implica que se expandiran
    _isSelected = isSelected;
    if(isSelected) {
        self.isExpanded = TRUE;
        self.parent.isSelected = TRUE;
    } else {
        for (TagTreeNode *child in self.children) {
            child.isSelected = FALSE;
        }
    }
    
    // Como es monoseleccion (por rama del arbol) sus hermanos deben ser deseleccionados
    for(TagTreeNode *sibling in self.parent.children) {
        if(sibling!=self) {
            sibling.isSelected = FALSE;
        }
    }

}

//---------------------------------------------------------------------------------------------------------------------
- (void) toggleExpanded {
    self.isExpanded = !self.isExpanded;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) toggleSelected {
    self.isSelected = !self.isSelected;
}

//---------------------------------------------------------------------------------------------------------------------
- (TagTreeNode *) selectedChild {
    
    for(TagTreeNode *child in self.children) {
        if(child.isSelected) return child;
    }
    return nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setDeepLevel:(int)level {
    
    // Cambiar el nivel de profundidad de un nodo implica ajustar el de todos sus hijos
    _deepLevel = level;
    for(TagTreeNode *child in self.children) {
        child.deepLevel = level + 1;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) addChildNode:(TagTreeNode *)childNode {

    // Primero lo elimina del posible nodo padre previo
    [childNode.parent removeChildNode:childNode];
    
    // Lo añade al array de nodos hijos
    [self.wChildren addObject:childNode];
    
    // Le ajusta el nivel de anidamiento
    childNode.parent = self;
    childNode.deepLevel = self.deepLevel + 1;
    
    // Si el nodo añadido esta expandido el padre lo debe estar tambien
    if(childNode.isExpanded) {
        self.isExpanded = TRUE;
    }
    
    // Si el nodo añadido esta seleccionado el padre lo debe estar tambien
    if(childNode.isSelected) {
        self.isSelected = TRUE;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (void) removeChildNode:(TagTreeNode *)childNode {
    
    // Solo elimina el nodo si realmente es hijo suyo
    if(self != childNode.parent) return;
    
    // Desenlaza el nodo nijo
    childNode.parent = nil;
    childNode.treeIndex = -1;
    [self.wChildren removeObject:childNode];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSArray *)flatDescendantArray {
    
    NSMutableArray *flatNodes = [NSMutableArray array];
    
    // Lo hacemos asi para que los "nietos" vayan en orden detras de los "hijos"
    for(TagTreeNode *childNode in self.children) {
        [flatNodes addObject:childNode];
        if(childNode.isExpanded) {
            [flatNodes addObjectsFromArray:[childNode flatDescendantArray]];
        }
    }
    return flatNodes;
}

//---------------------------------------------------------------------------------------------------------------------
- (TagTreeNode *) deepestSelectedNode {
    
    for(TagTreeNode *childNode in self.children) {
        TagTreeNode *node = [childNode deepestSelectedNode];
        if(node) return node;
    }
    
    return  self.isSelected ? self : nil;
}





//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------





@end
