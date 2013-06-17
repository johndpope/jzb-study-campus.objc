//
//  ScrollableToolbar.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 31/03/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#import <UIKit/UIKit.h>




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Enumerations & definitions
//*********************************************************************************************************************
#define ITEMSETID_NONE 0
typedef void (^TConfirmBlock)(void);
typedef void (^TCancelBlock)(void);




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface STBItem : NSObject

@property (nonatomic, strong) NSString      *title;
@property (nonatomic, strong) UIImage       *image;
@property (nonatomic, assign) NSUInteger    tagID;
@property (nonatomic, weak)   id            target;
@property (nonatomic, assign) SEL           action;

+ (STBItem *) itemWithTitle:(NSString *)title image:(UIImage *)image tagID:(NSUInteger)tagID target:(id)target action:(SEL)action;

@end




//*********************************************************************************************************************
#pragma mark -
#pragma mark Public Interface definition
//*********************************************************************************************************************
@interface ScrollableToolbar : UIView


@property (nonatomic, readonly) NSUInteger  itemSetID;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS public methods
//---------------------------------------------------------------------------------------------------------------------


// =====================================================================================================================
#pragma mark -
#pragma mark INSTANCE public methods
// ---------------------------------------------------------------------------------------------------------------------
- (void) addItem:(STBItem *)item;
- (void) setItems:(NSArray *)items itemSetID:(NSUInteger)itemSetID animated:(BOOL)animated;
- (void) removeAllItemsAnimated:(BOOL)animated;

- (void) activateEditModeForItemWithTagID:(NSUInteger)tagID
                                 animated:(BOOL)animated
                             confirmBlock:(TConfirmBlock)confirmBlock
                              cancelBlock:(TCancelBlock)cancelBlock;
- (void) deactivateEditModeAnimated:(BOOL)animated;
- (BOOL) isEditModeActive;
- (void) enableConfirmButton:(BOOL)enable count:(NSInteger)count;

@end
