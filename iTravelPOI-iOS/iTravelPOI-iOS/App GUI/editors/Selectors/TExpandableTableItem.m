//
//  TExpandableTableItem.m
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 25/05/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __TExpandableTableItem__IMPL__
#import "TExpandableTableItem.h"
#import "MCategory.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define INDEX_UNCHECKED -100
#define INDEX_CHECK_FAULT -200




//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface TExpandableTableItem()

@property (nonatomic, assign) BOOL isExpandable;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) NSInteger checkedIndex;
@property (nonatomic, strong) NSMutableArray *categories;


@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation TExpandableTableItem




//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (TExpandableTableItem *) expandableTableItemWithCategory:(MCategory *)cat isChecked:(BOOL) isChecked {
    
    TExpandableTableItem *me = [[TExpandableTableItem alloc] init];
    me.isExpandable = cat.subCategories.count>0 || cat.parent!=nil;
    me.isExpanded = FALSE;
    me.checkedIndex = !isChecked ? INDEX_UNCHECKED : (!me.isExpandable ? 0 :  (cat.parent==nil ? 1 : INDEX_CHECK_FAULT));
    me.categories = [NSMutableArray array];
    [me.categories addObject:cat];
    return me;
}



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (void) fillCellView:(UITableViewCell *)cell withIndex:(NSInteger)index {
    
    // Consigue la categoria que tiene la informacion para ese indice
    MCategory *category = [self categoryToShowAtIndex:index];
    
    
    // --- Texto --------------------------------------------------------------
    if(self.isExpanded && index==0) {
        cell.textLabel.text = category.name;
    } else {
        cell.textLabel.text = category.fullName;
    }
    
    // --- Color texto --------------------------------------------------------
    if(self.isExpandable && index==0) {
        cell.textLabel.textColor = [UIColor blueColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    
    // --- Img icono ----------------------------------------------------------
    if(self.isExpandable && index==0) {
        cell.imageView.image = self.isExpanded ? TExpandableTableItem.imageExpanded : TExpandableTableItem.imageCollapsed;
    } else {
        cell.imageView.image = category.entityImage;
    }
    
    // --- Img check ----------------------------------------------------------
    if(!self.isExpandable) {
        ((UIImageView *)cell.accessoryView).image = self.checkedIndex==index ? TExpandableTableItem.imageChecked : TExpandableTableItem.imageUnchecked;
    } else {
        if(index==0) {
            if(self.isExpanded) {
                ((UIImageView *)cell.accessoryView).image = nil;
            } else {
                ((UIImageView *)cell.accessoryView).image = self.checkedIndex!=INDEX_UNCHECKED ? TExpandableTableItem.imageChecked : TExpandableTableItem.imageUnchecked;
            }
        } else {
            ((UIImageView *)cell.accessoryView).image = self.checkedIndex==index ? TExpandableTableItem.imageChecked : TExpandableTableItem.imageUnchecked;
        }
    }
    
    
}

//---------------------------------------------------------------------------------------------------------------------
- (MCategory *) clickedAtIndex:(NSInteger)index selCats:(NSArray *)selCats excludedCat:(MCategory *)excludedCat{

    // Categoria seleccionada en la seccion
    MCategory *selCategory = nil;
    
    // Ajusta el indice del elemento seleccionado
    if(!self.isExpandable || index>0) {
        selCategory = [self categoryToShowAtIndex:index];
        if(self.checkedIndex==index) {
            self.checkedIndex = INDEX_UNCHECKED;
        } else {
            self.checkedIndex = index;
        }
    }
    
    // Ajusta el estado de expansion si es necesario
    self.isExpanded = self.isExpandable ? !self.isExpanded : FALSE;
    
    // Si se ha expandido por primera vez necesita cargar la informacion
    if(self.isExpanded && self.categories.count==1) {
        MCategory *oldRoot=self.categories[0];
        [self.categories removeAllObjects];
        
        // Comprueba si se debe filtrar algo o se añade tal cual
        if(excludedCat==nil) {
            [self.categories addObjectsFromArray:oldRoot.allInHierarchy];
        } else {
            for(MCategory *cat in oldRoot.allInHierarchy) {
                if(cat.internalIDValue != excludedCat.internalIDValue && ![cat isDescendatOf:excludedCat]){
                    [self.categories addObject:cat];
                }
            }
        }
        
        // Si habia un FAULT debe ajustar el indice del elemento chequeado ahora que los tiene
        if(self.checkedIndex==INDEX_CHECK_FAULT) {
            for(NSInteger index=0;index<self.categories.count;index++) {
                MCategory *currCat = self.categories[index];
                if(oldRoot.internalIDValue==currCat.internalIDValue) {
                    self.checkedIndex = index + 1;
                    break;
                }
            }
        }
    }
    
    return selCategory;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger) currentSize {
    
    return !self.isExpanded ? 1 : self.categories.count+1;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) isChecked {
    return self.checkedIndex != INDEX_UNCHECKED;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) clearCheck {
    if(self.checkedIndex == INDEX_CHECK_FAULT) {
        self.categories[0] = [self.categories[0] rootParent];
    }
    self.checkedIndex = INDEX_UNCHECKED;
}


//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (MCategory *)categoryToShowAtIndex:(NSInteger)index {
    
    if(index>0) {
        return self.categories[index-1];
    } else {
        if(!self.isExpandable || self.isExpanded || self.checkedIndex==INDEX_CHECK_FAULT || self.checkedIndex==INDEX_UNCHECKED) {
            return self.categories[0];
        } else {
            return self.categories[self.checkedIndex-1];
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) addSelectedCategory:(MCategory *)addedCat selCats:(NSMutableArray *)selCats {
    
    for(MCategory *selCat in selCats) {
        if(selCat.hierarchyIDValue==addedCat.hierarchyIDValue) {
            [selCats removeObject:selCat];
            break;
        }
    }
    [selCats addObject:addedCat];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) removeSelectedCategory:(MCategory *)removedCat selCats:(NSMutableArray *)selCats {
    
    for(MCategory *selCat in selCats) {
        if(selCat.hierarchyIDValue==removedCat.hierarchyIDValue) {
            [selCats removeObject:selCat];
            break;
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) imageChecked {
    
    // Carga las imagenes la primera vez y las reutiliza
    static __strong UIImage *__imgChecked = nil;
    if(__imgChecked==nil) {
        __imgChecked = [UIImage imageNamed:@"checkmark-checked"];
    }
    return __imgChecked;
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) imageUnchecked {
    
    // Carga las imagenes la primera vez y las reutiliza
    static __strong UIImage *__imgUnchecked = nil;
    if(__imgUnchecked==nil) {
        __imgUnchecked = [UIImage imageNamed:@"checkmark-unchecked"];
    }
    return __imgUnchecked;
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) imageCollapsed {
    
    // Carga las imagenes la primera vez y las reutiliza
    static __strong UIImage *__imgCollapsed = nil;
    if(__imgCollapsed==nil) {
        __imgCollapsed = [UIImage imageNamed:@"item-collapsed"];
    }
    return __imgCollapsed;
}

//---------------------------------------------------------------------------------------------------------------------
+ (UIImage *) imageExpanded {
    
    // Carga las imagenes la primera vez y las reutiliza
    static __strong UIImage *__imgExpanded = nil;
    if(__imgExpanded==nil) {
        __imgExpanded = [UIImage imageNamed:@"item-expanded"];
    }
    return __imgExpanded;
}

@end

